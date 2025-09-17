class_name MajorStats

var quantity_per_card: int = GameConfig.DEFAULT_MAJOR_QUANTITY_PER_CARD
var quantity_per_deck: int = GameConfig.DEFAULT_MAJOR_QUANTITY_PER_DECK

# Major Arcana Stats in Traditional Order (0-20)
var magician: int = GameConfig.DEFAULT_MAJOR_MAGICIAN
var high_priestess: int = GameConfig.DEFAULT_MAJOR_HIGH_PRIESTESS # not currently implemented in upgrades
var empress: int = GameConfig.DEFAULT_MAJOR_EMPRESS
var emperor: int = GameConfig.DEFAULT_MAJOR_EMPEROR
var hierophant: int = GameConfig.DEFAULT_MAJOR_HIEROPHANT # not currently implemented in upgrades
var lovers: int = GameConfig.DEFAULT_MAJOR_LOVERS
var strength: int = GameConfig.DEFAULT_MAJOR_STRENGTH # not currently implemented in upgrades
var wheel_multiplier: int = GameConfig.DEFAULT_MAJOR_WHEEL_MULTIPLIER
var wheel_charges: int = GameConfig.DEFAULT_MAJOR_WHEEL_CHARGES
var justice: int = GameConfig.DEFAULT_MAJOR_JUSTICE # not currently implemented in upgrades
var hanged_man: int = GameConfig.DEFAULT_MAJOR_HANGED_MAN # not currently implemented in upgrades
var death: int = GameConfig.DEFAULT_MAJOR_DEATH
var temperance: int = GameConfig.DEFAULT_MAJOR_TEMPERANCE
var devil: int = GameConfig.DEFAULT_MAJOR_DEVIL # not currently implemented in upgrades
var tower: int = GameConfig.DEFAULT_MAJOR_TOWER # not currently implemented in upgrades
var star: int = GameConfig.DEFAULT_MAJOR_STAR
var moon: int = GameConfig.DEFAULT_MAJOR_MOON
var moon_exponent: int = GameConfig.DEFAULT_MAJOR_MOON_EXPONENT # not currently implemented in upgrades
var sun_star: int = GameConfig.DEFAULT_MAJOR_SUN_STAR
var sun_moon: int = GameConfig.DEFAULT_MAJOR_SUN_MOON
var sun_exponent: int = GameConfig.DEFAULT_MAJOR_SUN_EXPONENT # not currently implemented in upgrades
var judgement: int = GameConfig.DEFAULT_MAJOR_JUDGEMENT # not currently implemented in upgrades

func reset():
    quantity_per_card = GameConfig.DEFAULT_MAJOR_QUANTITY_PER_CARD
    quantity_per_deck = GameConfig.DEFAULT_MAJOR_QUANTITY_PER_DECK
    # Reset in Major Arcana order
    magician = GameConfig.DEFAULT_MAJOR_MAGICIAN
    high_priestess = GameConfig.DEFAULT_MAJOR_HIGH_PRIESTESS
    empress = GameConfig.DEFAULT_MAJOR_EMPRESS
    emperor = GameConfig.DEFAULT_MAJOR_EMPEROR
    hierophant = GameConfig.DEFAULT_MAJOR_HIEROPHANT
    lovers = GameConfig.DEFAULT_MAJOR_LOVERS
    strength = GameConfig.DEFAULT_MAJOR_STRENGTH
    wheel_multiplier = GameConfig.DEFAULT_MAJOR_WHEEL_MULTIPLIER
    wheel_charges = GameConfig.DEFAULT_MAJOR_WHEEL_CHARGES
    justice = GameConfig.DEFAULT_MAJOR_JUSTICE
    hanged_man = GameConfig.DEFAULT_MAJOR_HANGED_MAN
    death = GameConfig.DEFAULT_MAJOR_DEATH
    temperance = GameConfig.DEFAULT_MAJOR_TEMPERANCE
    devil = GameConfig.DEFAULT_MAJOR_DEVIL
    tower = GameConfig.DEFAULT_MAJOR_TOWER
    star = GameConfig.DEFAULT_MAJOR_STAR
    moon = GameConfig.DEFAULT_MAJOR_MOON
    moon_exponent = GameConfig.DEFAULT_MAJOR_MOON_EXPONENT
    sun_star = GameConfig.DEFAULT_MAJOR_SUN_STAR
    sun_moon = GameConfig.DEFAULT_MAJOR_SUN_MOON
    sun_exponent = GameConfig.DEFAULT_MAJOR_SUN_EXPONENT
    judgement = GameConfig.DEFAULT_MAJOR_JUDGEMENT

func save() -> Dictionary:
    return {
        "quantity_per_card": quantity_per_card,
        "quantity_per_deck": quantity_per_deck,
        # Save in Major Arcana order
        "magician": magician,
        "high_priestess": high_priestess,
        "empress": empress,
        "emperor": emperor,
        "hierophant": hierophant,
        "lovers": lovers,
        "strength": strength,
        "wheel_multiplier": wheel_multiplier,
        "wheel_charges": wheel_charges,
        "justice": justice,
        "hanged_man": hanged_man,
        "death": death,
        "temperance": temperance,
        "devil": devil,
        "tower": tower,
        "star": star,
        "moon": moon,
        "moon_exponent": moon_exponent,
        "sun_star": sun_star,
        "sun_moon": sun_moon,
        "sun_exponent": sun_exponent,
        "judgement": judgement
    }

func load(data: Dictionary):
    if data.has("quantity_per_card"):
        quantity_per_card = data["quantity_per_card"]
    if data.has("quantity_per_deck"):
        quantity_per_deck = data["quantity_per_deck"]
    # Load in Major Arcana order
    if data.has("magician"):
        magician = data["magician"]
    if data.has("high_priestess"):
        high_priestess = data["high_priestess"]
    if data.has("empress"):
        empress = data["empress"]
    if data.has("emperor"):
        emperor = data["emperor"]
    if data.has("hierophant"):
        hierophant = data["hierophant"]
    if data.has("lovers"):
        lovers = data["lovers"]
    if data.has("strength"):
        strength = data["strength"]
    if data.has("wheel_multiplier"):
        wheel_multiplier = data["wheel_multiplier"]
    if data.has("wheel_charges"):
        wheel_charges = data["wheel_charges"]
    if data.has("justice"):
        justice = data["justice"]
    if data.has("hanged_man"):
        hanged_man = data["hanged_man"]
    if data.has("death"):
        death = data["death"]
    if data.has("temperance"):
        temperance = data["temperance"]
    if data.has("devil"):
        devil = data["devil"]
    if data.has("tower"):
        tower = data["tower"]
    if data.has("star"):
        star = data["star"]
    if data.has("moon"):
        moon = data["moon"]
    if data.has("moon_exponent"):
        moon_exponent = data["moon_exponent"]
    if data.has("sun_star"):
        sun_star = data["sun_star"]
    if data.has("sun_moon"):
        sun_moon = data["sun_moon"]
    if data.has("sun_exponent"):
        sun_exponent = data["sun_exponent"]
    if data.has("judgement"):
        judgement = data["judgement"] 