extends Node
class_name BaseAilment

## Base class for all patient ailments.
## See docs/ailment-template/ for the full guide.
## Extend this, drop your scene in res://ailments/your_ailment/, done.

enum TreatmentResult {
	SUCCESS,
	FAIL,
	CRITICAL_FAIL,
}

func get_display_name() -> String:
	push_error("get_display_name() not implemented")
	return "Unnamed Ailment"

func get_severity() -> int:
	# 1 = low, 2 = medium, 3 = high
	return 1

func on_treatment_step(tool: String) -> TreatmentResult:
	push_error("on_treatment_step() not implemented")
	return TreatmentResult.FAIL

func get_tip_modifier() -> float:
	# multiplier applied to the final tip, 0.0 - 1.5
	return 1.0
