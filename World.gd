extends Node2D


func _process(_delta):
	OS.set_window_title("Buer Mode Awesome     " + "FPS: " + str(Engine.get_frames_per_second()))
