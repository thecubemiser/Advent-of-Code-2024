extends Node

@export_file("*.txt") var input_file_path
@onready var input_string: String = ""
@onready var save_loader: SaveLoad = SaveLoad.new()
@onready var string_parser: StringParser = StringParser.new()

@export var level_step_threshold : int = 3

class Report extends Resource :
	var levels : Array[int] = []
	var safe : bool
# a safe report has levels that are steadily increasing
# by a min 1 to max 3 per level in the report,
# or decreasing similarly.

@onready var reports : Array[Report] = []
# list of "levels" as data recorded


@onready var safe_reports : int = 0
# a safe report has levels that are steadily increasing
# by a min 1 to max 3 per level in the report,
# or decreasing similarly.

func _ready() -> void:
	input_string = save_loader.load_text_from_file(input_file_path)
	
	process_input(input_string)
	
	for report in reports :
		set_is_report_safe(report)
	
	safe_reports = count_safe_reports(reports)
	
	prints("Original Safe Reports =", safe_reports)
	
	
	for report in reports:
		if report.safe == false :
			report.safe = process_safety_dampener(report)
	
	safe_reports = count_safe_reports(reports)
	
	prints("Safe Reports After Dampening =", safe_reports)
	
	pass


func _process(delta: float) -> void:
	pass


func process_input(input: String) -> void :
	var reports_by_string : PackedStringArray = string_parser.split_to_lines(input)
	for index in reports_by_string.size() :
		var report : Report = Report.new()
		report.levels = string_parser.split_line_to_ints_space_delimited( reports_by_string[index] )
		reports.append(report)
	return

func set_is_report_safe(report: Report) -> void :
	if are_levels_increasing(report):
		report.safe = true
	elif are_levels_decreasing(report):
		report.safe = true
	else :
		report.safe = false
	# prints(report.levels, "Safe =", report.safe)

func are_levels_increasing(report):
	var report_size = report.levels.size()
	var success = true
	for index in report_size - 1 :
		success = compare_levels(report.levels[index], report.levels[index+1])
		if success == false: return success
	return success

func are_levels_decreasing(report):
	var report_size = report.levels.size()
	var success = true
	for index in report_size - 1:
		success = compare_levels(report.levels[index+1], report.levels[index])
		if success == false: return success
	return success


func compare_levels(a: int,b: int) -> bool :
	if b > a and b - a <= level_step_threshold :
		return true
	else:
		return false

func count_safe_reports(reports) -> int :
	var count : int = 0
	for report in reports :
		if report.safe == true :
			count += 1
	return count


func process_safety_dampener(report) -> bool :
	var alternate_reports : Array[Report] = []
	#prints("Test Report:", report.levels, "Size:", report.levels.size())
	for size in report.levels.size() +1 :
		alternate_reports.append( Report.new() )
	
	for alt_rep in alternate_reports :
		alt_rep.levels = report.levels.duplicate(true)
	
	for index in alternate_reports.size() -1 :
		alternate_reports[index].levels.pop_at(index)
		#prints("--- Dampened Level Test:", alternate_reports[index].levels)
		
	for alt_report in alternate_reports:
		set_is_report_safe(alt_report)
		#prints("Alternate Report: ", alt_report.levels, "Safe?", alt_report.safe)
		if alt_report.safe == true :
			prints("FOUND NEW SAFE REPORT", alt_report.levels)
			return true
	
	return false
