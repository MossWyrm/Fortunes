extends Control
class_name DeckCreatorCardBoxList

### Manages a list of DeckCreatorCardBox instances

@export var displays_list: Array[DeckCreatorCardBox]

func size() -> int:
	return displays_list.size()

func get_display(index: int) -> DeckCreatorCardBox:
	if index >= 0 and index < displays_list.size():
		return displays_list[index]
	return null

func add_display(display: DeckCreatorCardBox) -> void:
	if display and display not in displays_list:
		displays_list.append(display)

func remove_display(display: DeckCreatorCardBox) -> void:
	displays_list.erase(display)

func clear_displays() -> void:
	displays_list.clear()
