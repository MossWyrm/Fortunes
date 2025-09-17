class_name TooltipData
extends RefCounted
## Tooltip data container with support for multiple game layers and object types
##
## The tooltip system automatically handles title, description, and color
## from the appropriate description system based on the game layer and object type.

var title: String        # Set by tooltip system
var description: String  # Set by tooltip system  
var object: Variant     # The object to display (Card, Rune, Symbol, etc.)
var color: Color        # Set by tooltip system
var layer: DataStructures.GameLayer  # Which game layer this tooltip belongs to

func _init(tooltip_object: Variant, tooltip_layer: DataStructures.GameLayer = DataStructures.GameLayer.DECK):
    object = tooltip_object
    layer = tooltip_layer
    # title, description, and color will be determined by the tooltip system based on layer and object type