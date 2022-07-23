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
	cylinder(d=17,h=6);
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

