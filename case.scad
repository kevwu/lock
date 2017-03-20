// cylindrical base of deadbolt
base_dia = 63.5;
base_height = 4.8;

// handle
handle_height_max = 8;
handle_width_max = 14.3;
// handle width on long end
handle_width_min_long = 6.35;
// handle width on short end
handle_width_min_short = 7.9;

handle_length = base_dia;
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

// handle
module handle(){
	linear_extrude(height=handle_height_max) {
		// long end
		polygon([
			[0,0],
			[(handle_width_max - handle_width_min_long)/2, (handle_length - 25)],
			[handle_width_max - (handle_width_max - handle_width_min_long)/2, (handle_length-25)],
			[handle_width_max,0],
		]);

		// short end
		polygon([
			[0,0],
			[(handle_width_max - handle_width_min_short)/2, -25],
			[handle_width_max - (handle_width_max - handle_width_min_short)/2, -25],
			[handle_width_max,0],
		]);
	}
}

!handle();