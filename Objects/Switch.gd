extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var target_path : NodePath = ""

# Called when the node enters the scene tree for the first time.
func _ready():
    $Sprite.frame = 0

func set_on():
    if target_path == "":
        return
    var target = get_node(target_path)
    target.lit = true
    $Sprite.frame = 1
    $CollisionShape2D.disabled = true
    Manager.play_oneshot_sound_effect("switch", global_position)
    Manager.play_oneshot_sound_effect("torchlight", target.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
