// cylindrical base of deadbolt
base_dia = 63.5;
base_height = 4.8;

// handle
handle_height_max = 8;
// tiny cylindrical base on which handle sits and swivels
// (diameter is entirely below the handle, so it is irrelevant)
handle_base = 1.6;

case_wall_thickness = 10;
// additional space above/below the deadbolt to allow for positioning
case_vertical_leeway = 5;

// enclose deadbolt base
difference() {
	cube([base_dia + 2*case_wall_thickness, base_dia + 2*case_wall_thickness + case_vertical_leeway, base_height]);

	translate([case_wall_thickness, case_wall_thickness, 0]) {
		cube([base_dia, base_dia + case_vertical_leeway, base_height]);
	}
}

// motor mount

// supports over deadbolt handle
translate([0, case_wall_thickness + case_vertical_leeway/2, base_height]) {
	cube([case_wall_thickness, base_dia, handle_base + handle_height_max]);
}

translate([case_wall_thickness + base_dia, case_wall_thickness + case_vertical_leeway/2, base_height]) {
	cube([case_wall_thickness, base_dia, handle_base + handle_height_max]);
}

// handle "grabber"
module handle(){

}