$fs=0.5; $fa=0.5;

use <common.scad>;
use <gears.scad>;
use <profiles.scad>;

use <lprofiles.scad>;
use <external.scad>;

walls=2;
house_depth=40;
housing_width=24;
gear_modul=2;
worm_starts=1; //equivalent to number teeth
worm_length=20;
follower_teeth=10;
follower_width=8; 
lead_angle=10;
collar_connector_offset=8;
motor_flange_diameter=22;
motor_flange_height=12;
cutoutclearance=1; // this is per side, so it gets doubled. i.e. works like a radius rather than a diameter

outside_r=motor_flange_diameter/2+cutoutclearance+walls;

function r_gear_c(modul,tooth_number)=modul*tooth_number/2;
function r_worm_c(modul,thread_starts,lead_angle) = modul*thread_starts/(2*sin(lead_angle));       // Worm Part-Cylinder Radius

function r_gear()=r_gear_c(gear_modul,follower_teeth);
function r_worm()=r_worm_c(gear_modul,worm_starts,lead_angle);


module assembly(open=true) {
	// omni-wheel and 6mm dshaft

	// motor
	assembly_motor();
	// gears
	assembly_wormgear();
	assembly_follower();

	assembly_shaft_bearings();
			
		*housing_back();
		if (!open) {
			*#housing_front();
		}
}

module assembly_wheel() {
	%translate([0,0,-20]) center_over_follower() {
		color("red")mirror([0,0,1])cylinder(d=60,h=30);
		color("silver")linear_extrude(40)d_shaft(6,5.4);
	}
}

module assembly_motor() {
	%color("red")translate([0,-83,0])center_over_worm()rotate([-90,0,0])motor();
}

module assembly_shaft_bearings() {
	color("gray") center_over_follower()
		mirrorz()up(follower_width/2+cutoutclearance+3)bearing_M6();
}

module orbital_holes() {
	mirrorz()for(t=[22,66,100])translate([r_worm(),0,0])rotate([0,t,0])translate([(housing_width+walls)/2+0,0,0])children();
}

module fillet2() {
	rotate([-90,0,0])linear_extrude(housing_width+walls*2,center=true)offset(r=-3)offset(r=3)projection()rotate([90,0,0])children();
}

module center_over_worm() {
	translate([r_worm(),0,0])children();
}

module center_over_follower() {
	translate([-r_gear(),0,0])children();
}

worm_bearing=true;
module old_housing() {
	difference() {
		// exterior
		union() {
			union() {
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
			chamfer_3d(dr=2) {
				center_over_follower() {
					//cube([housing_width+1-interrior_fillet,housing_width-interrior_fillet,10],center=true);
					cylinder(r=r_gear(),h=8,center=true);
				}
				//center_over_worm()rotate([90,0,0])cylinder(d=24-interrior_fillet,h=housing_width-interrior_fillet,center=true);
				center_over_worm()rotate([90,0,0])cylinder(d=r_worm()*2.5,h=housing_width-interrior_fillet,center=true);
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
		//#translate([r_worm(2,1,10),-(housing_width+walls)/2+2.01,0])rotate([-90,0,0])mirror([0,0,1])motor_mount_screws();
		translate([0,-(housing_width+walls)/2-1,0])center_over_worm()rotate([-90,0,0])motor_mount_screws2(20,15);
		
		// holes to hold the housing halves together
		mirrorz(){
			center_over_follower()mirrorx()translate([-8,0,9])rotate([90,0,0])linear_extrude(housing_width*3,center=true)M4();
			translate([-26+walls,0,16])rotate([90,0,0])linear_extrude(housing_width*3,center=true)M4();
		}
		orbital_holes()rotate([90,0,0]){
				linear_extrude(housing_width*3,center=true)M4();
				mirrorz()up(housing_width/2+walls)mirror([0,0,1])M3_head();
		}
		
	}
}


module assembly_worm_bearing() {
	translate([0,worm_length/2+0.5,0])center_over_worm()rotate([-90,0,0]){
		bearing_M6();
		cylinder(d=10,h=6+0.5);
	}
}

module assembly_worm_flange() {
	color("silver")translate([0,-(worm_length/2+collar_connector_offset+2.1),0])center_over_worm()rotate([90,0,0])motor_flange();
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

module wormgear(cutout=false,enclose_bearing=false) {
	if (cutout) {
		// this shape nearly perfectly follows the worm gear structure, but it makes assembly too hard so we're gonna just do a boring
		// cylinder instead. But I took the time to write this and figure it out so I'm not deleting it! </sunk cost falacy>
		/*cylinder(r=r_worm()+gear_modul, h=worm_length, center=true);
		hull(){
			up(-worm_length/2)mirror([0,0,1])cylinder(r=r_worm()+gear_modul,h=collar_connector_offset);
			up(-(worm_length/2+collar_connector_offset))mirror([0,0,1])cylinder(d=22,h=2+12); // 2 for own flange, +12 for motor flange
		}*/
		// doing the portion above the xy plane separate from the portion below is easier to calculate / understand
		if (enclose_bearing) {
			cylinder(h=worm_length/2+7,d=motor_flange_diameter); // 22 = size of flange; bearing = 6mm + 1mm gap
		} else {
			cylinder(h=worm_length/2,d=motor_flange_diameter); // 22 = size of flange
		}
		mirror([0,0,1])cylinder(h=worm_length/2+collar_connector_offset+14,d=motor_flange_diameter);
	} else {
		difference() {
			rotate([0,0,-90])union() {
				up(-worm_length/2)worm(modul=gear_modul, thread_starts=worm_starts, length=worm_length, bore=0, pressure_angle=30, lead_angle=lead_angle, together_built=1);
				//cylinder(d=6,h=23,center=true);
				if (worm_bearing) {
					cylinder(d=6,h=23/2+5); // extend farther to reach into the 
				}
				up(worm_length/2)chamfer_ring(s=1,d=6);
				
				hull(){
					up(-worm_length/2)mirror([0,0,1])cylinder(d=10,h=collar_connector_offset);
					up(-(worm_length/2+collar_connector_offset))mirror([0,0,1])cylinder(d=motor_flange_diameter,h=2);
				}
			}
			//mirror([0,0,1])linear_extrude(20)motor_flange_holes(shaft=false);
			//linear_extrude(24,center=true)mirror([1,0,0])d_shaft(3.5,3.1);
			//down(5)rotate([0,90,0])linear_extrude(50,center=true)M3();
			
			up(-(worm_length/2+collar_connector_offset))linear_extrude(collar_connector_offset)motor_flange_nut_holes();
			up(-(worm_length/2+collar_connector_offset))mirror([0,0,1])linear_extrude(2)motor_flange_holes();
			
			if (worm_bearing) {
				up(23/2+5)chamfer_ring(1,6);
			}
		}
	}
}

module assembly_wormgear(cutout=false,enclose_bearing=false) {
	translate([r_worm(),0,0])rotate([-90,0,0])wormgear(cutout=cutout,enclose_bearing=enclose_bearing);
}

module follower(cutout=false) {
	//color("blue")worm_gear(modul=2, tooth_number=10, thread_starts=1, width=gear_thickness, length=20, worm_bore=3, gear_bore=6, pressure_angle=30, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);
	if (cutout) {
		cylinder(r=r_gear()+gear_modul,h=follower_width);
	} else {
		difference() {
			union()rotate([0,0,10])minkowski(){
				spur_gear(modul=gear_modul, tooth_number=follower_teeth, width=follower_width, bore=0, pressure_angle=30, helix_angle=-lead_angle, optimized=false);
				cylinder(d=0.5,h=0.0001);
			}
			linear_extrude(follower_width+1,convexity=10)d_shaft(6,5.4);
			up(follower_width/2)rotate([0,90,0])linear_extrude((r_gear()+gear_modul)*2,center=true)M3();
		}
	}
}

// the main cavity of the gearbox
module void() {
	minkowski() {
		union() {
			assembly_follower(cutout=true);
			assembly_wormgear(cutout=true);
		}
		sphere(1);
	}
}

module body() {
	intersection() {
		linear_extrude(100,center=true,convexity=20)offset(delta=-(cutoutclearance+walls),chamfer=true)offset(delta=(cutoutclearance+walls)*3)offset(delta=-(cutoutclearance+walls))union(){
			projection(){ 
				assembly_follower(cutout=true);
				assembly_wormgear(cutout=true,enclose_bearing=true);
			}
			center_over_follower()hull(){
				square([r_gear()*2.4,r_gear()*2],center=true);
				square([r_gear()*2,r_gear()*2.4],center=true);
			}
		}
		rotate([-90,0,0])linear_extrude(100,center=true,convexity=20)offset(delta=cutoutclearance+walls)hull()projection() {
			rotate([90,0,0]) {
				assembly_follower(cutout=true);
				assembly_wormgear(cutout=true,enclose_bearing=true);
				assembly_shaft_bearings();
			}
		}
	};
	
	//for(t=[0,45,-45,90,-90]) 
	for(t=[-80:160/4:80])
	center_over_worm()rotate([0,t,0])translate([outside_r+3,0,0])rotate([90,90,0])screw_mount();
	
	for(t=[145,-145]) // I can't be arsed to do the math right for this one
	center_over_follower()rotate([0,t,0])translate([19,0,0])rotate([90,90,0])screw_mount();
	
}

module housing() {
	difference() {
		difference() {
			body();
			// there is SOME WEIRD BUG here where having assembly_worm_bearing() with all the other subtractive features
			// breaks rendering. But this fixes it. Go figure.
			assembly_worm_bearing();
		}
	
		void(); // main cavity for worm and follower
		
		assembly_shaft_bearings();
		
		//assembly_worm_bearing();
		//#translate([0,worm_length/2+0.5,0])center_over_worm()rotate([-90,0,0])cylinder(d=17,h=6);//bearing_M6();
		//translate([0,worm_length/2+0.5,0])center_over_worm()rotate([-90,0,0])bearing_M6();
		
		// wheel shaft hole
		center_over_follower() {
			cylinder(d=9,h=100,center=true);// shaft hole is 9mm to give clearance for hte inner spinny bit of the bearings
		}
		
		// slot to access the motor shaft flange grub screw
		translate([-(motor_flange_diameter/2+cutoutclearance+walls),-(worm_length/2+(collar_connector_offset+8)),0])center_over_worm()
			rotate([0,90,0])linear_extrude(walls*3,center=true)hull()mirrory()translate([0,4,0])circle(d=4);
	
		// motor mount
		translate([0,-(worm_length/2+collar_connector_offset+motor_flange_height+3.3),0])center_over_worm()rotate([-90,0,0])motor_mount_screws2(5,10);
	}
	
	// make the shaft bearing support stick into the main cavity some
	difference() {
		minkowski() {
			assembly_shaft_bearings();
			//sphere(1.5);
			mirrorz()linear_extrude(sqrt(2),scale=0)rotate([0,0,45])square(2,center=true);
		}
		assembly_shaft_bearings();
		center_over_follower() {
			cylinder(d=9,h=100,center=true);// shaft hole is 9mm to give clearance for hte inner spinny bit of the bearings
		}
	}
}

module screw_mount() {
	difference() {
		linear_extrude(17,center=true,convexity=20) {
			difference() {
				union(){
					circle(d=6);
					translate([0,-3])square([6,6],center=true);
				}
				circle(d=3.5);
			}
		}
		*up(-9)linear_extrude(2.5)M3_nut();
	}
}

module follower_spacer() {
	difference() {
		linear_extrude(4,convexity=3)difference() {
			circle(d=8.5);
			circle(d=6.3);
		}
		chamfer_ring(0.5,8.5);
		up(4)chamfer_ring(0.5	,8.5);
	}
}


module assembly_follower(cutout=false) {
	translate([-r_gear(),0,-follower_width/2])rotate([0,0,-14])follower(cutout=cutout);
}

/*
#linear_extrude(follower_width+walls*2,center=true)offset(chamfer=true,delta=5)hull(){
	center_over_follower()circle(d=17);
	center_over_worm()translate([0,5,0])square([worm_length,r_gear()*2],center=true);
}

hull()center_over_follower()up(-follower_width/2)follower();
hull()center_over_worm()translate([0,5,0])rotate([90,0,0])wormgear();
*/

// show everything all put together
//assembly();

// do these one at a time for printing
housing_front();
//housing_back();
//wormgear(cutout=true);
//housing_front();
//assembly_wheel();
//assembly_shaft_bearings();
//assembly_wormgear();
//assembly_follower();
//assembly_worm_flange();

//wormgear();


//follower();




/*
    c = modul / 6;                                              // Tip Clearance
    r_worm = modul*thread_starts/(2*sin(lead_angle));       // Worm Part-Cylinder Radius
    r_gear = modul*tooth_number/2;                                   // Spur Gear Part-Cone Radius
    rf_worm = r_worm - modul - c;                       // Root-Cylinder Radius
*/