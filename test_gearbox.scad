$fs=0.5; $fa=0.5;

use <common.scad>;
use <gears.scad>;
use <profiles.scad>;
use <lprofiles.scad>;

 
 
 
 module bot_shell() {
	 cylinder(d=222,h=100,center=true);
 }
 
 module gear_pair() {
	bevel_herringbone_gear_pair(modul=2, gear_teeth=24, pinion_teeth=24/2, axis_angle=90, tooth_width=12, bore=3, pressure_angle = 20, helix_angle=10, together_built=true);
 }
 
 
 
 

#difference() {
	linear_extrude(24+8+10)offset(r=10)hull()projection()gear_pair();
	up(5)linear_extrude(24+8+10)offset(r=2)hull()projection()gear_pair();
	up(222/2+24+8+2)rotate([0,90,0])bot_shell();
	
}
 
 
 %up(5)gear_pair();
	 

linear_extrude(12,center=true)motor_mount();