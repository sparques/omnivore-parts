$fa=0.5;$fs=0.5;

use <common.scad>

// hub for omni wheels

// all six holes, plus d-shaft, plus hole for grub screw

hub_center_d=12;
hub_center_h=18;

mid_d=28;
mid_h=10;

shaft_d=6;
shaft_flat_w=5.4;

module d_shaft(length) {
	linear_extrude(length,center=true)intersection() {
		circle(d=shaft_d);
		translate([shaft_d-shaft_flat_w,0,0])square(shaft_d,center=true);
	}
}


difference() {
	union() {
		//long bit
		cylinder(h=hub_center_h,d=hub_center_d,center=true);
		// middle bit
		cylinder(h=mid_h,d=mid_d,center=true);
	}

	// d-shaft hole
	d_shaft(hub_center_h+1);
	
	//chamfers
	mirrorz()up(mid_h/2)chamfer_ring(1,mid_d);
	mirrorz()up(hub_center_h/2)chamfer_ring(1,hub_center_d);
	
	// hub holes
	for(t=[0:360/6:360])
		rotate([0,0,t])translate([0,10.5,0])cylinder(d=3.2,h=mid_h+1,center=true);
	
	// grub screw hole for affixing shaft
	rotate([0,90,0])cylinder(h=mid_d+1,d=4,center=true);
}

