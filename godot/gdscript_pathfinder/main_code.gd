extends Node2D  # Nodo contenedor de los TileMapLayer

#signal ready_main_complete  # Definimos la señal

#@onready var player = $Player;

var grid_size = Vector2i(10, 10);
var directory = {};
var last_tile = Vector2i(0,0);  # Almacena la última celda donde se dibujó el marco

const CELL_SIZE = Vector2i(128, 128);
const BASE_LINE_WIDTH = 5.0;
const DRAW_COLOR = Color.BLACK #* Color(1, 1, 1, 0.502);

# The object for pathfinding on 2D grids.
var _astar = Heuristica.new();

var _start_point = Vector2i();
var _end_point = Vector2i();
var _path = PackedVector2Array();

# Referencias a las capas
@onready var base_layer = $"../TileSuelo";
@onready var overlay_layer = $"../TileMarco";
@onready var start_finish_layer = $"../TileInicioFin";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true);
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			directory[str(Vector2i(x, y))] = {
				"Tipo": "Suelo",
				"Posicion": str(Vector2i(x,y))
			};
			# Capa base (color de fondo)
			base_layer.set_cell(Vector2i(x, y),base_layer.base_id.SUELO, Vector2i(0, 0),0);
	print(directory);
	# Region should match the size of the playable area plus one (in tiles).
	# In this demo, the playable area is 17×9 tiles, so the rect size is 18×10.
	_astar.region = Rect2i(Vector2i(0, 0), grid_size);
	_astar.cell_size = CELL_SIZE;
	_astar.offset = CELL_SIZE * 0.5;
	_astar.solid_on_diagonal_between_solids = true;
	_astar.update()

	for i in range(_astar.region.position.x, _astar.region.end.x):
		for j in range(_astar.region.position.y, _astar.region.end.y):
			var pos = Vector2i(i, j)
			if base_layer.get_cell_source_id(pos) == base_layer.base_id.OBSTACULO:
				_astar.set_point_solid(pos);
	#emit_signal("ready_main_complete");
	#player.on_main_ready();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var tile = base_layer.local_to_map(get_global_mouse_position());
	
	# Solo actualizar si estamos dentro del grid
	if directory.has(str(tile)):
		# Limpiar el marco de la celda anterior en la capa de marcos
		if last_tile != tile:
			#overlay_layer.set_cell(last_tile, overlay_layer.overlay_id,Vector2i(0,0),0);
			overlay_layer.erase_cell(last_tile);
		
		# Dibujar el marco en la nueva celda en la capa de marcos
		overlay_layer.set_cell(tile,overlay_layer.overlay_id,Vector2i(0,0),0);
		last_tile = tile;
		#print(directory[str(tile)]);
	# Siguiente instrucción:

# Canvas llama por sistema al _draw() de todos sus hijos, es como un _process(delta)
func _draw():
	# Supongo que borra todo y redibuja, si path está vacío no dibujamos nada y listo.
	if _path.is_empty():
		return;
	# Le decimos que cuando se llame (se llamará si lo pido por queue_redraw() ) dibuje el trayecto en pantalla
	var last_point = self.base_layer.map_to_local(_start_point);
	for index in range(0, len(_path)):
		var current_point = _path[index];
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true);
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR);
		last_point = current_point;

func get_centered_position(local_position): # get_centered_position sería mejor nombre
	return self.base_layer.map_to_local(self.base_layer.local_to_map(local_position));

func is_point_walkable(local_position):
	var map_position = self.base_layer.local_to_map(local_position);
	if _astar.is_in_boundaries(map_position):
		return not _astar.is_point_solid(map_position);
	return false;

func is_point_in_boundries(local_position):
	var map_position = self.base_layer.local_to_map(local_position);
	return _astar.is_in_boundaries(map_position);

# Limpia los dibujos que ya trazamos cuando hicimos el camino
func clear_path():
	if not _path.is_empty():
		_path.clear();
		self.start_finish_layer.erase_cell(_start_point);
		self.start_finish_layer.erase_cell(_end_point);
		# Queue redraw to clear the lines and circles.
		queue_redraw();

func find_path(local_start_point, local_end_point):
	clear_path();

	_start_point = self.base_layer.local_to_map(local_start_point);
	_end_point = self.base_layer.local_to_map(local_end_point);
	_path = _astar.get_point_path(_start_point, _end_point);

	if not _path.is_empty():
		self.start_finish_layer.set_cell(_start_point, start_finish_layer.start_finish_id.START, Vector2i(0,0));
		self.start_finish_layer.set_cell(_end_point, start_finish_layer.start_finish_id.FINISH, Vector2i(0,0));

	# Redraw the lines and circles from the start to the end point.
	queue_redraw();

	return _path.duplicate();

func is_astar_point_solid(local_position):
	var map_position = self.base_layer.local_to_map(local_position);
	if _astar.is_in_boundaries(map_position):
		return _astar.is_point_solid(map_position);
	else:
		return -1;

func get_base_id_from_local(local_position : Vector2i):
	var map_position = self.base_layer.local_to_map(local_position);
	if _astar.is_in_boundaries(map_position):
		return self.base_layer.get_cell_source_id(map_position);
	else:
		return null;

func set_obstaculo(local_position : Vector2i) -> void:
	var map_position = self.base_layer.local_to_map(local_position);
	if _astar.is_in_boundaries(map_position):
		_astar.set_point_solid(map_position, true);
		#self.base_layer.erase_cell(map_position);
		self.base_layer.set_cell(map_position, base_layer.base_id.OBSTACULO, Vector2i(0,0));

func set_suelo(local_position : Vector2i) -> void:
	var map_position = self.base_layer.local_to_map(local_position);
	if _astar.is_in_boundaries(map_position):
		_astar.set_point_solid(map_position, false);
		self.base_layer.erase_cell(map_position);
		self.base_layer.set_cell(map_position, base_layer.base_id.SUELO, Vector2i(0,0));
