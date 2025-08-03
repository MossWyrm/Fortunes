class_name MajorStats

var quantity: int = 1
var magician: int = 5
var empress: int = 1
var emperor: int = 1
var lovers: int = 4
var wheel_multiplier: int = 2
var wheel_charges: int = 5
var hanged_man: int = 2
var temperance: int = 100
var devil: int = 3
var star: int = 5
var moon: int = 2
var sun_star: int = 10
var sun_moon: int = 3
var judgement: int = 10
var high_priestess: int = 3
var hierophant: int = 2
var strength: int = 5
var justice: int = 1
var death: int = 1

func reset():
    quantity = 1
    magician = 5
    empress = 1
    emperor = 1
    lovers = 4
    wheel_multiplier = 2
    wheel_charges = 5
    hanged_man = 2
    temperance = 100
    devil = 3
    star = 5
    moon = 2
    sun_star = 10
    sun_moon = 3
    judgement = 10
    high_priestess = 3
    hierophant = 2
    strength = 5
    justice = 1
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