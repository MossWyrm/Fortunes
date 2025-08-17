extends Node
# 🎉 CELEBRATION FIREWORKS SCRIPT 🎉
# A fun little script to commemorate the epic refactoring!

class_name CelebrationFireworks

@export var firework_colors: Array[Color] = [
	Color.GOLD,
	Color.MAGENTA, 
	Color.CYAN,
	Color.LIME,
	Color.ORANGE_RED,
	Color.DEEP_PINK
]

# Celebrate the legendary refactoring achievement!
func launch_victory_fireworks():
	print("🎆 LAUNCHING CELEBRATION FIREWORKS! 🎆")
	
	for i in range(7):  # Lucky number 7!
		var color = firework_colors[i % firework_colors.size()]
		_create_firework_burst(color, i)
		await get_tree().create_timer(0.3).timeout
	
	print("🏆 REFACTORING MASTERY CELEBRATION COMPLETE! 🏆")

func _create_firework_burst(color: Color, burst_number: int):
	var celebration_messages = [
		"✨ ValidationUtils protecting the realm!",
		"🔗 SignalManager banishing memory leaks!",
		"💎 GameConstants bringing divine order!",
		"📝 DescriptionFormatter unifying all text!",
		"🛡️ 15+ files now blessed with safety!",
		"🌟 Code quality ascended to legendary tier!",
		"🎊 VICTORY ACHIEVED - THE DECK IS BALANCED! 🎊"
	]
	
	var message = celebration_messages[burst_number]
	var color_name = _get_color_name(color)
	
	print("💥 %s FIREWORK: %s" % [color_name.to_upper(), message])

func _get_color_name(color: Color) -> String:
	if color == Color.GOLD: return "Golden"
	elif color == Color.MAGENTA: return "Mystic"
	elif color == Color.CYAN: return "Crystal"
	elif color == Color.LIME: return "Emerald"
	elif color == Color.ORANGE_RED: return "Phoenix"
	elif color == Color.DEEP_PINK: return "Royal"
	else: return "Magical"

# 🎭 THE END 🎭
# May this celebration script remind us of the day
# when Fortunes achieved code enlightenment! ✨
