extends Node

const PATH = "user://options.dat"

## DEFAULTS
var version = 2 # Increment by 1 any time you add new settings
var data = {
	"sens": 1,
	"volume": 0
}


func _ready():
	load_data()


func save_data():
	print("saving")
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_var(version)
	file.store_var(data)
	file.close()


func load_data():
	# Check to see if data exists
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH, FileAccess.READ)
		var file_version = file.get_var()
		# If the file doesn't have a version, ignore it and use defaults
		if (type_string(typeof(file_version)) != "int"): return
		# If data is from an older version, only load variables that exist in old data
		if (file_version < version):
			var old_data = file.get_var()
			for key in old_data:
				if data.has(key):
					data[key] = old_data[key]
		# Otherwise, just load data
		else:
			data = file.get_var()
		file.close()
