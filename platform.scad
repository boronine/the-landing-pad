// ============================================================================
// PLATFORM - Ellipse and rectangle base on top of column
// ============================================================================
include <parameters.scad>

// Platform (ellipse)
translate([0, 0, platform_z]) {
    linear_extrude(height = ellipse_z, center = true)
        scale([a, b])
            circle(r = 1);
}

// Platform entrance (rectangle) - where people step when they finish the stairs
translate([rect_center_x, 0, platform_z]) {
    cube([rect_x, rect_y, rect_z], center = true);
}

// Ridge - attached to the bottom of the platform, spanning from the platform
// center (x=0) to the opposite end of the platform entrance (x = rect_center_x + rect_x/2)
ridge_x = rect_center_x + rect_x / 2;
ridge_y = 40;
ridge_z = 16;
translate([ridge_x / 2, 0, platform_z - ellipse_z / 2 - ridge_z / 2]) {
    cube([ridge_x, ridge_y, ridge_z], center = true);
}
