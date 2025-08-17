


extends BaseCalculator
class_name MajorCalculator

# === Variables ===
var major_effects: Dictionary = {}

# === Godot Lifecycle ===
func _ready():
    _init_effects()

# === Initialization ===
func _init_effects():
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
    if major_effects.has(card.value):
        await get_major_effect(card.value).apply(card, flipped)
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
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).active()

func wheel_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.WHEEL_OF_FORTUNE).get_value(value)

func temperance_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).active()

func temperance_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TEMPERANCE).get_value(value)

func devil_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).active()

func devil_use() -> void:
    get_major_effect(DataStructures.MAJOR_ID.DEVIL).use()

func devil_forced() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.DEVIL).forced()

func tower_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).active()

func tower_value(value:int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.TOWER).get_value(value)

func star_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).active()

func star_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.STAR).get_value(value)

func judgement_active() -> bool:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).active()

func judgement_value(value: int) -> int:
    return get_major_effect(DataStructures.MAJOR_ID.JUDGEMENT).get_value(value)