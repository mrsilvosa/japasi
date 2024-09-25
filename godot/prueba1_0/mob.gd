extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Lista de nombres de animaciones:
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	# [randi() % n ] -> random integer from 0 and n-1
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	# mobs delete themselves when they leave the screen:
	queue_free()
