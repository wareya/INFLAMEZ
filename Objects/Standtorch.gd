extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var lit = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if lit:
        $AnimationPlayer.current_animation = "on"
        $Sprite/Light2D.energy = 1.0 + (1-Manager.stored_danger)*3
        $Sprite/HiddenLight.energy = (1-Manager.stored_danger)*3
    else:
        $AnimationPlayer.current_animation = "off"
        $Sprite/Light2D.energy = 0.0
        $Sprite/HiddenLight.energy = (1-Manager.stored_danger)*3
