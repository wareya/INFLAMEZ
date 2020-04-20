extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    var scene_name = get_tree().get_current_scene().filename
    if Manager.found_trinkets.has(scene_name):
        $Sprite.visible = false

func acquire():
    var scene_name = get_tree().get_current_scene().filename
    Manager.found_trinkets[scene_name] = true
    destroy()

func _process(_delta):
    var scene_name = get_tree().get_current_scene().filename
    if Manager.found_trinkets.has(scene_name):
        destroy()

func destroy():
    get_parent().remove_child(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
