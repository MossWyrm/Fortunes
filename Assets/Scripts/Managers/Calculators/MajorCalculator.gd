extends BaseCalculator
class_name MajorCalculator

var major_effects: Dictionary = {}

# Override BaseCalculator to initialize effects when game_state is available
func set_game_state(state: GameState):
    super.set_game_state(state)  # Call parent implementation
    _init_effects()  # Now initialize effects with valid game_state

func _init_effects():
    # Only initialize if we have a valid game_state
    if not game_state:
        DebugManager.print_game_state("MajorCalculator: Cannot initialize effects without game_state", DebugManager.DebugLevel.ERROR)
        return
        
    major_effects = {
        DataStructures.MAJOR_ID.FOOL: FoolEffect.new(game_state),
        DataStructures.MAJOR_ID.MAGICIAN: MagicianEffect.new(game_state),
        DataStructures.MAJOR_ID.HIGH_PRIESTESS: HighPriestessEffect.new(game_state),
        DataStructures.MAJOR_ID.EMPRESS: EmpressEffect.new(game_state),
        DataStructures.MAJOR_ID.EMPEROR: EmperorEffect.new(game_state),
        DataStructures.MAJOR_ID.HIEROPHANT: HierophantEffect.new(game_state),
        DataStructures.MAJOR_ID.LOVERS: LoversEffect.new(game_state),
        DataStructures.MAJOR_ID.CHARIOT: ChariotEffect.new(game_state),
        DataStructures.MAJOR_ID.STRENGTH: StrengthEffect.new(game_state),
        DataStructures.MAJOR_ID.HERMIT: HermitEffect.new(game_state),
        DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE: WheelOfFortuneEffect.new(game_state),
        DataStructures.MAJOR_ID.JUSTICE: JusticeEffect.new(game_state),
        DataStructures.MAJOR_ID.HANGED_MAN: HangedManEffect.new(game_state),
        DataStructures.MAJOR_ID.DEATH: DeathEffect.new(game_state),
        DataStructures.MAJOR_ID.TEMPERANCE: TemperanceEffect.new(game_state),
        DataStructures.MAJOR_ID.DEVIL: DevilEffect.new(game_state),
        DataStructures.MAJOR_ID.TOWER: TowerEffect.new(game_state),
        DataStructures.MAJOR_ID.STAR: StarEffect.new(game_state),
        DataStructures.MAJOR_ID.MOON: MoonEffect.new(game_state),
        DataStructures.MAJOR_ID.SUN: SunEffect.new(game_state),
        DataStructures.MAJOR_ID.JUDGEMENT: JudgementEffect.new(game_state)
    }

#region Calculation Overrides
func calculate_base_value(_card: Card, _flipped: bool) -> int:
    # Major Arcana typically have no base value
    return 0

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    var major_id = card.id - GameConstants.MAJOR_CARD_THRESHOLD - 1
    if major_effects.has(major_id):
        # Some apply() methods are async (Wheel, Hanged Man, Magician), others are not
        # Using await to handle both cases gracefully
        await get_major_effect(major_id).apply(card, flipped)

    var result = base_value
    # Apply arcana synergy multiplier if available
    if game_state and game_state.stats:
        result = int(result * game_state.stats.arcana_synergy_multiplier)
        DebugManager.print_card_effects("MajorCalculator: Arcana synergy multiplier applied - base: %d, arcana_synergy: %.3f, final: %d" % [base_value, game_state.stats.arcana_synergy_multiplier, result], DebugManager.DebugLevel.VERBOSE)
    return result
#endregion

#region Public Methods
#accessor for individual major effects
func get_major_effect(major_id: int) -> MajorEffectBase:
    return major_effects.get(major_id, null)

# Shuffle all major effects that require shuffling
func shuffle(safely: bool = false):
    for effect in major_effects.values():
        effect.shuffle(safely)

# Get display state for all major effects
func get_display_state() -> Dictionary:
    var display = {}
    for id in major_effects.keys():
        var effect = major_effects[id]
        if effect.has_method("get_display_data"):
            display[id] = effect.get_display_data()
    return display

# Returns all major effects for bulk operations (used by Death)
func get_all_effects() -> Array:
    return major_effects.values()
#endregion

#region Major Effect Accessors
func is_high_priestess_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.HIGH_PRIESTESS).is_active()

func get_high_priestess_cards() -> Array[Card]:
    return get_major_effect(DataStructures.MAJOR_ID.HIGH_PRIESTESS).use()

func is_high_priestess_forced() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.HIGH_PRIESTESS).forced()

func is_empress_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.EMPRESS).is_active()

func get_empress_display() -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPRESS).get_value()

func get_empress_bonus(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPRESS).modify_card_value(value)

func update_empress(value) -> void:
    get_major_effect(DataStructures.MAJOR_ID.EMPRESS).update(value)

func get_emperor_display() -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPEROR).get_value()

func get_emperor_bonus() -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPEROR).get_value()

func is_hierophant_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.HIEROPHANT).is_active()

func apply_hierophant_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.HIEROPHANT).modify_card_value(value)

func is_hanged_man_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.HANGED_MAN).is_hanged_man_active()

func apply_hanged_man_to_base_value(card: Card, base_value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.HANGED_MAN).apply_hanged_man_to_base_value(card, base_value)

func update_chariot(value) -> void:
    get_major_effect(DataStructures.MAJOR_ID.CHARIOT).update(value)

func update_wheel(suit: DataStructures.SuitType) -> void:
    get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).update(suit)

func is_wheel_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).is_active()

func apply_wheel_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).modify_card_value(value)

func update_justice(card: Card, value: int) -> void:
    get_major_effect(DataStructures.MAJOR_ID.JUSTICE).update_karma(card, value)

func update_death(value: int) -> void:
    get_major_effect(DataStructures.MAJOR_ID.DEATH).update_average(value)
    
func is_temperance_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).is_active()

func apply_temperance_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).apply_temperance_to_card(value)

func is_devil_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).is_active()

func trigger_devil() -> void:
    get_major_effect(DataStructures.MAJOR_ID.DEVIL).use()

func is_devil_forced() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).forced()

func is_tower_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).is_active()

func apply_tower_to_card(value:int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).apply_tower_to_card(value)

func is_star_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).is_active()

func apply_star_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).apply_star_to_card(value)

func is_judgement_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).is_active()

func apply_judgement_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).modify_card_value(value)

func update_judgement(card: Card) -> void:
    get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).update_uniques(card)

func is_strength_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.STRENGTH).is_active()

func apply_strength_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.STRENGTH).modify_card_value(value)

func update_strength(_value: int) -> void:
    get_major_effect(DataStructures.MAJOR_ID.STRENGTH).update(_value)

func update_hermit(card: Card) -> void:
    get_major_effect(DataStructures.MAJOR_ID.HERMIT).update_hermit(card)

func is_hermit_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.HERMIT).is_active()

func apply_hermit_to_card(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.HERMIT).modify_card_value(value)
#endregion

#region State Backup
# Create a backup of the current state of all major effects
func get_state_backup() -> Dictionary:
    var backup = {}
    for id in major_effects.keys():
        var effect = major_effects[id]
        if effect.has_method("get_state_backup"):
            backup[id] = effect.get_state_backup()
    return backup

func restore_state_backup(backup: Dictionary):
    for id in backup.keys():
        if major_effects.has(id):
            var effect = major_effects[id]
            if effect.has_method("restore_state_backup"):
                effect.restore_state_backup(backup[id])
#endregion