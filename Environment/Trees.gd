extends Node3D
var chunks

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_chunks():
	chunks = get_parent().terrain_chunks
	print(chunks)
