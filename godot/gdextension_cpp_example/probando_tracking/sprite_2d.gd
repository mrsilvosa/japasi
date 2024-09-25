extends Sprite2D
'''
La palabra clave func define una nueva función llamada _init. 
Este es un nombre especial para el constructor de nuestra clase. 
El motor llama a _init() en cada objeto o nodo al crearlo en la memoria, si define esta función.
'''
#func _init():
#	print("¡Hola mundo 2!")
# continuaremos sin esta prueba

var speed = 400 # la velocidad del movimiento en píxeles por segundo
var angular_speed = PI # la velocidad angular en radianes por segundo

func _process(delta):# Los dos puntos (:) terminan la definición.
	#rotation += angular_speed * delta 
	#cambiamos de forma:
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1
	'''
	Puede ver y editar acciones de entrada en su proyecto
	yendo a Proyecto -> Configuración del proyecto y haciendo clic en la pestaña Mapa de entrada.
	'''
	rotation += angular_speed * direction * delta
	##var velocity = Vector2.UP.rotated(rotation) * speed
	# Vector2.UP = constante de clase : Vector2(0, -1)
	# rotated() = método de clase
	##position += velocity * delta
	## usaremos otra manera:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta
'''
Por convención, las funciones virtuales de Godot, es decir, las funciones
integradas que puede anular para comunicarse con el motor, comienzan con un guión bajo.
'''
