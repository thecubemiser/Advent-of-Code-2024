class_name StringParser extends Resource

var reg : RegEx = RegEx.new()

func split_to_lines(input: String) -> PackedStringArray :
	return input.split("\n", false)

func split_line_to_ints_space_delimited(input: String) -> Array[int] :
	var strings : PackedStringArray = input.split(" ", false)
	var int_array: Array[int] = []
	for index in strings.size() :
		int_array.append( strings[index].to_int() )
	return int_array


func return_regex_strings(search_string: String, input) -> PackedStringArray :
	reg.compile(search_string)
	var results = []
	for result in reg.search_all(input) :
		results.push_back ( result.get_string() )
	return results
