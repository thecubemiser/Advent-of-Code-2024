class_name SaveLoad extends Resource


func load_text_from_file(file_path: String):
	var input_file = FileAccess.open(file_path, FileAccess.READ)
	var input_string = input_file.get_as_text()
	return input_string
