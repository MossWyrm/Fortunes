extends Control
class_name DeckCreatorCardBox

## Card selection display box
## Shows either a locked or unlocked card display based on card state

@export var locked_display: DeckCreatorCardBoxLocked
@export var unlocked_display: DeckCreatorCardBoxUnlocked

var can_add: bool = true
var can_remove: bool = true

func update_display(data: DeckCreatorDisplayData, deck_creator: DeckCreator) -> void:
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