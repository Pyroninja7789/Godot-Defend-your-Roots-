extends CanvasLayer

@onready var label: Label = $Control/Label

@onready var player: CharacterBody3D = $".."

func _process(delta: float) -> void:
	label.text = str(player.health)
	
