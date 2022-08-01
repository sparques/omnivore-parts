use <profiles.scad>
use <lprofiles.scad>
use <common.scad>

 module motor() {
	 cylinder(d=28,h=46.5);
	 linear_extrude(60.5)d_shaft(3.3,3);
 }
 
 module bot_shell() {
	 rotate_extrude()difference() {
		 bowl_profile();
		translate([-0.5,-0.5,0])offset(-0.5)bowl_profile();
	 }
	 
 }
 

 module omniwheel() {
	cylinder(d=60,h=25.5);
 }
 
 
 // bearing for 6 mm shafts
 module bearing_M6() {
	cylinder(d=17.3,h=6.1);
 }
 
 // the head of my M3 screws
 module M3_head() {
	 cylinder(d=5.5,h=3);
}

module motor_mount_screws() {
	// motor actually takes M3 screws, but make M4 holes
	linear_extrude(20){
		mirrorx()translate([19/2,0,0])M4();
		mirrory()translate([0,16/2,0])M4();
		M4();
	}

	mirrorx()translate([19/2,0,0])M3_head();
	mirrory()translate([0,16/2,0])M3_head();
}

// screw holes go down; head-holes go up
module motor_mount_screws2(screw_length,head_length) {
	// motor actually takes M3 screws, but make M4 holes
	mirror([0,0,1])linear_extrude(screw_length){
		mirrorx()translate([19/2,0,0])M4();
		mirrory()translate([0,16/2,0])M4();
		M4();
	}

	mirrorx()translate([19/2,0,0])cylinder(h=head_length,d=5.5);
	mirrory()translate([0,16/2,0])cylinder(h=head_length,d=5.5);
	linear_extrude(head_length)M4();
}

motor_mount_screws2(30,10);