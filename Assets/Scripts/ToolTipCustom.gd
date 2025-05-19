@tool
extends RichTextLabel
 
# width limit before wrap occurs
var width_max: int = 300
 
func _ready():
	# connect the 'resized' signal to the 'check_width()' function
	resized.connect(check_width)
 
func check_width():
	# when resize occurs, check if the max width has been hit
	if (size.x >= width_max):
		# if so, enable wordwrap and set the custom minimum size
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		custom_minimum_size.x = width_max
 
		# also disconnect the signal since it is no longer needed
		resized.disconnect(check_width)