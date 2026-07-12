// ============================================================================
// STAIRS - Main staircase accessing the platform
// ============================================================================
// Stairs — a single wide staircase facing the entrance gap head-on,
// with levitating steps and blocky handrails on both sides.
include <parameters.scad>
use <step.scad>

num_steps = 13;
step_rise = 16;
step_thickness = 12;
step_run = 28;

// Stair width fits between the two entrance fence sections on the rectangle
stair_width = 184;
platform_edge_x = rect_center_x + rect_x / 2;

// Steps
color("lightyellow")
for (i = [0 : num_steps - 1]) {
    sx = platform_edge_x + (num_steps - i - 0.5) * step_run;
    sz = (i + 0.5) * step_rise;

    // Straight step body
    translate([sx, 0, sz])
        cube([step_run, stair_width, step_thickness], center = true);

    step_side_curve(sx, 0, sz, step_run, stair_width, step_thickness);
}
