include <shared_vars.scad>;
include <../shape_primitives.scad>;


module vat(r_lense_lip=vat_r_lense_lip,
           h_lense_lip=vat_h_lense_lip,
           z_lense_lip_offset=vat_z_lense_lip_offset,
           r_o=vat_r_o,
           r_i=vat_r_i,
           h=vat_h,
           z_holder=vat_z_holder,
           w_holder=vat_holder_width,
           angle_holder=vat_holder_angle,
           r_o_hinge=vat_hinge_r_o,
           r_i_hinge=r_608zz,
           thickness_hinge=vat_hinge_thickness,
           y_offset_hinge=vat_hinge_y_offset,
           x_offset_hinge=vat_hinge_x_offset,
           r_m8_bolt=m8_bolt_radius,
          ) {

  module _vat_hinge() {
    // hinge
    difference() {
      hull() {
        translate([-r_o/2 + (r_o - r_i)/2 + x_offset_hinge, y_offset_hinge, 0])
          cube([r_o, thickness_hinge, h], center=true);
        translate([-r_o - r_o_hinge + x_offset_hinge, y_offset_hinge, 0])
        rotate([90, 0, 0])
          cylinder(r=r_o_hinge, h=thickness_hinge, center=true);
      }
    // hinge bearing hole
    translate([-r_o - r_o_hinge + x_offset_hinge, y_offset_hinge, 0])rotate([90, 0, 0])
      cylinder(r=r_i_hinge, h=thickness_hinge+r_o, center=true);
    }
  }

  // main body of vat with handle for tilt mechanism
  difference() {
    union() {
      hull() {
        // main body
        cylinder(r=r_o, h=h, center=true);
        // slanted bolt holder
        translate([r_o + w_holder/2, 0, -z_holder/2])
          cube([w_holder, 10, h-z_holder], center=true);
      }
      _vat_hinge();
      mirror([0, 1, 0]) _vat_hinge();
    }
    // remove corner caused by vat_hinge hull
    translate([0, 0, -h])
      cylinder(r=r_o, h=h, center=true);
    // hollow out center
    cylinder(r=r_i, h=h+2*r_o_hinge, center=true);
    // holder bolt hole
    translate([r_o + w_holder/2, 0, 0])rotate([0, angle_holder, 0])
      cylinder(r=r_m8_bolt, h=2*h, center=true);
  }
  translate([0, 0, (-h+h_lense_lip)/2 + z_lense_lip_offset])
    donut(r_o, r_lense_lip, h_lense_lip, $fn=$fn, center=true);
}

module 2Dhinge() {
  translate([-hinge_r_o, 0, 0])
    donut(hinge_r_o, hinge_r_i, h=hinge_h, center=true);
  translate([hinge_r_o, 0, 0]) rotate([90, 0, 0])
    donut(hinge_r_o, hinge_r_i, h=hinge_h, center=true);

  cube([2*hinge_thick, hinge_h, hinge_h], center=true);
}

module hinge_mount() {
  extrusion_conn = (xy_extrusion+2*thickness);
  module _extrusion_mount() {
    difference() {
      cube([extrusion_conn, extrusion_conn, 30+hinge_h], center=true);
      cube([xy_extrusion, xy_extrusion, xy_extrusion*2+hinge_h + 1], center=true);
      // bolt holes
      for (angle=[0, 1], z_mirror=[-1, 1]) translate([0, 0, z_mirror*(30)/2])
        rotate([[1, 0][angle] * 90, angle*90, 0])
          cylinder(r=m5_bolt_radius, h=xy_extrusion+1 + hinge_h, center=true);
    }
  }
  module _hinge_mount() {
    donut(hinge_r_o, hinge_r_i, hinge_h, center=true);
  }

  _hinge_mount();
  translate([-2*hinge_r_o, 0, 0])
    _extrusion_mount();
  // hinge to extrusion connector
  translate([-hinge_r_o/2, 0, 0])
    difference() {
      cube([hinge_thick + thickness + hinge_r_o, extrusion_conn, hinge_h], center=true);
      translate([hinge_thick + thickness, 0, 0])
        cylinder(r=hinge_r_i, h=hinge_h + 1, center=true);
    }
}
