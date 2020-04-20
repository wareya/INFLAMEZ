extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $Label.text = \
"""TOKENS: %d/%d
TORCHES: %d/%d
FIZZLES: %d
DEATHS: %d
""" % \
    [Manager.tokens, Manager.tokens_seen,
    Manager.torches, Manager.torches_seen,
    Manager.fizzles,
    Manager.deaths]
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
