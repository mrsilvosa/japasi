extends Sprite2D

signal health_depleted
signal health_changed(old_value, new_value)
var health = 10

var speed = 400 # la velocidad del movimiento en píxeles por segundo
var angular_speed = PI # la velocidad angular en radianes por segundo

func _process(delta):
	rotation += angular_speed * delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta


func _on_button_pressed():
	set_process(not is_processing())

func _on_timer_timeout():
	visible = not visible

func _ready():
	var timer = get_node("Timer") # "Timer" es el nombre del nodo hijo.
	timer.timeout.connect(_on_timer_timeout)

func take_damage(amount):
	health -= amount
	if health <= 0:
		health_depleted.emit()

func take_damage2(amount):
	var old_health = health
	health -= amount
	health_changed.emit(old_health, health)
