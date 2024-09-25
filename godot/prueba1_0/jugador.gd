extends Area2D

signal hit

# 	@export keyword permite setear su valor desde el inspector
@export var rapidez = 400 # Qué tan rápido se moverá el jugador (pixels/sec).
var pantalla_size # Tamaño de la ventana del juego.


# Called when the node enters the scene tree for the first time.
func _ready():
	pantalla_size = get_viewport_rect().size
	
	hide() # oculta al jugador al principio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocidad = Vector2.ZERO # Vector de movimiento del jugador.
	if Input.is_action_pressed("moverse_derecha"):
		velocidad.x += 1
	if Input.is_action_pressed("moverse_izquierda"):
		velocidad.x -= 1
	if Input.is_action_pressed("moverse_abajo"):
		velocidad.y += 1
	if Input.is_action_pressed("moverse_arriba"):
		velocidad.y -= 1

	if velocidad.length() > 0:
		velocidad = velocidad.normalized() * rapidez
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	# $ is shorthand for get_node().
	# So in the code above, $AnimatedSprite2D.play() is the same as get_node("AnimatedSprite2D").play().
	
	position += velocidad * delta
	position = position.clamp(Vector2.ZERO, pantalla_size)
	
	if velocidad.x != 0:
		$AnimatedSprite2D.animation = "caminar"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocidad.x < 0
	elif velocidad.y != 0:
		$AnimatedSprite2D.animation = "arriba"
		$AnimatedSprite2D.flip_v = velocidad.y > 0
		

func _on_body_entered(body: Node2D):
	hide() # El jugador desaparece tras ser tocado.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	# Básicamente se desactiva la señal para que no vuelva a suceder estando oculto.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show() # muestra al jugador
	$CollisionShape2D.disabled = false
