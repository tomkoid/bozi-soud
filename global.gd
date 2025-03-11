extends Node

var game_controller : GameController
var game_version = "1.4.1"

var settings: GameSettings = GameSettings.new()

signal emit_player_particles

signal version_bad

@export var prev_scene = ""

func _ready():
	var ver1 = semver_parse("0.3.2.3")
	var ver2 = semver_parse("0.3.2.3-rc2")
	print(ver1)
	print(ver2)

## returns the semver_nums and semver_tags array and if the the version should be tested against the game version
## for example: 1.2.3-rc shouldn't be tested against 1.2.3 since it's a release candidate => false
func semver_parse(ver: String) -> Array:
	var semver_nums = []
	var semver_tags = []

	var tags = false
	for i in range(0,ver.length()):
		if not tags:
			if ver[i] == "-":
				tags = true
			elif ver[i] == ".":
				continue
			else:
				semver_nums.append(ver[i])
		else:
			if ver[i] == ".":
				continue
			else:
				semver_tags.append(ver[i])
		

	return [semver_nums, "".join(semver_tags), not tags]
