class_name Heuristica extends RefCounted

class HeuristicaData:
	var costo_G : int; # distancia del nodo en cuestión al inicial.
	var costo_H : int; # distancia del nodo en cuestión a la meta.
	var costo_F : int; # G+H
	var posicion : Vector2i;
	var parent : HeuristicaData;
	
	func _init(p_posicion : Vector2i = Vector2i(0,0), p_parent : HeuristicaData = null, p_costo_G : int = 0, p_costo_H : int = 0 ):
		posicion = p_posicion;
		parent = p_parent;
		costo_G = p_costo_G;
		costo_H = p_costo_H;
		costo_F = p_costo_G + p_costo_H;
	
	func duplicate() -> HeuristicaData:
		var new_data : HeuristicaData = HeuristicaData.new(posicion, null, costo_G, costo_H);
		new_data.costo_F = costo_G + costo_H;
		if parent != null:
			new_data.parent = parent.duplicate();
		return new_data;

class Cell:
	var is_solid : bool = false;
	
var cell_size : Vector2i = Vector2i(1,1);
var offset : Vector2i = Vector2i(0,0);
var region : Rect2i = Rect2i(0,0,0,0);
var mapa = [];
var solid_on_diagonal_between_solids : bool = true;

func _generar_mapa() -> void:
	mapa.clear();
	for x in range(region.size.x):
		mapa.append([]);
		for y in range(region.size.y):
			mapa[x].append(Cell.new());  # Añadir una nueva celda

func _init() -> void:
	# Inicializar el mapa con celdas
	_generar_mapa();

func update() ->void:
	if region.size.x != mapa.size() or (mapa.size() > 0 and region.size.y != mapa[0].size()):
		_generar_mapa();

func set_point_solid(positionInput : Vector2i, solid_state: bool = true) -> void:
	mapa[positionInput.x][positionInput.y].is_solid = solid_state;

func is_in_boundaries(positionInput : Vector2i) -> bool:
	var does_the_input_exists : bool = region.has_point(positionInput);
	return does_the_input_exists;

func is_point_solid(positionInput : Vector2i) -> bool:
	return mapa[positionInput.x][positionInput.y].is_solid;

func get_point_path(from_id: Vector2i, to_id: Vector2i) -> PackedVector2Array:
	var path : PackedVector2Array = PackedVector2Array();
	var closed_list : Array[HeuristicaData];
	var open_list : Array[HeuristicaData];
	var children : Array[HeuristicaData];
	var startNode = HeuristicaData.new();
	
	startNode.costo_F = 0;
	startNode.costo_G = 0;
	startNode.costo_H = 0;
	startNode.parent = null;
	startNode.posicion = from_id;
	
	open_list.append(startNode.duplicate());
	
	while open_list.size() > 0:
		var currentNodeData : HeuristicaData;
		var itemData : HeuristicaData;
		var currentIndex : int = 0;
		
		currentNodeData = open_list[0];
		
		for i in open_list.size():
			itemData = open_list[i];
			if itemData.costo_F < currentNodeData.costo_F:
				currentNodeData = itemData;
				currentIndex = i;
		# Técnicamente como todo se pasa por referencia a menos que se haga una copia con duplicate(),
		# al igualar objetos, mantienen referencia, osea currentNodeData tendrá la referencia de itemData,
		# quien en su lugar tenía la referencia de open_list[x], por lo que currentNodeData podría llegar
		# a ser tratado como el mismo item que uno dentro de la open_list[x].
		# lo menciono porque ahora viene la parte donde saco el item de la open_list para ponerlo en la close_list.
		# Esto podría llegar a dar problemas.
		closed_list.append(currentNodeData);
		open_list.remove_at(currentIndex);
		
		if currentNodeData.posicion == to_id:
			var currentPath : HeuristicaData = null;
			currentPath = closed_list[closed_list.size()-1];
			while currentPath.parent != null:
				path.append((currentPath.posicion * cell_size) + offset);
				currentPath = currentPath.parent;
			closed_list.clear();
			children.clear();
			open_list.clear();
			path.reverse(); # invierte el orden, el orden original empieza en el final y termina en el siguiente al principio
			return path.duplicate();
		
		var posicionesAlrededor : Array[Vector2i];
		posicionesAlrededor.append(Vector2i(-1, 0));
		posicionesAlrededor.append(Vector2i(-1,-1));
		posicionesAlrededor.append(Vector2i( 0,-1));
		posicionesAlrededor.append(Vector2i( 1,-1));
		posicionesAlrededor.append(Vector2i( 1, 0));
		posicionesAlrededor.append(Vector2i( 1, 1));
		posicionesAlrededor.append(Vector2i( 0, 1));
		posicionesAlrededor.append(Vector2i(-1, 1));
		
		for k in range(8):
			var newPosition : Vector2i;
			var newData = HeuristicaData.new();
			
			newPosition = currentNodeData.posicion + posicionesAlrededor[k];
			
			if not is_in_boundaries(newPosition):
				continue;
			if is_point_solid(newPosition):
				continue;
			if solid_on_diagonal_between_solids:
				if (k % 2) == 0:
					pass;
				else:
					if not is_in_boundaries(Vector2i(newPosition.x, newPosition.y - posicionesAlrededor[k].y)):
						continue;
					if not is_in_boundaries(Vector2i(newPosition.x - posicionesAlrededor[k].x, newPosition.y)):
						continue;
						
					var adyacent1 : bool = false;
					var adyacent2 : bool = false;
					
					adyacent1 = mapa[newPosition.x][newPosition.y - posicionesAlrededor[k].y].is_solid;
					adyacent2 = mapa[newPosition.x - posicionesAlrededor[k].x][newPosition.y].is_solid;
					
					if adyacent1 and adyacent2:
						continue;
						
			newData.posicion = newPosition;
			newData.parent = closed_list[closed_list.size()-1];
			
			if (k % 2) == 0:
				newData.costo_G = currentNodeData.costo_G + 10; # valores arbitrarios, ajustables
			else:
				newData.costo_G = currentNodeData.costo_G + 14; # valores arbitrarios, ajustables
			
			var distancia : Vector2i;
			var distancia_cuadrada : Vector2i;
			var hipotenusa_cuadrada : int;
			
			distancia = Vector2i((newData.posicion - to_id) * 2); # la multiplicación es arbitraria, ajustable
			distancia_cuadrada = distancia * distancia;
			hipotenusa_cuadrada = distancia_cuadrada.x + distancia_cuadrada.y;
			
			newData.costo_H = hipotenusa_cuadrada;
			newData.costo_F = newData.costo_G + newData.costo_H;
			
			children.append(newData.duplicate());
		
		var children_amount = children.size();
		var j : int = 0;
		while j < children_amount:
			var childOnClosedList : bool = false;
			var childOnOpenList : bool = false;
			var childOnOpenAndChildrenList : bool = false;
			
			childOnClosedList = false;
			childOnOpenList = false;
			childOnOpenAndChildrenList = false;
			
			for x in closed_list.size():
				if closed_list[x].posicion == children[j].posicion:
					childOnClosedList = true;
			if childOnClosedList:
				children.remove_at(j);
				#j = j - 1;
				children_amount = children.size();
				continue;
			
			for a in open_list.size():
				if open_list[a].posicion == children[j].posicion:
					if children[j].costo_G > open_list[a].costo_G:
						childOnOpenAndChildrenList = true; # llegué a la conclusión que no sirve de nada mantener children con mayor G vivos.
					elif children[j].costo_G < open_list[a].costo_G:
						# a ver si funciona bien esto acá, tengo que reemplazar al open por el child, y debería cambiar al open_list[?]
						open_list[a] = children[j];
						childOnOpenList = true;
					elif children[j].costo_G == open_list[a].costo_G:
						childOnOpenAndChildrenList = true;
					# por ahora omito la comparación por igual en caso que efectivamente sean el mismo objeto.
			if childOnOpenList:
				continue;
			if childOnOpenAndChildrenList:
				children.remove_at(j);
				#j = j - 1;
				children_amount = children.size();
				continue;
			
			open_list.append(children[j].duplicate());
			j += 1;
	
	print("No se pudo obtener camino");
	closed_list.clear();
	children.clear();
	open_list.clear();
	return path.duplicate();
