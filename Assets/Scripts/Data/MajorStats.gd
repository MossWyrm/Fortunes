class_name MajorStats

var quantity: int = GameConfig.DEFAULT_MAJOR_QUANTITY
var magician: int = GameConfig.DEFAULT_MAJOR_MAGICIAN
var empress: int = GameConfig.DEFAULT_MAJOR_EMPRESS
var emperor: int = GameConfig.DEFAULT_MAJOR_EMPEROR
var lovers: int = GameConfig.DEFAULT_MAJOR_LOVERS
var wheel_multiplier: int = GameConfig.DEFAULT_MAJOR_WHEEL_MULTIPLIER
var wheel_charges: int = GameConfig.DEFAULT_MAJOR_WHEEL_CHARGES
var hanged_man: int = GameConfig.DEFAULT_MAJOR_HANGED_MAN # not currently implemented in upgrades
var temperance: int = GameConfig.DEFAULT_MAJOR_TEMPERANCE
var devil: int = GameConfig.DEFAULT_MAJOR_DEVIL # not currently implemented in upgrades
var tower: int = GameConfig.DEFAULT_MAJOR_TOWER
var star: int = GameConfig.DEFAULT_MAJOR_STAR
var moon: int = GameConfig.DEFAULT_MAJOR_MOON
var sun_star: int = GameConfig.DEFAULT_MAJOR_SUN_STAR
var sun_moon: int = GameConfig.DEFAULT_MAJOR_SUN_MOON
var judgement: int = GameConfig.DEFAULT_MAJOR_JUDGEMENT # not currently implemented in upgrades
var high_priestess: int = GameConfig.DEFAULT_MAJOR_HIGH_PRIESTESS # not currently implemented in upgrades
var hierophant: int = GameConfig.DEFAULT_MAJOR_HIEROPHANT # not currently implemented in upgrades
var strength: int = GameConfig.DEFAULT_MAJOR_STRENGTH # not currently implemented in upgrades
var justice: int = GameConfig.DEFAULT_MAJOR_JUSTICE # not currently implemented in upgrades
var death: int = 1 # not currently implemented in upgrades

func reset():
    quantity = GameConfig.DEFAULT_MAJOR_QUANTITY
    magician = GameConfig.DEFAULT_MAJOR_MAGICIAN
    empress = GameConfig.DEFAULT_MAJOR_EMPRESS
    emperor = GameConfig.DEFAULT_MAJOR_EMPEROR
    lovers = GameConfig.DEFAULT_MAJOR_LOVERS
    wheel_multiplier = GameConfig.DEFAULT_MAJOR_WHEEL_MULTIPLIER
    wheel_charges = GameConfig.DEFAULT_MAJOR_WHEEL_CHARGES
    hanged_man = GameConfig.DEFAULT_MAJOR_HANGED_MAN
    temperance = GameConfig.DEFAULT_MAJOR_TEMPERANCE
    devil = GameConfig.DEFAULT_MAJOR_DEVIL
    tower = GameConfig.DEFAULT_MAJOR_TOWER
    star = GameConfig.DEFAULT_MAJOR_STAR
    moon = GameConfig.DEFAULT_MAJOR_MOON
    sun_star = GameConfig.DEFAULT_MAJOR_SUN_STAR
    sun_moon = GameConfig.DEFAULT_MAJOR_SUN_MOON
    judgement = GameConfig.DEFAULT_MAJOR_JUDGEMENT
    high_priestess = GameConfig.DEFAULT_MAJOR_HIGH_PRIESTESS
    hierophant = GameConfig.DEFAULT_MAJOR_HIEROPHANT
    strength = GameConfig.DEFAULT_MAJOR_STRENGTH
    justice = GameConfig.DEFAULT_MAJOR_JUSTICE
    death = 1

func save() -> Dictionary:
    return {
        "quantity": quantity,
        "magician": magician,
        "empress": empress,
        "emperor": emperor,
        "lovers": lovers,
        "wheel_multiplier": wheel_multiplier,
        "wheel_charges": wheel_charges,
        "hanged_man": hanged_man,
        "temperance": temperance,
        "devil": devil,
        "tower": tower,
        "star": star,
        "moon": moon,
        "sun_star": sun_star,
        "sun_moon": sun_moon,
        "judgement": judgement,
        "high_priestess": high_priestess,
        "hierophant": hierophant,
        "strength": strength,
        "justice": justice,
        "death": death
    }

func load(data: Dictionary):
    if data.has("quantity"):
        quantity = data["quantity"]
    if data.has("magician"):
        magician = data["magician"]
    if data.has("empress"):
        empress = data["empress"]
    if data.has("emperor"):
        emperor = data["emperor"]
    if data.has("lovers"):
        lovers = data["lovers"]
    if data.has("wheel_multiplier"):
        wheel_multiplier = data["wheel_multiplier"]
    if data.has("wheel_charges"):
        wheel_charges = data["wheel_charges"]
    if data.has("hanged_man"):
        hanged_man = data["hanged_man"]
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
    if data.has("sun_star"):
        sun_star = data["sun_star"]
    if data.has("sun_moon"):
        sun_moon = data["sun_moon"]
    if data.has("judgement"):
        judgement = data["judgement"]
    if data.has("high_priestess"):
        high_priestess = data["high_priestess"]
    if data.has("hierophant"):
        hierophant = data["hierophant"]
    if data.has("strength"):
        strength = data["strength"]
    if data.has("justice"):
        justice = data["justice"]
    if data.has("death"):
        death = data["death"] 