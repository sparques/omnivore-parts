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

module motor_flange_holes(shaft=true) {
	if (shaft) {
		circle(d=3.17);
	}
	for(t=[0,90,180,270]) 
		rotate([0,0,t])translate([8,0,0])circle(d=2.85);
}

module M6_flange_holes(shaft=true) {
	for (t=[0:360/4:360])
		rotate([0,0,t])translate([21/2,0,0])circle(d=3);
	if (shaft) {
		circle(d=6);
	}
}


module M3_nut() {
	circle(d=7,$fn=6);
}

module motor_flange_nut_holes() {
	for(t=[0,90,180,270]) 
		rotate([0,0,t])translate([8,0,0])rotate([0,0,0])M3_nut();
}