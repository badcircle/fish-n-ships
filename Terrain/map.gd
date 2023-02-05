extends MeshInstance2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var img =  get_parent().get_node("Camera3D").get_viewport().get_texture().get_data()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	get_node("map").texture = tex # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
