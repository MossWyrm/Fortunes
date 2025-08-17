class_name TooltipData
extends RefCounted

var title: String
var description: String
var card: Card
var color: Color

func _init(tooltip_title: String, tooltip_description: String, tooltip_card: Card, tooltip_color: Color = Color.WHITE):
    title = tooltip_title
    description = tooltip_description
    color = tooltip_color
    card = tooltip_card