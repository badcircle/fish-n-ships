extends CharacterBody3D

const BASE_SPEED = PI * 2
const RUN_SPEED = BASE_SPEED * 1.75
const JUMP_VELOCITY = 7.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var health : int = 50
@export var stam : float = 1.0
@export var mana : float = 1.0

@export var cam:Node3D
@export var cam_v:Node3D
@export var flightui:CanvasGroup
@export var ui:CanvasGroup

signal entered_vehicle
signal exited_vehicle

var mouse_input = Vector2()
var move_vector = Vector3()
var mouse_visible = true

enum Stance {IDLE, WALK, RUN, JUMP, COMBAT, FISH, CRAFT, LOOT, TARGET, SCOPE, PILOT}
var stance
var speed = BASE_SPEED
var ani : AnimationTree

var prev_pos

func _ready():
	stance = Stance.IDLE
	ani = $package/aniTree
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_visible = false

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	if Input.is_action_just_released("ui_cancel"):
		if mouse_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _physics_process(delta):
	if mouse_input != Vector2():
		if !Input.is_action_pressed("control_turn"):
#			cam.rotation_degrees.y += -mouse_input.x *.1
			pass
		cam_v.rotation_degrees.x += mouse_input.y *-.1
#		cam.rotation_degrees.y = clamp(cam.rotation_degrees.y, -180, 180)
		cam_v.rotation_degrees.x = clamp(cam_v.rotation_degrees.x, 20, 90)
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_match_stance(delta, direction)
	prev_pos = position
	_coords()
	_altitude_ui()
		
	match stance:
		Stance.PILOT, Stance.FISH, Stance.CRAFT, Stance.LOOT, Stance.TARGET, Stance.SCOPE:
			pass
		Stance.IDLE, Stance.WALK, Stance.RUN, Stance.JUMP, Stance.COMBAT:
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			if direction:
				if Input.is_action_pressed("boost"):
					stance = Stance.RUN
					speed = RUN_SPEED
				else:
					stance = Stance.WALK
					speed = BASE_SPEED
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				stance = Stance.IDLE
				velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
				velocity.z = move_toward(velocity.z, 0, BASE_SPEED)
			if !Input.is_action_pressed("control_turn"):
				if Input.is_action_pressed("left"):
					rotation_degrees.y += 2.6
				if Input.is_action_pressed("right"):
					rotation_degrees.y -= 2.6
				
			cam.rotation_degrees.y = clamp(cam.rotation_degrees.y, -45, 45)
			if Input.is_action_pressed("control_turn"):
				cam.rotation_degrees.y = move_toward(cam.rotation_degrees.y, 0, 1)
				rotation_degrees.y -= mouse_input.x * 0.1
			move_and_slide()
	
	if Input.is_action_just_released("enter_vehicle"):
		if stance == Stance.PILOT:
			stance = Stance.IDLE
			var new_parent = get_parent().get_parent()
			var this_pos = global_position
			var this_rot = global_rotation
			get_parent().remove_child(self)
			new_parent.add_child(self)
			self.rotation.y = this_rot.y
			self.position = this_pos
			$H.position.z = 3
			emit_signal("exited_vehicle")
		else:
			if $los.is_colliding():
				stance = Stance.PILOT
				var target = $los.get_collider(0)
				var new_parent = target.get_parent().get_parent()
				get_parent().remove_child(self)
				new_parent.add_child(self)
				self.rotation.y = deg_to_rad(-180)
				self.position = target.position + Vector3(-0.8,0.5,0)
				$H.position.z = 6
				emit_signal("entered_vehicle")
	
	if stance == Stance.PILOT:
		if Input.is_action_pressed("control_turn"):
			if mouse_input.x < 0:
				get_parent().apply_torque_impulse(Vector3(0,1,0) * 200)
			elif mouse_input.x > 0:
				get_parent().apply_torque_impulse(Vector3(0,-1,0) * 200)
	
	mouse_input = Vector2()

func _match_stance(delta, direction):
	match stance:
		Stance.IDLE, Stance.PILOT:
			ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], 0, 0.1)
		Stance.WALK:
			ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], 0.55, 0.05)
		Stance.RUN:
			ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], 1, 0.04)

func _coords():
	ui.get_node("Coords").text = str("Location: {0}, {1}").format({0:"%0.0f" % global_position.x, 1:"%0.0f" % global_position.z})

func _altitude_ui():
	if global_position.y > 1:
		flightui.visible = true
		flightui.get_node("Alt").text = str("Altitude: {0}").format({0:"%0.0f" % global_position.y})
	else:
		flightui.visible = false
