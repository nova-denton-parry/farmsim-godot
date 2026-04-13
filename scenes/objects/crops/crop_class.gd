class_name Crop
extends Node2D

@export var harvest_scene: PackedScene

@export var sprite_2d: Sprite2D
@export var watering_particles: GPUParticles2D
@export var flowering_particles: GPUParticles2D
@export var growth_cycle_component: GrowthCycleComponent
@export var hurt_component: HurtComponent
@export var unwatered_sprite: Texture2D
@export var watered_sprite: Texture2D

var is_mature: bool = false


func _ready() -> void:
	watering_particles.emitting = false
	flowering_particles.emitting = false
	
	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.crop_maturity.connect(on_crop_maturity)
	growth_cycle_component.reset_watering.connect(on_watering_reset)
	
	add_to_group("crops")


func _process(_delta: float) -> void:
	var growth_state = growth_cycle_component.get_current_growth_state()
	sprite_2d.frame = growth_state - 1
	
	if growth_state > 2:
		z_index = 1		# allow normal y-sort behavior
	
	if growth_state == growth_cycle_component.total_growth_states:
		flowering_particles.emitting = true


func on_hurt(_hit_damage: int, _sprite: AnimatedSprite2D) -> void:
	if !growth_cycle_component.is_watered && growth_cycle_component.current_growth_state != growth_cycle_component.total_growth_states:
		watering_particles.emitting = true
		growth_cycle_component.is_watered = true # set before timer times out
		sprite_2d.texture = watered_sprite
		await get_tree().create_timer(3.0).timeout
		watering_particles.emitting = false


func on_crop_maturity() -> void:
	flowering_particles.emitting = true
	is_mature = true


func on_watering_reset() -> void:
	sprite_2d.texture = unwatered_sprite


func set_watered(watered: bool) -> void:
	growth_cycle_component.is_watered = watered
	if watered:
		sprite_2d.texture = watered_sprite
	else:
		sprite_2d.texture = unwatered_sprite
