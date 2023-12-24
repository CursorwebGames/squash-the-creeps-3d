extends Node

@export var mob_scene: PackedScene


func _ready():
	($UserInterface/Retry as ColorRect).hide()

func _on_mob_timer_timeout():
	# every n seconds
	var mob = mob_scene.instantiate()
	
	var spawn_loc = $SpawnPath/SpawnLocation as PathFollow3D
	spawn_loc.progress_ratio = randf()
	
	var player_pos = ($Player as CharacterBody3D).position
	mob.init(spawn_loc.position, player_pos)
	
	# connect signal
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed)
	
	add_child(mob)

func _unhandled_input(event):
	# retry if dead
	if event.is_action("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()

func _on_player_hit():
	($MobTimer as Timer).stop()
	($UserInterface/Retry as ColorRect).show()
