extends Node

@export_file("*.txt") var input_file_path
@onready var input_string: String = ""
@onready var save_loader: SaveLoad = SaveLoad.new()
@onready var string_parser: StringParser = StringParser.new()

@onready var list_a: Array[int] = []
@onready var list_b: Array[int] = []

@onready var list_distances: Array[int] = []
@onready var total_list_distances: int

@onready var similarity_score: int


func _ready() -> void:
	input_string = save_loader.load_text_from_file(input_file_path)
	
	process_input(input_string)
	
	list_a.sort()
	list_b.sort()
	
	
	compare_lists_for_distances(list_a, list_b)
	
	
	total_list_distances = sum_distances(list_distances)
	prints("Total List Distances:", total_list_distances)
	
	similarity_score = calculate_similarity_score(list_a, list_b)
	prints("Similarity Score:", similarity_score)
	
	
	pass


func _process(delta: float) -> void:
	pass


#func load_text_from_file(file_path: String):
	#var input_file = FileAccess.open(file_path, FileAccess.READ)
	#input_string = input_file.get_as_text()
	#return input_string





func process_input(input: String) -> void :
	var lines = string_parser.split_to_lines(input)
	for line in lines:
		var int_array : Array[int] = string_parser.split_line_to_ints_space_delimited(line)
		list_b.append( int_array.pop_back() )
		list_a.append( int_array.pop_back() )
	return


#func split_to_lines(input: String) -> PackedStringArray :
	#return input.split("\n", false)
#
#func split_line_to_ints_space_delimited(input: String) -> Array[int] :
	#var strings : PackedStringArray = input.split(" ", false)
	#var int_array: Array[int] = []
	#for index in strings.size() :
		#int_array.append( strings[index].to_int() )
	#return int_array



func compare_lists_for_distances(a: Array[int], b: Array[int]) -> void :
	for entry in a.size() :

		if a[entry - 1] > b[entry - 1] :
			list_distances.append( a[entry - 1] - b[entry - 1] )
		else :
			list_distances.append( b[entry - 1] - a[entry - 1] )
	return

func sum_distances(list: Array[int]) -> int :
	var sum : int
	for entry in list :
		sum += entry
	return sum


func calculate_similarity_score(list_a: Array[int], list_b: Array[int]) -> int :
	var score: int = 0
	for entry_a in list_a :
		var entry_score = 0
		for entry_b in list_b :
			if entry_b == entry_a :
				entry_score = entry_score + 1
		score += entry_a * entry_score
	return score
