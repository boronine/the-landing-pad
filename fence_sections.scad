include <parameters.scad>
use <section_shape.scad>

// ============================================================================
// FENCE SECTIONS - Placement along the platform perimeter
// ============================================================================

// Inset from the edge of the platform (ellipse or rectangle) to the sections
outer_rim = 10;

// The entrance (rectangle) blocks fence sections near the 3 o'clock position.
entrance_half_angle = atan2(rect_y / 2, rect_center_x - rect_x / 2);

// Two fence sections sitting on top of the rectangle
section_z = platform_top + gap + section_width / 2;
fence_inset = outer_rim + section_height / 2;   // edge-of-platform inset to a section's center
section_y_offset = rect_y / 2 - fence_inset;
for (y_pos = [section_y_offset, -section_y_offset]) {
    translate([rect_center_x, y_pos, section_z]) {
        rotate([0, 0, 90])
            rotate([0, 90, 0])
                section_shape();
    }
}

// Fence sections placed along the ellipse's perimeter with equal arc-length gaps
for (i = [0 : n_sections - 1]) {
    target = i * target_arc;
    theta = find_theta(target, 0);
    // Skip the section centered within the entrance opening (3 o'clock)
    // and the sections covered by the back wall (9 o'clock)
    if (theta > entrance_half_angle && theta < 360 - entrance_half_angle
        && !(i >= back_wall_first && i <= back_wall_last)) {
        inset_x = (a - fence_inset) * cos(theta);
        inset_y = (b - fence_inset) * sin(theta);
        alpha = atan2(ellipse_x * sin(theta), ellipse_y * cos(theta));
        translate([inset_x, inset_y, section_z]) {
            rotate([0, 0, alpha])
                rotate([0, 90, 0])
                    section_shape();
        }
    }
}
