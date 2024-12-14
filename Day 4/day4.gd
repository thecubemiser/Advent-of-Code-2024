extends Node

@export_file("*.txt") var input_file_path
@onready var input_string: String = ""
@onready var save_loader: SaveLoad = SaveLoad.new()
@onready var string_parser: StringParser = StringParser.new()

@export var search_string_part_one: String

@export var search_string_part_two: String

var NORTH = Vector2i(Vector2i.UP)
var SOUTH = Vector2i(Vector2i.DOWN)
var EAST = Vector2i(Vector2i.RIGHT)
var WEST = Vector2i(Vector2i.LEFT)

var NORTHEAST = Vector2i(NORTH + EAST)
var SOUTHEAST = Vector2i(SOUTH + EAST)
var NORTHWEST = Vector2i(NORTH + WEST)
var SOUTHWEST = Vector2i(SOUTH + WEST)

var directions : Array[Vector2i] = [
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTHEAST,
	SOUTHEAST,
	NORTHWEST,
	SOUTHWEST]



class MapSpot :
	var map_location : Vector2i
	var marker: String = ""
	var words_found: Dictionary = {}
	var linked_spots: Dictionary = {}



@onready var map: Dictionary = {} # Vector2i, MapSpot
@onready var map_size: Vector2i

@onready var starting_spots: Array[MapSpot] = []
# will fill with spots that contain "X" as their marker
@onready var found_word_one_spots: Array[MapSpot] = []

@onready var part_two_submap_indices: Dictionary = {}
@onready var part_two_submap_size: Vector2i = Vector2i(2,2)

@onready var found_word_two_spots: Array[MapSpot] = []

func _ready() -> void:
	
	input_string = save_loader.load_text_from_file(input_file_path)
	
	
	process_input(input_string)
	setup_linked_spots(map)
	
	# part one parsing
	gather_starting_spots(map, search_string_part_one[0])
	check_wordfind(map, starting_spots, search_string_part_one)
	compile_words_found(starting_spots, search_string_part_one)
	
	
	prints("PART TWO")
	gather_part_two_submaps(map, part_two_submap_size)
	
	check_part_two_wordfind(part_two_submap_indices, search_string_part_two)
	prints("Part Two Total \"X-MAS\" Found:",found_word_two_spots.size())
	
	pass



func _process(delta: float) -> void:
	pass



func process_input(input: String) -> void :
	var lines : PackedStringArray = string_parser.split_to_lines(input)
	# get length of lines to create bounds for our map
	# assign locations and create map spots for each into map
	map_size = Vector2i( lines[0].length(), lines.size() )
	for line_index : int in map_size.y :
		for character in map_size.x :
			var spot = MapSpot.new()
			spot.map_location = Vector2i(character, line_index)
			spot.marker = lines[line_index].substr(character, 1)
			map[spot.map_location] = spot
	return


func setup_linked_spots(map: Dictionary) -> void :
	for spot: MapSpot in map.values():
		for direction in directions:
			if is_location_oob(map, spot.map_location + direction) :
				continue
			else:
				spot.linked_spots[direction] = map[spot.map_location + direction]


func gather_starting_spots(map: Dictionary, char: String) -> void :
	for location in map :
		if map[location].marker == char :
			starting_spots.append( map[location] )
	prints("Starting Spots Found:", starting_spots.size())



func check_wordfind(map: Dictionary, starting_locations: Array[MapSpot], search_string: String) -> void :
	for location in starting_locations :
		for direction in directions:
			if check_search_string_by_direction(location, search_string, direction) :
				if !location.words_found.has(search_string):
					location.words_found[search_string] = []
				location.words_found[search_string].append(direction)




func check_search_string_by_direction(spot: MapSpot, search_string: String, search_direction: Vector2i) -> bool :
	var current_spot: MapSpot = spot
	var next_spot: MapSpot = current_spot
	var current_string_found: String = ""
	
	
	
	for index in search_string.length():
		current_string_found += next_spot.marker
		if index == search_string.length():
			break
		
		if next_spot.linked_spots.keys().has(search_direction) :
			next_spot = next_spot.linked_spots[search_direction]
	
	if current_string_found == search_string:
		#prints("found word at", current_spot.map_location, "in direction", search_direction)
		return true

	return false


func check_spot_character(spot: MapSpot, string: String, index: int) -> bool :
	prints("Checking string character",string[index],"at index",index,"(spot",spot.map_location,"), found:",spot.marker)
	if spot.marker == string[index] :
		return true
	return false


func is_location_oob(map: Dictionary, location: Vector2i) -> bool :
	if map.has(location) : return false
		#if map[location].map_location.y < 0 : return false
		#if map[location].map_location.x < 0 : return false
		#if map[location].map_location.y > map_size.y : return false
		#if map[location].map_location.x > map_size.x : return false
	return true


func compile_words_found(locations: Array[MapSpot], search_string: String) -> void :
	var total_words : int = 0
	for location in locations:
		if location.words_found.has(search_string):
			found_word_one_spots.append(location)
			total_words += location.words_found[search_string].size()
	prints("Total Words Found:", total_words)



func gather_part_two_submaps(map: Dictionary, part_two_submap_size: Vector2i) -> void :
	prints("Beginning Submap Indices:",part_two_submap_indices.size())
	prints("Submap Size:", part_two_submap_size)
	var truncated_map_size = map_size - part_two_submap_size
	prints("Truncated Map Size:", truncated_map_size)
	for x in truncated_map_size.x :
		for y in truncated_map_size.y :
			part_two_submap_indices[Vector2i(x,y)] = map[Vector2i(x,y)]
	prints("Found Submap Indices:",part_two_submap_indices.size())
	var submaps_to_remove : Array[Vector2i]
	for key in part_two_submap_indices.keys() :
		if part_two_submap_indices[key].linked_spots[SOUTHEAST].marker != search_string_part_two[1]:
			submaps_to_remove.append(key)
	for key in submaps_to_remove :
		part_two_submap_indices.erase(key)
	prints("Filtered Submap Indices:",part_two_submap_indices.size())


func check_part_two_wordfind(locations: Dictionary, word: String):
	var ind_NW = Vector2i(0,0)
	var ind_NE = Vector2i(part_two_submap_size.x,0)
	var ind_SW = Vector2i(0,part_two_submap_size.y)
	var ind_SE = Vector2i(part_two_submap_size)
	
	for spot: MapSpot in locations.values() :
		
		if check_search_string_by_direction(spot, word, SOUTHEAST) :
			if check_search_string_by_direction(map[spot.map_location + ind_NE], word, SOUTHWEST) :
				found_word_two_spots.append(spot)
		
		if check_search_string_by_direction(spot, word, SOUTHEAST) :
			if check_search_string_by_direction(map[spot.map_location + ind_SW], word, NORTHEAST) :
				found_word_two_spots.append(spot)
		
		if check_search_string_by_direction(map[spot.map_location + ind_SE], word, NORTHWEST) :
			if check_search_string_by_direction(map[spot.map_location + ind_NE], word, SOUTHWEST) :
				found_word_two_spots.append(spot)
		
		if check_search_string_by_direction(map[spot.map_location + ind_SE], word, NORTHWEST) :
			if check_search_string_by_direction(map[spot.map_location + ind_SW], word, NORTHEAST) :
				found_word_two_spots.append(spot)
