extends Node

@export_file("*.txt") var input_file_path
@onready var input_string: String = ""
@onready var save_loader: SaveLoad = SaveLoad.new()
@onready var string_parser: StringParser = StringParser.new()

@export var search_string: String

@onready var reg : RegEx = RegEx.new()

@onready var mul_commands : Array[String] = []
@onready var mul_commands_culled : Array[String] = []
@onready var mul_command_multiples : Array[int] = []

@onready var mul_command_sum : int = 0

@onready var do_default : bool = true
@onready var do_while_do : bool = true


func _ready() -> void:
	do_while_do = do_default
	
	input_string = save_loader.load_text_from_file(input_file_path)
	
	for str in string_parser.return_regex_strings(search_string, input_string) :
		mul_commands.append(str)

	
	for command in mul_commands :
		if test_dont(command) :
			do_while_do = false
			prints("Do set to OFF")
		elif test_do(command) :
			do_while_do = true
			prints("Do set to ON")
		if do_while_do == true :
			if test_mul(command) :
				prints("Appending Command", command)
				mul_commands_culled.append(command)
	
	prints("Mul Commands Culled:", mul_commands_culled.size())
	for command in mul_commands_culled :

		mul_command_multiples.append( multiply_mul_command(command) )
	
	
	prints(mul_command_multiples)
	for multiple in mul_command_multiples :
		mul_command_sum += multiple
	
	prints("MUL COMMAND SUM", mul_command_sum)
	
	pass 



func _process(delta: float) -> void:
	pass


func multiply_mul_command(command) -> int:
	var mul_pair: Array[int]
	for pair in string_parser.return_regex_strings(str("[0-9]{1,3}"), command) :
		mul_pair.append( pair.to_int() )
	prints("Mul Pair:", mul_pair)
	return mul_pair[0] * mul_pair[1]


func test_dont(input) -> bool :
	reg.compile("don't[()][)]")
	var results = []
	if reg.search_all(input) :
		return true
	return false
		
func test_do(input) -> bool :
	reg.compile("do[()][)]")
	var results = []
	if reg.search_all(input) :
		return true
	return false

func test_mul(input) -> bool :
	reg.compile("mul[(]")
	var results = []
	if reg.search_all(input) :
		return true
	return false
