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

stepper_shaft_dia = 4.9;
// width of notched part of shaft
stepper_shaft_notch = 3;
// length of notched part of shaft
stepper_shaft_length = 6;

case_wall_thickness = 10;
// additional space above/below the deadbolt to allow for positioning
case_vertical_leeway = 5;

module base() {
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
}

// deadbolt handle. Not used in product, but helps with dimensioning.
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

// handle "grabber"
module grabber() {
	cyl_dia = 8;
	cyl_height = handle_height_max + stepper_shaft_length + 2;
	difference() {
		union() {
			translate([10, 12, 0])
				cylinder(h=cyl_height, d=cyl_dia, $fn = 100);
			translate([-10,12,0])
				cylinder(h=cyl_height, d=cyl_dia, $fn = 100);
			translate([10,-10,0])
				cylinder(h=cyl_height, d=cyl_dia, $fn = 100);
			translate([-10,-10,0])
				cylinder(h=cyl_height, d=cyl_dia, $fn = 100);
			translate([0, 1 ,cyl_height - stepper_shaft_length/2])
				cube([20 + cyl_dia, 22 + cyl_dia ,stepper_shaft_length], center=true);
		}

		intersection() {
			cylinder(h=50, d=stepper_shaft_dia, $fn = 50);
			cube([stepper_shaft_dia, stepper_shaft_notch, 50], center=true);
		}
	}
}

translate([-(handle_width_max)/2,0,0]) {
	handle();
}
!grabber();