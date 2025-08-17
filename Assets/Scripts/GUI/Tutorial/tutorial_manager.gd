extends Node
class_name TutorialManager
## Tutorial system manager
##
## Manages the tutorial flow and progression for new players.
## Checks tutorial completion status and handles tutorial logic.

#region Initialization
func _ready() -> void:
	_check_tutorial_status()

# Check if tutorial should be started or skipped
func _check_tutorial_status() -> void:
	if _is_tutorial_complete():
		_skip_tutorial()
	else:
		_start_tutorial()

# Check if the tutorial has been completed
func _is_tutorial_complete() -> bool:
	if ValidationUtils.has_stats():
		return GameManager.game_state.stats.tutorial_complete
	return false
#endregion

#region Tutorial Flow
# Start the tutorial sequence
func _start_tutorial() -> void:
	# TODO: Implement tutorial start logic
	print("TutorialManager: Starting tutorial")

# Skip tutorial for returning players
func _skip_tutorial() -> void:
	print("TutorialManager: Tutorial already completed, skipping")

# Mark tutorial as complete
func complete_tutorial() -> void:
	if ValidationUtils.has_stats():
		GameManager.game_state.stats.tutorial_complete = true
		print("TutorialManager: Tutorial marked as complete")
#endregion