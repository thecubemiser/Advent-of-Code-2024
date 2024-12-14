extends Node

@export_file("*.txt") var input_file_path
@onready var input_string: String = ""
@onready var save_loader: SaveLoad = SaveLoad.new()
@onready var string_parser: StringParser = StringParser.new()

@onready var reg : RegEx = RegEx.new()

@export var page_rule_regex: String

@onready var page_rules: Array[PageRule]
class PageRule :
	var page_pair : Vector2i
	var earlier_page: int
	var later_page: int

@onready var page_sets: Array[PageSet]
class PageSet:
	var pages: Array[int]
	var ok : bool = false

@onready var satisfied_sets: Array[PageSet] = []
@onready var middle_pages: Array[int] = []

@onready var sum_of_middle_pages: int = 0

func _ready() -> void:
	
	input_string = save_loader.load_text_from_file(input_file_path)
	process_input(input_string)
	#for prule in page_rules:
		#print(prule.page_pair)
	#for pset in page_sets:
		#print(pset.pages)
	#for pset in page_sets:
		#print(pset.pages)
	test_page_sets(page_sets, page_rules)
	for p_set in page_sets :
		if p_set.ok == true :
			satisfied_sets.append(p_set)
	
	for p_set in satisfied_sets:
		middle_pages.append( get_middle_page(p_set) )
	
	prints("Number of Sets:", page_sets.size())
	prints("Number of Satisfied Sets:", satisfied_sets.size())
	#prints("Middle Pages:", middle_pages)
	sum_of_middle_pages = sum_pages(middle_pages)
	prints("Sum of Middle Pages:",sum_of_middle_pages)
	
	pass


func _process(delta: float) -> void:
	pass


func process_input(input: String) -> void :
	var lines : PackedStringArray = string_parser.split_to_lines(input)

	for line in lines:
		#if string_parser.return_regex_strings(line, page_rule_regex) :
		if line.substr(2,1) == "|":
			#prints(line)
			var prule: PageRule = PageRule.new()
			#prule.page_pair = Vector2i(line.left(2).to_int(),line.left(-2).to_int())
			prule.earlier_page = line.left(2).to_int()
			prule.later_page = line.right(3).to_int()
			#prints(prule.earlier_page, prule.later_page)
			prule.page_pair = Vector2i(prule.earlier_page, prule.later_page)
			page_rules.append(prule)
		elif line.length() == 1:
			continue
		elif !line.is_empty() :
			var pages_strings = line.split(",", false)
			var pages : Array[int] = []
			for page_number in pages_strings:
				pages.append( page_number.to_int() )
			var page_set = PageSet.new()
			page_set.pages = pages
			page_sets.append(page_set)
	pass

func test_page_sets(p_sets: Array[PageSet], p_rules: Array[PageRule]) -> void :
	for p_set: PageSet in p_sets :
		if test_page_set(p_set, p_rules):
			p_set.ok = true
		else : p_set.ok = false

func test_page_set(p_set: PageSet, p_rules: Array[PageRule]) -> bool :
	for rule in p_rules :
		if test_page_set_for_rule(p_set, rule) == false :
			return false
	return true

func test_page_set_for_rule(p_set: PageSet, p_rule: PageRule) -> bool :
	var contains : bool = false
	var satisfied : bool = true
	var page_1 : int = p_set.pages.find(p_rule.earlier_page)
	var page_2 : int = p_set.pages.find(p_rule.later_page)
	if page_1 == -1 or page_2 == -1 :
		contains = false
	else:
		contains = true
	if contains :
		if page_1 > page_2 :
			satisfied = false
	return satisfied

func get_middle_page(p_set: PageSet) -> int :
	return p_set.pages[p_set.pages.size() / 2]

func sum_pages(pages: Array[int]) -> int :
	var sum: int  = 0
	for page in pages:
		sum += page
	return sum
		
