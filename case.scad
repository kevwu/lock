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

base_wall_thickness = 10;
// additional space above/below the deadbolt to allow for positioning
base_vertical_leeway = 5;

module base() {
	// enclose deadbolt base
	difference() {
		cube([base_dia + 2*base_wall_thickness, base_dia + 2*base_wall_thickness + base_vertical_leeway, base_height]);

		translate([base_wall_thickness, base_wall_thickness, 0]) {
			cube([base_dia, base_dia + base_vertical_leeway, base_height]);
		}
	}

	// motor mount

	// supports over deadbolt handle
	translate([0, base_wall_thickness + base_vertical_leeway/2, base_height]) {
		cube([base_wall_thickness, base_dia, handle_base + handle_height_max]);
	}

	translate([base_wall_thickness + base_dia, base_wall_thickness + base_vertical_leeway/2, base_height]) {
		cube([base_wall_thickness, base_dia, handle_base + handle_height_max]);
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

stepper_motor_dia = 28.6;
stepper_motor_height = 20;
stepper_motor_flange_length = 8;
stepper_motor_hole_dia = 3.17;
stepper_wire_breakout = 19;

// case for motor
module motor_case() {
	difference() {
		case_thickness = 8;
		// outer casing
		union() {
			cylinder(h=stepper_motor_height + case_thickness, d=stepper_motor_dia + case_thickness, $fn=300);

			// cross-beam (for mounting and flanges)
			translate([0,0,5]) {
				cube([base_dia + 3*case_thickness, stepper_motor_flange_length, 10], center=true);
			}

			column_height = base_height + handle_base + handle_height_max + stepper_shaft_length;

			// base (for mounting onto door)
			translate([base_dia/2 + case_thickness, 0, 0]) {
				// column
				translate([0,0,-10]) {
					cube([case_thickness, stepper_motor_flange_length, column_height], center=true);
				}
				// skid
				translate([0,0,-column_height]) {
					cube([1.5*case_thickness, base_dia + 2*case_thickness, case_thickness/2], center=true);
				}
			}

			translate([-(base_dia/2 + case_thickness),0,0]) {
				// column
				translate([0,0,-10]) {
					cube([case_thickness, stepper_motor_flange_length, column_height], center=true);
				}
				// skid
				translate([0,0,-column_height]) {
					cube([1.5*case_thickness, base_dia + 2*case_thickness, case_thickness/2], center=true);
				}
			}
		}

		union() {
			// motor hole
			cylinder(h=stepper_motor_height, d=stepper_motor_dia, $fn = 300);

			// wire breakout hole
			translate([0, stepper_motor_dia/2, stepper_motor_height/2]) {
				cube([stepper_wire_breakout, 10, stepper_motor_height], center=true);
			}
		}
	}
}

translate([-(handle_width_max)/2,0,0]) {
	%handle();
}

// handle's axis of rotation is not centered on base. 5mm here is eyeballed
translate([0, 5, -base_height]) {
	%cylinder(h=base_height, d=base_dia, $fn = 100);
}

grabber();
translate([0,0,handle_base + handle_height_max + stepper_shaft_length + 5]) {
	!motor_case();
}