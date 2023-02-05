extends Node3D
var rows = 4
var cols = 4
@export_node_path(MeshInstance3D) var tile

# Called when the node enters the scene tree for the first time.
func _ready():
	for col in range(1, cols+1):
		for row in range(1, rows+1):
			print(col, ":", row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
