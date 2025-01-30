class_name Frame extends GridContainer

var throws: Array[Node];

func _ready() -> void:
	throws = get_children();

func fill_frame(values: Array) -> void:
	var idx = 0;
	for value in values:
		throws[idx].visible = true;
		var throw_label: Label = throws[idx].get_child(0) as Label;
		throw_label.text = str(value);
		idx += 1;
