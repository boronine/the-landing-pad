// ============================================================================
// STAIRS - Main staircase accessing the platform
// ============================================================================
// Stairs — a single wide staircase facing the entrance gap head-on,
// with levitating steps and blocky handrails on both sides.
include <parameters.scad>
use <step.scad>

num_steps = 13;

// Stair width fits between the two entrance fence sections on the rectangle.
// It is the total step span, including the curved ends of each step.
stair_width = 184;

// Measured step dimensions, relative to the full stair width (2.14 m):
// thickness (Z) 0.06 m, width along the walking direction (X) 0.30 m
step_thickness = stair_width * (0.06 / 2.14);
step_run = stair_width * (0.30 / 2.14);
platform_edge_x = rect_center_x + rect_x / 2;

// Concrete slope under the stairs, implemented as a skewed box
// Top face (and bottom face) corners lie on the XY plane (Z=0)
slope_width = 40;
measured_slope_run = 367;      // cm (3.67 m)
total_run = measured_slope_run;
slope_start_x = platform_edge_x;
slope_start_z = platform_z - rect_z / 2;  // bottom of entrance platform
slope_end_z = 0;
slope_thickness = 51;  // cm, vertical height of remaining sloped bar
k = total_run / slope_start_z;  // horizontal run per unit rise
color("gray")
translate([slope_start_x + total_run - slope_thickness, -slope_width / 2, 0])
    multmatrix([
        [1, 0, -k, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ])
    cube([slope_thickness, slope_width, slope_start_z]);

// Steps — equidistant, with the entrance platform acting as the 14th step:
// tread surfaces are equally spaced in z, so the platform top is exactly one
// rise above the last step. The staircase is anchored so the top step's near
// face is flush with the platform edge — touching, but not overlapping — and
// x spacing follows the slope's pitch so the steps rest on top of it.
platform_top_z = platform_z + rect_z / 2;
step_rise = platform_top_z / (num_steps + 1);
step_dx = k * step_rise;  // horizontal spacing, parallel to the slope line
color("lightyellow")
for (i = [0 : num_steps - 1]) {
    sz = (i + 1) * step_rise - step_thickness / 2;  // tread at (i + 1) * rise
    sx = platform_edge_x + step_run / 2 + (num_steps - 1 - i) * step_dx;

    step(sx, 0, sz, step_run, stair_width, step_thickness);
}
