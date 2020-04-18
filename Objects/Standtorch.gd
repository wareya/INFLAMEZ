extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var lit = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if lit:
        $AnimationPlayer.current_animation = "on"
    else:
        $AnimationPlayer.current_animation = "off"
