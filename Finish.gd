extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    var assist_text = ""
    if Manager.assist:
        assist_text = "ASSIST MODE ON"
    var skip_text = ""
    if Manager.skip_used:
        skip_text = "SKIP USED"
    $Label.text = \
"""TOKENS: %d/%d
TORCHES: %d/%d
FIZZLES: %d
DEATHS: %d
%s
%s
""" % \
    [Manager.tokens, Manager.tokens_seen,
    Manager.torches, Manager.torches_seen,
    Manager.fizzles,
    Manager.deaths, assist_text, skip_text]
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
