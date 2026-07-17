include <parameters.scad>
use <section_shape.scad>

// ============================================================================
// FENCE SECTIONS - Placement along the platform perimeter
// ============================================================================

// Two fence sections sitting on top of the rectangle
section_z = column_h + ellipse_z + gap + section_width / 2;
section_y_offset = rect_y / 2 - outer_rim - section_height / 2;

// Pillars under each fence section — little vertical boxes bridging the gap
// between the platform top and the section bottom, so each section stands on
// top of two pillars. They are embedded slightly into both for a solid union.
fence_pillar_w = section_height / 2;
fence_pillar_offset = section_depth / 3;  // along the section's length
fence_pillar_embed = gap / 2;
fence_pillar_h = gap + 2 * fence_pillar_embed;
fence_pillar_z = column_h + ellipse_z + gap / 2;  // centered in the gap

module section_pillars() {
    // Offset along local y — the sections' long axis before the z-rotation
    for (y_off = [-fence_pillar_offset, fence_pillar_offset])
        translate([0, y_off, 0])
            cube([fence_pillar_w, fence_pillar_w, fence_pillar_h], center = true);
}

for (y_pos = [section_y_offset, -section_y_offset]) {
    translate([rect_center_x, y_pos, section_z]) {
        rotate([0, 0, 90])
            rotate([0, 90, 0])
                section_shape();
    }
    translate([rect_center_x, y_pos, fence_pillar_z])
        rotate([0, 0, 90])
            section_pillars();
}

// Fence sections placed along the ellipse's perimeter with equal arc-length gaps
for (i = [0 : n_sections - 1]) {
    target = i * target_arc;
    theta = find_theta(target, 0);
    // Skip the section centered within the entrance opening (3 o'clock)
    // and the 5 sections on the opposite side (9 o'clock)
    if (theta > entrance_half_angle && theta < 360 - entrance_half_angle
        && !(i >= 8 && i <= 12)) {
        inset_x = (a - outer_rim - section_height / 2) * cos(theta);
        inset_y = (b - outer_rim - section_height / 2) * sin(theta);
        alpha = atan2(ellipse_x * sin(theta), ellipse_y * cos(theta));
        translate([inset_x, inset_y, section_z]) {
            rotate([0, 0, alpha])
                rotate([0, 90, 0])
                    section_shape();
        }
        translate([inset_x, inset_y, fence_pillar_z])
            rotate([0, 0, alpha])
                section_pillars();
    }
}
