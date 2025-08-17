extends Node
class_name DisplayStateManager

# References to calculators (set after game initialization)
var major_calculator: MajorCalculator
var cup_calculator: CupCalculator
var wand_calculator: WandCalculator
var sword_calculator: SwordCalculator
var pentacle_calculator: PentacleCalculator

func _ready():
    # Listen for game initialization and wire up calculators when ready
    GameManager.game_state.event_bus.game_initialized.connect(_on_game_initialized)

func _on_game_initialized():
    var card_calculator = GameManager.game_state.card_calculator
    if card_calculator:
        card_calculator.set_display_state_manager(self)

func get_full_display_state() -> Dictionary:
    return {
        "majors": major_calculator.get_display_state(),
        "cups": cup_calculator.get_display_state(),
        "wands": wand_calculator.get_display_state(),
        "swords": sword_calculator.get_display_state(),
        "pentacles": pentacle_calculator.get_display_state(),
    }

func update_display_states(display_data: Dictionary) -> void:
    for suit in display_data.keys():
        GameManager.game_state.event_bus.emit_suit_display_updated(suit, display_data[suit])