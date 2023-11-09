extends Node2D

onready var player1 = get_node("adventurer")
onready var camera = get_node("dead-fim-camera")


signal paused

func _process(delta):
	pass

func _ready():
	
	get_node("control-layer/topPanel/vidas").set_text(str(int(Global.vidas)))
	
	#print(global.vidas)
	if Global.musica == true:
		get_node("main-music").set_autoplay(true)
		get_node("main-music").play()
		#$control_Layer/pause_menu/pauseButton/popup/TextureRect/on.show()
		#$control_Layer/pause_menu/pauseButton/popup/TextureRect/off.hide()
		#get_node("control_Layer/pause_menu/pauseButton/popup/music_button").toggle_mode(true)
	if Global.musica == false:
		get_node("main-music").set_autoplay(false)
		get_node("main-music").stop()
		#$control_Layer/pause_menu/pauseButton/popup/TextureRect/on.hide()
		#$control_Layer/pause_menu/pauseButton/popup/TextureRect/off.show()
		#get_node("control_Layer/pause_menu/pauseButton/popup/audio").toggle_mode(false)
		

func _on_quit_pressed():
	get_tree().quit()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		#$control_Layer/pause_menu/pauseButton/popup.show()
		#get_tree().set_pause(true)
		get_tree().quit()

func reviver():
	player1.set_position(get_node("spawn-point").get_position())
	player1.reviver()
	#get_node("game_time").set_wait_time(60)
	#get_node("game_time").start()

func _on_spawntimer_timeout():
	reviver()

func _on_adventurer_morrer():
	Global.vidas -= 1
	get_node("spawn-timer").start()
	print(Global.vidas)
	$"main-music".stop()
	#$dead_music.play()


######### FIM BLOCK ##########

func change_camera():
	#Função para mudança de câmera no fim ou ao morrer
	camera.set_global_position(player1.get_node("camera").get_camera_position())
	camera.make_current()

func _on_adventurer_fim():
	#get_node("control_Layer/control").hide()
	change_camera()
	get_node("end-timer").set_wait_time(3)
	get_node("end-timer").start()
	print("fim")
	#get_node("game_time").stop()

func _on_end_timeout():
	#get_tree().quit()
	get_tree().reload_current_scene()

### PAUSE MENU ###

func _on_pause_pressed():
	get_tree().set_pause(true)
