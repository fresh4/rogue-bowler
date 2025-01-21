extends Node3D

@onready var grid_map: GridMap = %GridMap
@onready var subtraction_box: CSGBox3D = %SubtractionBox
@onready var csg_grid: CSGCombiner3D = %CSGGrid

var max_x: int = 0;
var min_x: int = 0;
var max_z: int = 0;
var min_z: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	csg_grid.visible = true;
	for cell in grid_map.get_used_cells():
		if cell.x < min_x: min_x = cell.x;
		if cell.x > max_x: max_x = cell.x;
		if cell.z < min_z: min_z = cell.z;
		if cell.z > max_z: max_z = cell.z;
		
	var size: Vector3 = Vector3(calculate_bounds(min_x, max_x), 12, calculate_bounds(min_z, max_z));
	subtraction_box.size = size;
	

func calculate_bounds(min_n: int, max_n: int) -> int:
	return ( 30 * ( ( abs(min_n) + abs(max_n) ) / 15 ) ) + 30;
