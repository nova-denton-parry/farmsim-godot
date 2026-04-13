extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var interactable_component: InteractableComponent = $InteractableComponent

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	collision_layer = 2		#ensure starting with expected collision layer
	# TODO change collision update to change shape, rather than changing layers to
	#	maintain collision with walls on either side of door
	
func on_interactable_activated() -> void:
	animated_sprite_2d.play("open_door")
	collision_layer = 1		# change to same layer as player to remove collision
	print("activated")

func on_interactable_deactivated() -> void:
	animated_sprite_2d.play("close_door")
	collision_layer = 2		# return to normal collision layer
	print("deactivated")
