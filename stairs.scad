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

    // Quick-and-dirty concrete slope under the stairs (same width as ridge)
    // Extends from platform entrance down to ground
    // Measurements from site: run (width) 3.67 m (height matches bottom of entrance platform)
    slope_width = 40;
    measured_slope_run = 367;      // cm (3.67 m)
    total_run = measured_slope_run;
    slope_start_x = platform_edge_x;
    slope_start_z = platform_z - rect_z / 2;  // bottom of entrance platform
    slope_end_z = 0;

    // Sloped bar: subtract a second identical triangle shifted down 51 cm vertically
    slope_thickness = 51;  // cm, vertical height of remaining sloped bar
    color("gray")
    translate([slope_start_x, 0, 0])
        rotate([90, 0, 0])
            linear_extrude(height = slope_width, center = true, convexity = 4)
                difference() {
                    polygon(points = [
                        [0, 0],
                        [0, slope_start_z],
                        [total_run, slope_end_z]
                    ]);
                    translate([0, -slope_thickness])
                        polygon(points = [
                            [0, 0],
                            [0, slope_start_z],
                            [total_run, slope_end_z]
                        ]);
                }
