extends Control
class_name DeckCreatorCardBox

## Card selection display box
## Shows either a locked or unlocked card display based on card state

@export var locked_display: DeckCreatorCardBoxLocked
@export var unlocked_display: DeckCreatorCardBoxUnlocked

var can_add: bool = true
var can_remove: bool = true
var gesture_detector: TouchGestureDetector = TouchGestureDetector.new()
var current_deck_creator: DeckCreator
var current_card_id: int

func update_display(data: DeckCreatorDisplayData, deck_creator: DeckCreator) -> void:
	# Store references for tooltip handling
	current_deck_creator = deck_creator
	current_card_id = data.card_id
	
	if data.is_unlocked:
		_display_unlocked(data, deck_creator)
	else:
		_display_locked(data, deck_creator)

func _display_unlocked(data: DeckCreatorDisplayData, deck_creator: DeckCreator):
	locked_display.hide()
	unlocked_display.show()
	unlocked_display.update(data, deck_creator)

func _display_locked(data: DeckCreatorDisplayData, deck_creator: DeckCreator):
	locked_display.show()
	unlocked_display.hide()
	locked_display.update(data, deck_creator)

# Handle card face input for tooltips using gesture detection
func _on_card_face_gui_input(event: InputEvent) -> void:
	var result = gesture_detector.process_input(event)
	match result.gesture_type:
		TouchGestureDetector.GestureResult.GestureType.TAP_COMPLETED:
			# Show tooltip on tap completion
			if current_deck_creator and current_card_id > 0:
				current_deck_creator.show_card_tooltip(current_card_id)
		TouchGestureDetector.GestureResult.GestureType.DRAG_COMPLETED:
			# Was scrolling - don't show tooltip
			pass