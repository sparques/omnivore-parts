$fs=0.5; $fa=0.5;

use <common.scad>;
use <gears.scad>;
use <profiles.scad>;

use <lprofiles.scad>;
use <external.scad>;

function r_gear(modul,tooth_number)=modul*tooth_number/2;
function r_worm(modul,thread_starts,lead_angle) = modul*thread_starts/(2*sin(lead_angle));       // Worm Part-Cylinder Radius



module assembly(open=true) {
//worm(modul=2, thread_starts=1, length=20, bore=0, pressure_angle=25, lead_angle=5, together_built=true);
// omni-wheel and 6mm dshaft
%color("red")translate([-r_gear(2,10),0,-20]) {
	mirror([0,0,1])cylinder(d=60,h=30);
	linear_extrude(40)d_shaft(6,5.4);
}
// motor
%color("red")translate([r_worm(2,1,10),-(housing_width+walls)/2-50,0])rotate([-90,0,0])motor();
// gears
translate([r_worm(2,1,10),0,0])rotate([90,0,0])wormgear();
translate([-r_gear(2,10),0,-4])rotate([0,0,-14])follower();
//color("blue")worm_gear(modul=2, tooth_number=10, thread_starts=1, width=gear_thickness, length=20, worm_bore=3, gear_bore=6, pressure_angle=30, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);

// bearings
%color("gray")translate([-r_gear(2,10),0,0]) {
			mirrorz()up(house_depth/4+2)bearing_M6();
		}
		
	housing_back();
	if (!open) {
		#housing_front();
	}
}

walls=4;
gear_thickness=8;
house_depth=40;
housing_width=24;
		
module orbital_holes() {
	mirrorz()for(t=[22,66,100])translate([r_worm(2,1,10),0,0])rotate([0,t,0])translate([(housing_width+walls)/2+1,0,0])children();
}

module fillet2() {
	rotate([-90,0,0])linear_extrude(housing_width+walls*2,center=true)offset(r=-3)offset(r=3)projection()rotate([90,0,0])children();
}

module center_over_worm() {
	translate([r_worm(2,1,10),0,0])children();
}

module center_over_follower() {
	translate([-r_gear(2,10),0,0])children();
}

worm_bearing=true;
module housing() {
	difference() {
		// exterior
		union() {
			fillet2() {
				hull() {
					translate([-10,0,0]){
						cube([housing_width+2*walls,housing_width+2*walls,house_depth],center=true);
					}
					translate([5.7,0,0])rotate([90,0,0])cylinder(d=housing_width+walls,h=housing_width+2*walls,center=true);
				}
				orbital_holes()rotate([90,0,0])cylinder(d=walls+4,h=housing_width+walls*2,center=true);
			}
			if (worm_bearing) {
				translate([0,housing_width/2-0.01,0])center_over_worm()rotate([-90,0,0])minkowski() {
					bearing_M6();
					sphere(d=walls);
				}
			}
		}

		//interrior space
		minkowski() {
			interrior_fillet=2;
			union() {
				center_over_follower() {
					//cube([housing_width+1-interrior_fillet,housing_width-interrior_fillet,10],center=true);
					cylinder(r=r_gear(2,12),h=8,center=true);
				}
				center_over_worm()rotate([90,0,0])cylinder(d=24-interrior_fillet,h=housing_width-interrior_fillet,center=true);
			}
			sphere(d=interrior_fillet);
		}
		
		// bearing slots and shaft hole
		center_over_follower() {
			cylinder(d=9,h=100,center=true);// shaft hole is 9mm to give clearance for hte inner spinny bit of the bearings
			// may need to scale([1.05,1.05,1.05]) the bearing slots
			mirrorz()up(house_depth/4+2)bearing_M6();
		}
		
		// bearing for opposite side of worm
		if (worm_bearing) {
			translate([0,housing_width/2-0.01,0])center_over_worm()rotate([-90,0,0])bearing_M6();
		}
		
		//motor mount screw holes
		translate([r_worm(2,1,10),-(housing_width+walls)/2+2.01,0])rotate([-90,0,0])mirror([0,0,1])motor_mount_screws();
		
		// holes to hold the housing halves together
		mirrorz(){
			translate([-18,0,9])rotate([90,0,0])linear_extrude(housing_width*3,center=true)M4();
			translate([-26+walls,0,16])rotate([90,0,0])linear_extrude(housing_width*3,center=true)M4();
		}
		orbital_holes()rotate([90,0,0]){
				linear_extrude(housing_width*3,center=true)M4();
				mirrorz()up(housing_width/2+walls)mirror([0,0,1])M3_head();
		}
		
	}
	

}

module housing_back() {
	difference() {
		housing();
		rotate([-90,0,0])cube_xy([100,100,100]);
	}
}

module housing_front() {
	difference() {
		housing();
		rotate([90,0,0])cube_xy([100,100,100]);
	}
}

module wormgear() {
	difference() {
		rotate([0,0,-90])union() {
			up(-10)worm(modul=2, thread_starts=1, length=20, bore=0, pressure_angle=30, lead_angle=10, together_built=1);
			cylinder(d=6,h=23,center=true);
			if (worm_bearing) {
				cylinder(d=6,h=23/2+5); // extend farther to reach into the 
			} 
		}
		linear_extrude(24,center=true)mirror([1,0,0])d_shaft(3.5,3.1);
		//rotate([0,90,0])linear_extrude(50,center=true)M3(); //this won't do anything, the motor shaft is too short :(
		if (worm_bearing) {
			up(23/2+5)chamfer_ring(1,6);
		}
	}
}

module follower() {
	//color("blue")worm_gear(modul=2, tooth_number=10, thread_starts=1, width=gear_thickness, length=20, worm_bore=3, gear_bore=6, pressure_angle=30, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);
	difference() {
		rotate([0,0,21])spur_gear(modul=2, tooth_number=10, width=8, bore=0, pressure_angle=30, helix_angle=10);
		up(-0.01)linear_extrude(9)d_shaft(6,5.4);
		up(4)rotate([0,90,0])linear_extrude(50,center=true)M3();
	}
}


// show everything all put together
//assembly();

// do these one at a time for printing
//housing_back();

//housing_front();

wormgear();

//follower();





/*
    c = modul / 6;                                              // Tip Clearance
    r_worm = modul*thread_starts/(2*sin(lead_angle));       // Worm Part-Cylinder Radius
    r_gear = modul*tooth_number/2;                                   // Spur Gear Part-Cone Radius
    rf_worm = r_worm - modul - c;                       // Root-Cylinder Radius
*/