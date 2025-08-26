extends RefCounted
class_name TouchGestureDetector

## Touch Gesture Detection Utility
## Distinguishes between intentional taps and scroll gestures for mobile-friendly UI

#region Gesture Detection State
var initial_touch_position: Vector2
var has_moved_significantly: bool = false
var movement_threshold: float = 20.0  # Pixels of movement to consider it a scroll
var is_tracking: bool = false
#endregion

#region Configuration
## Set the movement threshold (pixels) for distinguishing taps from drags
func set_movement_threshold(threshold: float) -> void:
	movement_threshold = threshold
#endregion

#region Gesture Processing
## Call this with input events to track gestures
## Returns a GestureResult indicating what type of gesture occurred
func process_input(event: InputEvent) -> GestureResult:
	var result = GestureResult.new()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Touch/click started
			_start_tracking(event.position)
			result.gesture_type = GestureResult.GestureType.TOUCH_STARTED
			result.position = event.position
		else:
			# Touch/click released
			if is_tracking:
				_stop_tracking()
				if has_moved_significantly:
					result.gesture_type = GestureResult.GestureType.DRAG_COMPLETED
				else:
					result.gesture_type = GestureResult.GestureType.TAP_COMPLETED
				result.position = event.position
				result.was_intentional_tap = not has_moved_significantly
	
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if is_tracking:
			_update_movement(event.position)
			if has_moved_significantly:
				result.gesture_type = GestureResult.GestureType.DRAGGING
				result.position = event.position
	
	return result

## Check if current gesture is an intentional tap (not a drag/scroll)
func is_intentional_tap() -> bool:
	return is_tracking and not has_moved_significantly

## Check if significant movement has been detected
func is_dragging() -> bool:
	return is_tracking and has_moved_significantly
#endregion

#region Private Methods
func _start_tracking(position: Vector2) -> void:
	initial_touch_position = position
	has_moved_significantly = false
	is_tracking = true

func _update_movement(current_position: Vector2) -> void:
	if not is_tracking:
		return
		
	var distance = current_position.distance_to(initial_touch_position)
	if distance > movement_threshold:
		has_moved_significantly = true

func _stop_tracking() -> void:
	is_tracking = false
#endregion

#region Result Class
## Result object returned by gesture detection
class GestureResult:
	enum GestureType {
		NONE,
		TOUCH_STARTED,
		TAP_COMPLETED,
		DRAG_COMPLETED,
		DRAGGING
	}
	
	var gesture_type: GestureType = GestureType.NONE
	var position: Vector2 = Vector2.ZERO
	var was_intentional_tap: bool = false
#endregion
