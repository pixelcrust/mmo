extends CharacterBody2D

const packets := preload("res://packets.gd")
const Scene := preload("res://objects/actor/actor.tscn")
const Actor := preload("res://objects/actor/actor.gd")

@export var speed = 200
@export var friction = 0.01
@export var acceleration = 0.1

var actor_id: int
var actor_name: String
var start_x: float
var start_y: float
var start_rad: float
var is_player: bool

@onready var _nameplate: Label = $Nameplate
@onready var _collision_shape: CircleShape2D = $hitbox_movement2.shape
@onready var _camera: Camera2D = $Camera2D

static func instantiate(actor_id: int, actor_name: String, x: float, y: float, speed: float, is_player: bool) -> Actor:
	var actor := Scene.instantiate()
	actor.actor_id = actor_id
	actor.actor_name = actor_name
	actor.start_x = x
	actor.start_y = y
	actor.start_rad = rad
	actor.speed = speed
	actor.is_player = is_player
	
	return actor

func _ready():
	position.x = start_x
	position.y = start_y
	
	velocity = Vector2.RIGHT * speed
	_nameplate.text = actor_name
	
func get_input():
	var input = Vector2()
	if Input.is_action_pressed("key_right"):
		input.x += 1
	if Input.is_action_pressed("key_left"):
		input.x -= 1
	if Input.is_action_pressed("key_down"):
		input.y += 1
	if Input.is_action_pressed("key_up"):
		input.y -= 1
	return input

func _physics_process(delta):
	
	if not is_player:
		return
		
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()
	
	var packet := packets.Packet.new()
	var player_direction_msg := packet.new_player_direction()
	player_direction_msg.set_direction(velocity.angle())
	WS.send(packet)

func _input(event: InputEvent) -> void:
	if is_player and event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_camera.zoom.x = min(4, _camera.zoom.x + 0.1)
			MOUSE_BUTTON_WHEEL_DOWN:
				_camera.zoom.x = max(0.1, _camera.zoom.x - 0.1)
		_camera.zoom.y = _camera.zoom.x
