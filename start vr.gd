extends Node3D

# Preload both player scenes
const VR_PLAYER = preload("res://scenes/player/vr_player.tscn")
const DESKTOP_PLAYER = preload("res://scenes/player/player.tscn")

# Drag your Marker3D into this slot in the Inspector
@export var spawn_point: Marker3D

# Optional extra rotation in degrees (X, Y, Z) to fine-tune facing direction
@export var rotation_offset_degrees: Vector3 = Vector3.ZERO

var xr_interface: XRInterface

func _ready() -> void:
	# 1. Look for the OpenXR interface
	xr_interface = XRServer.find_interface("OpenXR")
	
	var player_instance: Node3D
	
	# 2. Check if OpenXR can initialize (detects if a runtime/headset is running)
	if xr_interface and xr_interface.is_initialized():
		print("VR Headset detected. Initializing VR Player...")
		
		# Turn off VSync to let the headset control the framerate
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		# Tell the main viewport to output to the VR headset
		get_viewport().use_xr = true
		
		# Instantiate the VR player scene
		player_instance = VR_PLAYER.instantiate()
	else:
		print("No VR headset detected. Spawning Desktop Player...")
		
		# Fall back to standard flat-screen rendering
		get_viewport().use_xr = false
		
		# Instantiate the desktop player scene
		player_instance = DESKTOP_PLAYER.instantiate()
	
	# Add the player to the scene tree first so global transforms work properly
	add_child(player_instance)
	
	# Move and rotate the player to match the Marker3D
	if spawn_point:
		player_instance.global_position = spawn_point.global_position
		player_instance.global_rotation = spawn_point.global_rotation
		
		# Apply any extra rotation offset from the Inspector
		player_instance.rotate_x(deg_to_rad(rotation_offset_degrees.x))
		player_instance.rotate_y(deg_to_rad(rotation_offset_degrees.y))
		player_instance.rotate_z(deg_to_rad(rotation_offset_degrees.z))
	else:
		push_warning("No Marker3D assigned to spawn_point! Spawning at (0, 0, 0).")
