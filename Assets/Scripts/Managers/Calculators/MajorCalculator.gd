extends BaseCalculator
class_name MajorCalculator

# === Variables ===
var major_effects: Dictionary = {}

# === Godot Lifecycle ===
# Override BaseCalculator to initialize effects when game_state is available
func set_game_state(state: GameState):
    super.set_game_state(state)  # Call parent implementation
    _init_effects()  # Now initialize effects with valid game_state

# === Initialization ===
func _init_effects():
    # Only initialize if we have a valid game_state
    if not game_state:
        push_error("MajorCalculator: Cannot initialize effects without game_state")
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

# === Calculation ===
func calculate_base_value(_card: Card, _flipped: bool) -> int:
    # Major Arcana typically have no base value
    return 0

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    var major_id = card.id - GameConstants.MAJOR_CARD_THRESHOLD - 1
    if major_effects.has(major_id):
        await get_major_effect(major_id).apply(card, flipped)
    return base_value

# === Effect Accessors ===
func get_major_effect(major_id: int) -> MajorEffectBase:
    return major_effects.get(major_id, null)

# === Bulk Operations ===
func shuffle(safely: bool = false):
    for effect in major_effects.values():
        effect.shuffle(safely)

func get_display_state() -> Dictionary:
    var display = {}
    for id in major_effects.keys():
        var effect = major_effects[id]
        if effect.has_method("is_active") and effect.is_active():
            if effect.has_method("get_display_data"):
                display[id] = effect.get_display_data()
    DebugManager.print_ui_displays("UpdateSuitDisplays: Getting display state: %s"%[display], DebugManager.DebugLevel.INFO)
    return display

# === State Management ===
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

# === Effect Shortcuts ===
func empress_value() -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPRESS).get_value()

func empress_update(value) -> void:
    get_major_effect(DataStructures.MAJOR_ID.EMPRESS).update(value)

func emperor_value() -> int:
    return get_major_effect(DataStructures.MAJOR_ID.EMPEROR).get_value()

func chariot_update(value) -> void:
    get_major_effect(DataStructures.MAJOR_ID.CHARIOT).update(value)

func wheel_update(suit: DataStructures.SuitType) -> void:
    get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).update(suit)

func wheel_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).is_active()

func wheel_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).get_value(value)

func temperance_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).is_active()

func temperance_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).get_value(value)

func devil_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).is_active()

func devil_use() -> void:
    get_major_effect(DataStructures.MAJOR_ID.DEVIL).use()

func devil_forced() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).forced()

func tower_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).is_active()

func tower_value(value:int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).get_value(value)

func star_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).is_active()

func star_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).get_value(value)

func judgement_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).is_active()

func judgement_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).get_value(value)