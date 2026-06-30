extends Node
class_name BaseEvent

## Base class for traffic/world events (red light running, siren response, etc).
## Extend this, drop your scene in res://events/your_event/, done.

func get_display_name() -> String:
	return "Unnamed Event"

func on_trigger() -> void:
	push_error("on_trigger() not implemented")
