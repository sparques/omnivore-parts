$fa=0.5; $fs=0.5;

use <common.scad>;


coupler_d=12;

difference() {

cylinder(d=coupler_d,h=19.99,center=true);

// motor shaft
up(-5)d_shaft(10,3.3,3);

// wheel shaft
up(5)d_shaft(10,6,5.4);

mirrorz()up(5)rotate([0,90,0])cylinder(d=4,h=coupler_d+1,center=true);
}