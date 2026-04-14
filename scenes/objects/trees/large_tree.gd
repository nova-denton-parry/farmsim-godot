extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent 

@export var log_scene: PackedScene

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damage_reached.connect(on_max_damage_reached)
	
	add_to_group("trees")

func on_hurt(hit_damage: int, sprite: AnimatedSprite2D) -> void:
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("shake_intensity", 1.5)
	await sprite.animation_finished
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.0)


func on_max_damage_reached() -> void:
	call_deferred("add_log_scenes")
	queue_free()


func add_log_scenes() -> void:
	var log_instance_1 = log_scene.instantiate() as Node2D
	var log_instance_2 = log_scene.instantiate() as Node2D
	var log_instance_3 = log_scene.instantiate() as Node2D
	var rng = RandomNumberGenerator.new()
	log_instance_1.global_position = global_position
	get_parent().add_child(log_instance_1)
	log_instance_2.global_position = global_position + Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))
	get_parent().add_child(log_instance_2)
	log_instance_3.global_position = global_position + Vector2(rng.randi_range(-10, 10), rng.randi_range(-10, 10))
	get_parent().add_child(log_instance_3)
