extends Node
class_name CardDescription

## CardDescriptions autoload - provides card description functionality
## Routes to the new modular BaseCardDescription system

static func get_description(card: Card, bb_formatted = false) -> Dictionary:
	return CardDescriptionFactory.get_description(card, bb_formatted)