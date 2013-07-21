include <../shape_primitives.scad>;
include <shared_vars.scad>;


module build_platform() {
translate([0, y_offset_build_platform, z_offset_build_platform]) {
  cylinder(r=r_platform, h=thickness_platform);
  // shaft connecting top to bottom
  cylinder(r=r_platform_shaft, h=h_platform_shaft);
  translate([0, 0, h_platform_shaft + z_platform_mount/2]) {
    difference() {
    // top mount connecting to z axis
        cube(xyz_platform_mount, center=true);
      // screw holes
      for (sign = [-1, 1])
      translate([0, sign * dist_between_platform_mount_screws/2, 0])
        cylinder(r=m3_bolt_radius, h=z_platform_mount + 1, center=true);
    }
  }
}
}

module rod_to_extrusion_stabilizing_mount(with_flap=false, flap_side=1) {
  // flap_side: -1 means to left.  1 means to right
  module _flap() {
        difference() {
          cube([thickness, xy_extrusion, rod_mount_length+r_rod_holder], center=true);
        for (sign=[-1.2,1.2, -.5, .5]) {
          translate([0, 0, sign*xy_extrusion])rotate([0, 90, 0])
            cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
      }}}
  difference () {
    union () {
      for (sign=[-1, 1]) {
        translate ([0, 0, sign*(rod_mount_length)/2])
        rod_mount();
        if (with_flap) {
        translate([r_rod_holder, flap_side*xy_extrusion, 0])_flap();
    }}}
    for (sign=[-1, 1]) {
      translate ([xy_extrusion/2, 0, sign*(rod_mount_length - xy_extrusion/2 + 5/2)])
      cube([xy_extrusion+5, 5+xy_extrusion, xy_extrusion+5], center=true);
    }
  }
}

module rod_mount(mount_angle=0, r_i=r_lm8uu) {
  difference () {
    union () {
      U(r_rod_holder, r_i, r_rod_holder+thickness, r_rod_holder);
      translate ([r_rod_holder, 0, 0])rotate([mount_angle, 0, 0])
        cube ([thickness, xy_extrusion, rod_mount_length], center=true);
    }
    // screw holes
    rotate([mount_angle, 0, 0])
    rotate([0, 90, 0])for (sign=[1, -1])
      translate([sign*(rod_mount_length-xy_extrusion)/2, 0, 1])
        cylinder(r=m5_bolt_radius, h=2*r_rod_holder+thickness, center=true);
  }
}

module rod_fastening_mount(female_end=-1) {
difference() {
  union() {
  rod_mount(90, r_smooth_rod);
  // platform for bolts on male side
  for (mirror=[-1, 1])
    translate([-r_smooth_rod*2-thickness,
               mirror*(r_rod_holder - r_smooth_rod),
               0])
    rotate([0, 90, 0])
    cylinder(r=.15+m3_bolt_radius+abs(thickness-m3_bolt_radius), h=r_rod_holder, center=false);
  }
  translate ([female_end*r_rod_holder, 0, 0])
    cube([2*r_rod_holder, 2*r_rod_holder +2*xy_extrusion, 2*r_rod_holder], center=true);
  for (mirror=[-1, 1]){
    // bolt holes
    translate([0, mirror*(r_rod_holder-r_smooth_rod), 0]) {
      rotate([0, 90, 0])
        cylinder (h=2*r_rod_holder+thickness+1, r=.15+m3_bolt_radius, center=true);
      // nut traps for female side
      translate([r_rod_holder - thickness, 0, r_rod_holder/2 - m3_nut_width])
        cube([m3_nut_height, m3_nut_width, r_rod_holder], center=true);
  }}
}
}

module lead_screw_nut_mount() {
  module _lead_screw_mount_plate() {
  difference() {
  U(r_lead_screw_nut_flange, r_i_lead_screw_nut_flange,
    r_lead_screw_nut_flange+2*thickness, 2*thickness);
  for (ang=[45:90:360])rotate([0, 0, ang]) translate([r_screwhole_lead_screw_nut_flange, 0, 0])
    cylinder(r=m5_bolt_radius, h=2*thickness+1, center=true);
  }}
  module _extrusion_mount() {
  difference() {
  cube([thickness, max(r_lead_screw_nut_flange, 2*xy_extrusion), xy_extrusion+2*thickness], center=true);
  for (mirror=[-1, 1]) translate([0, 1/2*xy_extrusion*mirror, 2*thickness])
  rotate([0, 90, 0])cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
  }}
  _lead_screw_mount_plate();
  translate([r_lead_screw_nut_flange + thickness, 0, (xy_extrusion)/2])
    _extrusion_mount();
}

/////////
h_lead_screw_spacer = 8;
r_lead_screw_sleeve_bearing = 12.72/2;
h_lead_screw_sleeve_bearing = 12.72;

module lead_screw_spacer() {
  donut(m5_bolt_radius+3, m5_bolt_radius+1.5, h_lead_screw_spacer);
}

module lead_screw_mount() {
  U(r_lead_screw_sleeve_bearing + 10, r_lead_screw_sleeve_bearing,
    r_lead_screw_nut_flange+2*thickness, h_lead_screw_sleeve_bearing);
  translate([r_lead_screw_nut_flange, 0, 0]){
  cube([thickness,2*r_lead_screw_nut_flange+2*xy_extrusion,  xy_extrusion], center=true);
  for (mirror=[-1, 1]) translate([0, mirror*(r_lead_screw_nut_flange+xy_extrusion/2), 0])
    rotate([90, 0, 0])cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
}}

module extrusion_support() {
  module face(extra_length=0) {
    difference() {
    cube([xy_extrusion+extra_length, thickness, xy_extrusion], center=true);
    translate([extra_length/2, 0, 0])rotate([90, 0, 0])
    cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
    }
  }
  module side() {
    translate([(xy_extrusion)/-2, xy_extrusion/2, 0]) {
      difference() {
      cube([thickness, xy_extrusion+thickness, xy_extrusion], center=true);
      translate([0, -thickness, 0])rotate([0, 90, 0]) cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
      }
    }
  }
  for (mirror=[-1, 1]) {
    translate([mirror*xy_extrusion, 0, 0]) 
    translate([5*mirror, 0, 0])rotate([0, (mirror-1)*-90, 0])face(10);
  }
  translate([thickness/-2, 0, 0])
  side();
  translate([thickness/2 + xy_extrusion, 0,  0])
    side();
  translate([0, xy_extrusion, 0])
    face();
}

module extrusion_vertical_support() {
  // a chiral object, so dont expect it to work on both sides
  len = extrusion_support_length;
  angle = extrusion_support_angle;
  rotate([0, angle, 0]) {
    cube([xy_extrusion, thickness, len], center=false);
      rotate([0, angle, 0]) {
      difference() {
      cube([xy_extrusion, xy_extrusion, thickness], center=false);
      translate([xy_extrusion/2, xy_extrusion/2, thickness/2])
        rotate(90)cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
      }}
      translate([0, thickness, 0]) rotate([0, 90, -90])
        translate([.001, 0, 0]) // make valid 2-manifold
        pie_slice(xy_extrusion, abs(angle), thickness);
    translate ([0, 0, len]) {
      rotate([0, angle, 0]) translate([0, -xy_extrusion+thickness, 0]) {
      difference() {
      cube([thickness, xy_extrusion, xy_extrusion], center=false);
      translate([thickness/2, xy_extrusion/2, xy_extrusion/2])
        rotate([0, 90, 0])cylinder(r=m5_bolt_radius, h=thickness+1, center=true);
      }}
     //connection
     rotate([-90, 360-90, 0])
     translate([0, .001, 0]) // make valid 2-manifold
     pie_slice(xy_extrusion, 90-abs(angle), thickness);
    }
  }
}

module _sq() {
  difference() {
  cube([xy_extrusion, thickness, xy_extrusion], center=true);
  rotate([90, 0, 0])cylinder (h=thickness+1, r=m5_bolt_radius, center=true);
  }
}

module extrusion_corner_support(chirality=-1) {
  _sq();
  translate([0, 0, xy_extrusion])_sq();
  translate([chirality*(xy_extrusion-thickness)/2, xy_extrusion/2, 0])rotate([0, 0, 90]) {
    _sq();
    // add an extra screw hole to fit normal hex screws
    translate([xy_extrusion, 0, 0])_sq();}
}

module extrusion_T_support() {
  for (i=[-1:1]) {
    translate([i*xy_extrusion, 0, 0])_sq();
    translate([0, 0, (i+1)*xy_extrusion])_sq();
}}
