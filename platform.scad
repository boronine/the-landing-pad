// ============================================================================
// PLATFORM - Ellipse and rectangle base on top of column
// ============================================================================
include <parameters.scad>

rect_z = 20; // platform slab thickness
platform_z = platform_top - ellipse_z / 2;

// Platform (ellipse)
translate([0, 0, platform_z]) {
    linear_extrude(height = ellipse_z, center = true)
        scale([a, b])
            circle(r = 1);
}

// Platform (rectangle)
translate([rect_center_x, 0, platform_z]) {
    cube([rect_x, rect_y, rect_z], center = true);
}
