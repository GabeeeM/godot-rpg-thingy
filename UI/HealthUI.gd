extends Control


var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUiFull = $HeartUIFull
onready var heartUiEmpty = $HeartUIEmpty

func set_hearts(value):
#	hearts = clamp(value, 0, max_hearts)
	heartUiFull.rect_size.x = value * 15
	if(value < 1):
		heartUiFull.hide()

func set_max_hearts(value):
	max_hearts = value
	heartUiEmpty.rect_size.x = PlayerStats.max_health * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
