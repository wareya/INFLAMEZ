extends KinematicBody2D

func _ready():
    $PlayerSprite.transform.x.x = look_direction

const topspeed = 77.7
const jumpspeed = 190.0
const gravity = 500.0
const bad_slope_limit = 0.7 # not a normal

var walk_state = 0
export var look_direction = 1

var velocity : Vector2 = Vector2(0, 0)

var want_to_jump = false

const max_fire = 120.0
var fire = max_fire
var max_life = 15.0
var life = max_life

const walljump_consumed_fire = 5.0
const walljump_timer_max = 1
const second_walljump_timer_max = 0.7
var second_walljump_timer = 0
var walljump_timer = 0
var walljumping_enabled = true
var walljump_xvel = 0 # dynamic
var last_walljump_dir = 0

func get_which_wall_collided():
    for i in range(get_slide_count()):
        var collision = get_slide_collision(i)
        if collision.normal.x > 0.9:
            return 1
        elif collision.normal.x < -0.9:
            return -1
    return 0

var was_on_ground_last_frame = false

var in_water = false

const damage_cooldown_max = 0.5
var damage_cooldown = 0
const movement_damage_cooldown_max = 0.5
var movement_damage_cooldown = 0
var num_damage_bodies_in = 0

func _physics_process(delta):
    if Input.is_action_just_pressed("restart") and life <= 0:
        Manager.reload_level()
        Manager.play_oneshot_sound_effect_screenlocal("respawn")
        return
    
    $Canvas/Fire.visible = Manager.simulate
    if Manager.simulate == false:
        return
    var previous_walk_state = walk_state
    if Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
        walk_state = -1
    if !Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
        walk_state = 1
        
    if Input.is_action_just_pressed("ui_left"):
        walk_state = -1
        walljump_timer = 0
    if Input.is_action_just_pressed("ui_right"):
        walk_state = 1
        walljump_timer = 0
    
    if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
        walk_state = 0
    
    if walk_state != 0:
        look_direction = walk_state
    
    if movement_damage_cooldown > 0:
        walk_state = 0
    
    $PlayerSprite.transform.x.x = look_direction
    
    var just_jumped = false
    
    if movement_damage_cooldown <= 0:
        if walljump_timer <= 0:
            velocity.x = walk_state * topspeed
            if is_on_wall():
                velocity.x *= 0.01
        if walljump_timer > 0:
            var derp = walljump_timer/walljump_timer_max
            derp = derp*derp
            velocity.x = lerp(walljump_xvel, walk_state * topspeed, 1-derp)
            walljump_timer -= delta
        
        if Input.is_action_just_pressed("jump"):
            walljump_timer = 0
            want_to_jump = true
        if !Input.is_action_pressed("jump"):
            walljump_timer = 0
            want_to_jump = false
    elif walljump_timer > 0:
        walljump_timer -= delta
    
    if second_walljump_timer > 0:
        second_walljump_timer -= delta
    
    if want_to_jump and (is_on_floor() or was_on_ground_last_frame):
        velocity.y = -jumpspeed
        want_to_jump = false
        just_jumped = true
        Manager.play_oneshot_sound_effect_screenlocal("jump")
        $JumpParticles.restart()
        $JumpParticles.emitting = true
    
    $WallGrindParticles.emitting = false
    
    if walljumping_enabled:
        var scan_left_result = null
        var scan_right_result = null
        if (velocity.x <= 0 or !is_on_floor()):
            scan_left_result = move_and_collide(Vector2(-1.5, 0), true, true, true)
        if (velocity.x >= 0 or !is_on_floor()) and scan_left_result == null:
            scan_right_result = move_and_collide(Vector2(1.5, 0), true, true, true)
        if is_on_wall() or scan_left_result or scan_right_result:
            var walldir = get_which_wall_collided()
            if walldir == 0 and scan_left_result != null and scan_left_result.normal.x > 0.9:
                walldir = 1
            if walldir == 0 and scan_right_result != null and scan_right_result.normal.x < -0.9:
                walldir = -1
            if walldir != 0 and (last_walljump_dir != walldir or second_walljump_timer <= 0):
                if velocity.x == 0 or sign(velocity.x) != sign(walldir) and movement_damage_cooldown == 0:
                    $WallGrindParticles.emitting = true
                    $WallGrindParticles.position.x = -4*walldir
                if want_to_jump:
                    last_walljump_dir = walldir
                    velocity.y = -jumpspeed*0.8
                    velocity.x = topspeed*walldir
                    walljump_xvel = velocity.x
                    walljump_timer = walljump_timer_max
                    second_walljump_timer = second_walljump_timer_max
                    want_to_jump = false
                    just_jumped = true
                    fire -= walljump_consumed_fire
                    Manager.play_oneshot_sound_effect_screenlocal("jump")
                    $WallJumpParticles.restart()
                    $WallJumpParticles.direction.x = float(walldir)
                    $WallJumpParticles.emitting = true
                    $WallJumpParticles.position.x = -4*walldir
    
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y /= 2
    
    if is_on_floor() and walk_state == 0 and previous_walk_state != 0 and velocity.y < 0 and !just_jumped and damage_cooldown <= 0:
        velocity.y = 0
    
    for trinket in get_tree().get_nodes_in_group("Trinket"):
        if trinket.overlaps_body(self):
            trinket.acquire()
            Manager.play_oneshot_sound_effect_screenlocal("trinketpickup")
    
    for torch in get_tree().get_nodes_in_group("StandTorch"):
        if torch.overlaps_body(self):
            var played_sound = false
            if fire > 0:
                if !torch.lit:
                    played_sound = true
                    Manager.play_oneshot_sound_effect("torchlight", global_position)
                    $PlayerSprite/FlameBlastParticles.restart()
                    $PlayerSprite/FlameBlastParticles.emitting = true
                torch.lit = true
            if torch.lit:
                if fire <= 0 and !played_sound:
                    played_sound = true
                    Manager.play_oneshot_sound_effect("torchlight", global_position)
                    $PlayerSprite/FlameBlastParticles.restart()
                    $PlayerSprite/FlameBlastParticles.emitting = true
                elif fire < max_fire*0.75 and !played_sound:
                    Manager.play_oneshot_sound_effect("torchlightmini", global_position)
                fire = max_fire
    
    if fire > 0:
        for exit in get_tree().get_nodes_in_group("Exit"):
            if exit.overlaps_body(self):
                Manager.change_level(exit.target)
                velocity.x = 0
                if is_on_floor():
                    $PlayerSprite/Anim.current_animation = "stand"
                else:
                    $PlayerSprite/Anim.current_animation = "jump"
                return
    
    was_on_ground_last_frame = is_on_floor()
    
    velocity.y += gravity*delta/2
    
    if in_water:
        velocity.x *= pow(0.95, delta*120)
        if velocity.y > 0:
            velocity.y *= pow(0.95, delta*120)
        else:
            velocity.y *= pow(0.975, delta*120)
    
    var do_floor_snap = true
    var floor_snap = Vector2(0, max(1, min(4, abs(velocity.x)*delta)))
    if velocity.y < -50 or just_jumped:
        floor_snap = Vector2(0, 0)
    do_floor_snap = floor_snap.y > 0
    do_floor_snap = false
    
    var old_velocity_y = velocity.y
    var old_is_on_floor = is_on_floor()
    
    #if do_floor_snap:
    velocity = move_and_slide_with_snap(velocity, floor_snap, Vector2(0, -1), true)
    #else:
    #    velocity = move_and_slide(velocity, Vector2(0, -1), true)
    
    if velocity.y < -bad_slope_limit and velocity.y < old_velocity_y and is_on_wall():
        velocity.y = old_velocity_y
    
    velocity.y += gravity*delta/2
    
    if !old_is_on_floor and is_on_floor():
        if old_velocity_y > 100:
            Manager.play_oneshot_sound_effect_screenlocal("land")
            $LandParticles.restart()
            $LandParticles.emitting = true
        elif old_velocity_y > 50:
            Manager.play_oneshot_sound_effect_screenlocal("landmini")
            $LandParticles.restart()
            $LandParticles.emitting = true
    
    $Camera.position = Vector2(0, 0)
    $Camera.global_position.x = round($Camera.global_position.x)
    $Camera.global_position.y = round($Camera.global_position.y)
    $PlayerSprite.position = Vector2(0, 0)
    $PlayerSprite.global_position.x = round($PlayerSprite.global_position.x)
    $PlayerSprite.global_position.y = round($PlayerSprite.global_position.y)
    
    if fire > 0:
        fire -= delta
        fire -= min(velocity.length_squared()/1500, 15)*delta
        $PlayerSprite/FlameSprite/Light.energy = sqrt(fire/max_fire)
        $PlayerSprite/FlameSprite.visible = true
        life = max_life
        if fire <= 0:
            Manager.play_oneshot_sound_effect("torchgoesout", global_position)
    else:
        $PlayerSprite/FlameSprite/Light.energy = 0
        $PlayerSprite/FlameSprite.visible = false
        life -= delta
    
    Manager.set_danger(life/max_life)
    $Canvas/Fire.value = fire/max_fire*100*1.01
    
    $PlayerSprite/Particles.emitting = fire > 0
    $PlayerSprite/Particles.lifetime = max(0.01, max(0, fire)/max_fire)
    $PlayerSprite/Particles.modulate.a = lerp($PlayerSprite/Particles.modulate.a, sqrt(sqrt(max(0, fire)/max_fire)), 0.1)
    $PlayerSprite/Particles.direction = Vector2(velocity.x * look_direction, velocity.y*0.5).normalized()
    $PlayerSprite/Particles.initial_velocity = velocity.length()*0.5
    
    if !is_on_floor():# and !was_on_ground_last_frame:
        $PlayerSprite/Anim.current_animation = "jump"
    elif abs(velocity.x) > 1 or walk_state != 0:
        if $PlayerSprite/Anim.current_animation != "walk":
            $PlayerSprite/Anim.current_animation_position
        $PlayerSprite/Anim.current_animation = "walk"
    else:
        $PlayerSprite/Anim.current_animation = "stand"
    
    if damage_cooldown > 0:
        damage_cooldown -= delta
    if movement_damage_cooldown > 0:
        movement_damage_cooldown -= delta
    
    if is_on_floor():
        movement_damage_cooldown = 0
    
    if damage_cooldown <= 0 and num_damage_bodies_in > 0:
        if damage_cooldown <= 0:
            do_damage()

func _on_FlameExtinguishArea_body_entered(body):
    if fire > 0:
        Manager.play_oneshot_sound_effect("torchgoesout", global_position)
    fire = 0
    pass # Replace with function body.

func produce_splash():
    var effect = preload("res://Objects/Splash.tscn").instance()
    effect.emitting = true
    effect.one_shot = true
    add_child(effect)
    yield(get_tree().create_timer(1), "timeout")
    remove_child(effect)

func _on_WaterDepthTrick_body_entered(body):
    Manager.play_oneshot_sound_effect("splash", global_position)
    produce_splash()
    z_index = 0
    $PlayerSprite/Particles.z_index = 0
    in_water = true


func _on_WaterDepthTrick_body_exited(body):
    z_index = 10
    $PlayerSprite/Particles.z_index = -1
    in_water = false

func do_damage():
    if fire > 0:
        fire -= max_fire/4
    else:
        life -= max_life/2
    Manager.play_oneshot_sound_effect("hurt", global_position)
    damage_cooldown = damage_cooldown_max
    movement_damage_cooldown = movement_damage_cooldown_max
    velocity = (-velocity + Vector2(-look_direction*20, -50)).normalized()*150
    velocity.x = clamp(velocity.x, -topspeed, topspeed)
    produce_splash()

func _on_Death_body_entered(body):
    num_damage_bodies_in += 1
    if damage_cooldown <= 0:
        do_damage()

func _on_Death_body_exited(body):
    num_damage_bodies_in -= 1


func _on_TRUDEATH_body_entered(body):
    fire = 0
    life = 0
    Manager.play_oneshot_sound_effect_screenlocal("deathtrigger")
