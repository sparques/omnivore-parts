use <common.scad>;


$fa=0.5; $fs=0.5;

module M3() {
	circle(d=3);
}



module M4() {
	circle(d=4);
}

module motor_mount() {
	// motor actually takes M3 screws, but make M4 holes
	mirrorx()translate([19/2,0,0])M4();
	mirrory()translate([0,16/2,0])M4();
	M4();
}

module bowl_profile() {
	import("bowl_profile.svg");
}