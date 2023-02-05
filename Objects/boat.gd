extends RigidBody3D

@export var JUMP_VELOCITY = 1.5
@export var SPEED = 15
var _angular_speed = 2
var floating
var beached
var build_up_speed = 50

enum Status {OFF, ON, PARKED}
var status = Status.OFF

func _ready():
	status = Status.OFF

func _physics_process(delta):
	floating = _check_float_points()
	beached = _check_ground_collide()
	
	if floating:
		_keep_afloat()
				
	if status == Status.OFF:
		_expand_wings(delta * 2)
		if beached:
			sleeping = true
	else:
		sleeping = false
		if Input.is_action_pressed("left"):
			apply_torque_impulse(Vector3(0,1,0) * 150)
		if Input.is_action_pressed("right"):
			apply_torque_impulse(Vector3(0,-1,0) * 150)
		if Input.is_action_pressed("up"):
			if global_transform.origin.y < 9:
				build_up_speed = 400
			else:
				build_up_speed = 800
			apply_central_impulse(global_transform.basis * Vector3.FORWARD * build_up_speed * -1)
		if Input.is_action_pressed("down"):
			if global_transform.origin.y < 9:
				build_up_speed = 200
			else:
				build_up_speed = 400
			apply_central_impulse(global_transform.basis * Vector3.BACK * build_up_speed * -1)

		if Input.is_action_pressed("jump"):
			if position.y < 200:
				apply_central_impulse(Vector3.UP*200)
			
		if !floating and !beached and Input.is_action_pressed("crouch"):
			apply_central_impulse(Vector3.DOWN*400)
			rotation.x = move_toward(rotation.x, 0, delta)
			rotation.z = move_toward(rotation.z, 0, delta)
		
		if !floating and !Input.is_action_pressed("jump"):
			rotation.x = move_toward(rotation.x, 0, delta)
			rotation.z = move_toward(rotation.z, 0, delta)
		
		if $AltChecker.is_colliding():
			var groundLevel = $AltChecker.get_collision_point()
			if groundLevel.y > 2:
				apply_central_impulse(Vector3.UP*400)
		
		rotation.z = move_toward(rotation.z, 0, delta)
		rotation.x = clamp(rotation.x, deg_to_rad(-5), deg_to_rad(5))
		rotation.z = clamp(rotation.z, deg_to_rad(-5), deg_to_rad(5))
		
		_expand_wings(delta * 2)
	
func _check_float_points():
	var checkFloat = false
	if $Float.global_transform.origin.y <= 0:
		checkFloat = true
	if $Float2.global_transform.origin.y <= 0:
		checkFloat = true
	if $Float3.global_transform.origin.y <= 0:
		checkFloat = true
	if $Float4.global_transform.origin.y <= 0:
		checkFloat = true
	return checkFloat

func _check_ground_collide():
	if $RayToGround.is_colliding() || $RayToGround2.is_colliding():
		return true
	else:
		return false
		
func _expand_wings(delta):
	if position.y > 9 and status == Status.ON:
		$Wing_Left.rotation.z = move_toward($Wing_Left.rotation.z, deg_to_rad(-90), delta)
		$Wing_Left.rotation.x = move_toward($Wing_Left.rotation.x, deg_to_rad(0), delta)
		$Wing_Left.position.x = move_toward($Wing_Left.position.x, 4, delta)
		$Wing_Right.rotation.z = move_toward($Wing_Right.rotation.z, deg_to_rad(-90), delta)
		$Wing_Right.rotation.x = move_toward($Wing_Right.rotation.x, deg_to_rad(0), delta)
		$Wing_Right.position.x = move_toward($Wing_Right.position.x, -4, delta)
	else:
		$Wing_Left.rotation.z = move_toward($Wing_Left.rotation.z, deg_to_rad(0), delta)
		$Wing_Left.rotation.x = move_toward($Wing_Left.rotation.x, deg_to_rad(-90), delta)
		$Wing_Left.position.x = move_toward($Wing_Left.position.x, 2.8, delta)
		$Wing_Right.rotation.z = move_toward($Wing_Right.rotation.z, deg_to_rad(0), delta)
		$Wing_Right.rotation.x = move_toward($Wing_Right.rotation.x, deg_to_rad(90), delta)
		$Wing_Right.position.x = move_toward($Wing_Right.position.x, -2.8, delta)


func _on_lilguy_entered_vehicle():
	status = Status.ON

func _on_lilguy_exited_vehicle():
	status = Status.OFF

func _keep_afloat():
	var number_under_water = 0
	if $Float.global_transform.origin.y < 0:
		number_under_water += 1
	if $Float2.global_transform.origin.y < 0:
		number_under_water += 1
	if $Float3.global_transform.origin.y < 0:
		number_under_water += 1
	if $Float4.global_transform.origin.y < 0:
		number_under_water += 1
	if number_under_water == 4:
#		apply_impulse(Vector3.UP*400*-$Float4.global_transform.origin, $Float4.global_transform.origin-global_transform.origin)
		apply_impulse(Vector3.UP*400*-global_transform.origin)
