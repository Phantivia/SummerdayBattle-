extends Node

# Default game port. Can be any number between 1024 and 49151.
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

# Name for my player.
var player_name = "The Warrior"

# Names for remote players in id:name format.
var players = {}
var players_set = {}
var players_ready = []
var local_set = [0,0]
# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

onready var Snow_Scene = load("res://Object/Blue_Snow/Blue_Snow.tscn")
onready var Tea_Scene = load("res://Object/tea_cup/tea.tscn")
onready var Coke_Scene = load("res://Object/coke_cup/coke.tscn")

onready var Suga_Texture = load("res://Object/Suga/char8_Suga.png")
onready var Leco_Texture = load("res://Object/Leco/char1_Leco.png")
onready var Nami_Texture = load("res://Object/Nami/char4_Nami.png")

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name,local_set)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name,set = [0,0]):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	players_set[id] = set
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	players_set.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_points):
	# Change scene.
	var map = load("res://Object/Field1/Field.tscn").instance()
	var game = load("res://Game.tscn").instance()
	game.add_child(map)
	get_tree().get_root().add_child(game)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://Object/Leco/Leco.tscn")
	for p_id in spawn_points:
		var spawn_pos = map.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.
		player.scale *= 0.15
		player.find_node("camera").current = false

		var equip_set = [0,0]

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
			player.find_node("camera").current = true
			equip_set = local_set

		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])
			equip_set = players_set[p_id]

		match equip_set[0]:
				0:
					player.get_node("hero_sprite").texture = Suga_Texture
				1:
					player.get_node("hero_sprite").texture = Leco_Texture
				2:
					player.get_node("hero_sprite").texture = Nami_Texture

		match equip_set[1]:
				0:
					player.get_node("weapon").add_child(Snow_Scene.instance())
					player.get_node("Shield").visible = true
				1:
					player.get_node("weapon").add_child(Coke_Scene.instance())
				2:
					player.get_node("weapon").add_child(Tea_Scene.instance())
					
		player.set_network_master(p_id)
		map.get_node("Players").add_child(player)

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	OS.set_window_maximized(true)
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)


func join_game(ip, new_player_name):
	player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()
	players_set.clear()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
