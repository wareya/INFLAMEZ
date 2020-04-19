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

func play_bgm(music = null):
    
    var file = "res://Music/" + music + ".ogg"
    if current_music == file:
        return
    current_music = file
    
    if simulate == false:
        yield(self, "fadein_done")
    
    if File.new().file_exists(file):
        var asdf = load(file)
        $BGM.stream = asdf
        $BGM.play()
        print("playing " + file)


func fadein_end():
    emit_signal("fadein_done")
    $AnimationPlayer.current_animation = "stop"
    simulate = true

func fadein_start():
    simulate = false
        
func fadeout_end():
    emit_signal("fadeout_done")
    $AnimationPlayer.current_animation = "stop"

func fadeout_start():
    simulate = false\

func _onready():
    $CanvasLayer/Overlay.texture = preload("res://Sprites/splash.png")

func set_danger(danger : float):
    $CanvasLayer/Danger.modulate.a = pow(1-danger, 2)
    if danger <= 0:
        $CanvasLayer/Overlay.texture = preload("res://Sprites/death.png")
        $AnimationPlayer.current_animation = "fadeout"
        $BGM/Anim.current_animation = "fadeout_slow"
        simulate = false
    pass

func change_level(path : String):
    simulate = false
    $AnimationPlayer.current_animation = "fadeout"
    var loader = ResourceLoader.load_interactive(path)
    yield(self, "fadeout_done")
    loader.wait()
    var target = loader.get_resource()
    print("changing to...")
    print(target)
    get_tree().change_scene_to(target)
    $AnimationPlayer.current_animation = "fadein"
    pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
