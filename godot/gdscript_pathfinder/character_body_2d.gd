extends CharacterBody2D

enum State { IDLE, FOLLOW };

const MASS = 5.0
const ARRIVE_DISTANCE = 5.0

@export var speed: float = 450.0

var _state = State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../MainCode"
@onready var main_node = $"../MainCode"  # Referencia al nodo Main

var _click_position = Vector2()
var _path = PackedVector2Array()
var _next_point = Vector2()

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

func _change_state(new_state):
	if new_state == State.IDLE:
		_tile_map.clear_path()
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, _click_position)
		if _path.size() < 1:
			_change_state(State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		#_next_point = to_global(_path[1]);
		_next_point = _path[0];
	_state = new_state

func _ready():
	#main_node = $Main;
	#await $Main.ready_main_complete;
	#main_node.connect("ready_main_complete", Callable(self, "_on_main_ready"));
	_on_main_ready();


# Esta función se ejecutará cuando se emita la señal
func _on_main_ready():
	print("Player _ready() ejecutado después del _ready() de Main.")
	# Aquí puedes agregar la lógica que necesites para Player
	_change_state(State.IDLE)

func _move_to(local_position):
	var desired_velocity = (local_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	#rotation = _velocity.angle()
	return position.distance_to(local_position) < ARRIVE_DISTANCE

func _process(_delta):
	if _state != State.FOLLOW:
		return
	var arrived_to_next_point = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(State.IDLE)
			return
		#_next_point = to_global(_path[0]);
		_next_point = _path[0];


#func _input(event):
#	_click_position = get_global_mouse_position()
#	if _tile_map.is_point_walkable(_click_position):
#		# ahora toca modificar el código original para que haga lo que quiero:
#		
#		if Input.is_action_just_pressed("LeftClick"):
#			_change_state(State.FOLLOW);
#			print("aqui soy left")
#		elif Input.is_action_just_pressed("RightClick"):
#			print("aqui soy right")
#			if _tile_map.is_astar_point_solid(_click_position) == true:
#				# es un obstáculo, lo tengo que hacer suelo:
#				_tile_map.set_suelo(_click_position);
#			elif _tile_map.is_astar_point_solid(_click_position) == false:
#				# es suelo, lo tengo que hacer obstáculo:
#				_tile_map.set_obstaculo(_click_position);
#		#if event.is_action_pressed(&"teleport_to", false, true):
#		#	_change_state(State.IDLE)
#		#	global_position = _tile_map.round_local_position(_click_position)
#		#elif event.is_action_pressed(&"move_to"):
#		#	_change_state(State.FOLLOW)

func _input(event):
	if event is InputEventMouseButton:
		_click_position = get_global_mouse_position()
		if _tile_map.is_point_in_boundries(_click_position):
		# ahora toca modificar el código original para que haga lo que quiero:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				#print("aqui soy left")
				if _tile_map.is_point_walkable(_click_position):
					_change_state(State.FOLLOW)
			if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
				#print("aqui soy right")
				if _tile_map.is_astar_point_solid(_click_position) == false:
				# es suelo, lo tengo que hacer obstáculo:
					#print("Celda es suelo, cambiando a obstáculo")
					_tile_map.set_obstaculo(_click_position);
				else:
				# es obstaculo, lo tengo que hacer suelo:
					#print("Celda es obstaculo, cambiando a suelo")
					_tile_map.set_suelo(_click_position);
