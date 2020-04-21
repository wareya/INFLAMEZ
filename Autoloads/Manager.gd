extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal fadein_done
signal fadeout_done
signal music_faded


# Called when the node enters the scene tree for the first time.
func _ready():
#    $AnimationPlayer.current_animation = "fadein"
    pass # Replace with function body.

var simulate = false

var current_music = ""

var found_trinkets : Dictionary = {}

var deaths = 0
var fizzles = 0
var tokens_seen = 0
var tokens = 0
var torches_seen = 0
var torches = 0
var assist = false

var last_visited_torch_position = null

var skip_used = false

func play_bgm(music = null):
    var file = "res://Music/" + music + ".ogg"
    if current_music == file:
        return
    current_music = file
    
    if simulate == false:
        yield(self, "fadein_done")
    
    var asdf = load(file)
    $BGM.stream = asdf
    $BGM.play()
    print("playing " + file)

func play_oneshot_sound_effect(name : String, _global_position : Vector2):
    var effect = load("res://Sounds/"+name+".wav")
    var player = AudioStreamPlayer2D.new()
    player.stream = effect
    player.global_position = _global_position
    player.play()
    add_child(player)
    yield(player, "finished")
    remove_child(player)
    pass

func play_oneshot_sound_effect_screenlocal(name : String):
    var effect = load("res://Sounds/"+name+".wav")
    var player = AudioStreamPlayer.new()
    player.stream = effect
    player.play()
    add_child(player)
    yield(player, "finished")
    remove_child(player)
    pass

func fadein_end():
    emit_signal("fadein_done")
    #$AnimationPlayer.stop()
    simulate = true

func fadein_start():
    simulate = false
        
func fadeout_end():
    emit_signal("fadeout_done")
    #$AnimationPlayer.stop()

func fadeout_start():
    simulate = false

func _onready():
    $CanvasLayer/Overlay.texture = preload("res://Sprites/splash.png")

var stored_danger = 1.0

func set_danger(danger : float):
    stored_danger = danger
    $CanvasLayer/Danger.modulate.a = 1-pow(danger, 2)
    if danger <= 0:
        deaths += 1
        var scene_name = get_tree().get_current_scene().filename
        $CanvasLayer/Overlay.texture = preload("res://Sprites/death.png")
        $AnimationPlayer.current_animation = "fadeout"
        simulate = false
    pass

func reload_level():
    $CanvasLayer/Overlay.texture = preload("res://Sprites/splash.png")
    deaths += 1
    if assist and last_visited_torch_position != null:
        for player in get_tree().get_nodes_in_group("Player"):
            player.global_position = last_visited_torch_position
            player.velocity = Vector2(0, 0)
            player.life = player.max_life
            player.fire = player.max_fire
            $AnimationPlayer.stop()
            $CanvasLayer/Danger.modulate.a = 0
            $CanvasLayer/Overlay.modulate.a = 0
            stored_danger = 1
    else:
        var scene_name = get_tree().get_current_scene().filename
        if !assist and found_trinkets.has(scene_name):
            tokens -= 1
            found_trinkets.erase(scene_name)
        $AnimationPlayer.stop()
        $CanvasLayer/Danger.modulate.a = 0
        $CanvasLayer/Overlay.modulate.a = 0
        get_tree().reload_current_scene()
    simulate = true

func change_level(path : String):
    for torch in get_tree().get_nodes_in_group("StandTorch"):
        if torch.lit:
            torches += 1
        torches_seen += 1
    tokens_seen += 1
    simulate = false
    $AnimationPlayer.current_animation = "fadeout"
    var loader = ResourceLoader.load_interactive(path)
    yield(self, "fadeout_done")
    loader.wait()
    var target = loader.get_resource()
    print("changing to...")
    print(path)
    get_tree().change_scene_to(target)
    last_visited_torch_position = null
    $AnimationPlayer.current_animation = "fadein"
    pass


func _process(delta):
    if stored_danger <= 0:
        $CanvasLayer/Danger.modulate.a = 1
