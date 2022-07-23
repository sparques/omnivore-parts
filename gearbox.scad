$fs=0.5; $fa=0.5;

use <common.scad>;
use <gears.scad>;
use <profiles.scad>;

use <lprofiles.scad>;
use <external.scad>;

modul=2; // 2
wheel_gear_teeth=16; // 16
motor_gear_teeth=8; // 8


module wheel_gear() {
	difference() {
		herringbone_gear(modul=modul, tooth_number=wheel_gear_teeth, width=10, bore=0, pressure_angle=20, helix_angle=30, optimized=false);
		chamfer_ring(2,(modul+wheel_gear_teeth)*2);
		up(10)chamfer_ring(2,(modul+wheel_gear_teeth)*2);
		linear_extrude(21,center=true)d_shaft(6,5.4);
	}
}

module motor_gear() {
	difference() {
		herringbone_gear(modul=modul, tooth_number=motor_gear_teeth, width=10, bore=0, pressure_angle=20, helix_angle=30, optimized=true);
		chamfer_ring(2,(modul+motor_gear_teeth)*2);
		up(10)chamfer_ring(2,(modul+motor_gear_teeth)*2);
		linear_extrude(21,center=true)d_shaft(3.3,3);
	}
}


module center_over_wheel_gear() {
	translate([0,motor_gear_teeth,0])children();
}

module center_over_motor_gear() {
	translate([0,-wheel_gear_teeth,0])children();
}

module gears_together() {
	center_over_motor_gear()motor_gear();
	center_over_wheel_gear()wheel_gear();	
}

clearance=2; //space between moving parts and casing
gearbox_wall=5; //thickness of the gearbox wall

module gears_together_profile() {
	hull() {
		//projection()gears_together();
		//center_over_motor_gear()circle(modul+motor_gear_teeth);
		// need more space for the motor so we size to the motor, rather than the motor gear
		center_over_motor_gear()circle(d=30);
		center_over_wheel_gear()circle(modul+wheel_gear_teeth+2);
	}
}

module case_holes() {
	center_over_wheel_gear()
		for(t=[0,60,120,180])
			rotate([0,0,t])translate([modul+wheel_gear_teeth+2 + gearbox_wall/2 +1,0,0])M4();
	center_over_motor_gear()
		for(t=[0,-60,-120,-180])
			rotate([0,0,t])translate([30/2+gearbox_wall/2+1,0,0])M4();
}

// bottom_plate is the against the robot body plate, it has the motor mount
// and mount holes for attaching to the robot body
module bottom_plate() {
	plate_thickness=5;
	plate_inset=2;
	difference() {
		union() {
			linear_extrude(plate_thickness)offset(r=gearbox_wall+clearance)gears_together_profile();
			linear_extrude(plate_thickness+plate_inset)offset(r=-0.5)gears_together_profile();
		}
		
		// for wheel bearing
		up(7.001)center_over_wheel_gear()mirror([0,0,1])bearing_M6();
		
		// cut-out so we can mount the motor close enough
		up(-0.001)center_over_motor_gear()cylinder(d=30,h=plate_thickness+plate_inset-5);
		
		// holes for mounting motor (and letting motor shaft through)
		center_over_motor_gear()up(plate_thickness+plate_inset+0.01)rotate([0,0,90])mirror([0,0,1])motor_mount_screws();
		
		// holes for mounting plate to robot body
		center_over_wheel_gear()
			up(-0.01)
				for(t=[0,60,120,180]) {
					rotate([0,0,t])translate([13,0,0]){
						linear_extrude(plate_thickness+plate_inset+1)M4();
						up(plate_thickness+plate_inset+0.02)mirror([0,0,1])M3_head();
					}
				}
		
		// holes for connecting plate to gearbox body
		up(-0.01)linear_extrude(plate_thickness+plate_inset)case_holes();
		
	}
}

// bottom_plate is the against the robot body plate, it has the motor mount
// and mount holes for attaching to the robot body
module top_plate() {
	plate_thickness=5;
	plate_inset=2;
	difference() {
		union() {
			linear_extrude(plate_thickness)offset(r=gearbox_wall+clearance)gears_together_profile();
			linear_extrude(plate_thickness+plate_inset)offset(r=-0.5)gears_together_profile();
		}
		
		// for wheel bearing
		up(7.001)center_over_wheel_gear()mirror([0,0,1])bearing_M6();
		// for wheel shaft
		up(-0.01)center_over_wheel_gear()cylinder(d=7,h=plate_thickness+plate_inset+1);
		
		// for motor gear bearing
		up(7.001)center_over_motor_gear()mirror([0,0,1])bearing_M6();
		
		// holes for connecting plate to gearbox body
		up(-0.01)linear_extrude(plate_thickness+plate_inset)case_holes();
	}
}

module body() {
	thickness=10+4+2; // 10mm for the wheels, 1mm clearance either side, 4mm from the insets from the plates
	difference() {
		linear_extrude(thickness)difference() {
			offset(r=gearbox_wall+clearance)gears_together_profile();
			gears_together_profile();
		}
		up(-0.01)linear_extrude(thickness+1)case_holes();
	}
}

rotate([-90,0,0]){
*#body();
down(5)bottom_plate();
%up(3)gears_together();
up(21)rotate([0,180,0])top_plate();


*%down(46+3)center_over_motor_gear()motor();


%up(22)center_over_wheel_gear()omniwheel();


}