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
// Steps are enlarged by 2% in all directions (applied twice), then by
// another 5%; the other step dimensions are derived from stair_width, so
// they scale along with it.
step_scale = 1.02 * 1.02 * 1.05;
stair_width = 184 * step_scale;

// Measured step dimensions, relative to the full stair width (2.14 m):
// thickness (Z) 0.06 m, width along the walking direction (X) 0.30 m,
// total side-profile height including the upward-curving ends (Z) 0.70 m
step_thickness = stair_width * (0.06 / 2.14);
step_run = stair_width * (0.30 / 2.14);
step_height = stair_width * (0.70 / 2.14);
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
step_x = function (i) platform_edge_x + step_run / 2 + (num_steps - 1 - i) * step_dx;
color("lightyellow")
for (i = [0 : num_steps - 1]) {
    sz = (i + 1) * step_rise - step_thickness / 2;  // tread at (i + 1) * rise

    step(step_x(i), 0, sz, step_run, stair_width, step_thickness, step_height);
}

// Railings — one thin box per side, sloping along the stair pitch, raised
// above the steps' upturned sides on little vertical pillars (one per step).
rail_y = (stair_width - step_thickness) / 2;  // center of the vertical side bars
rail_angle = atan2(step_rise, step_dx);       // stair pitch
rail_raise = step_thickness * 3;              // rail centerline above the side tops
pillar_w = step_thickness * 0.75;

// Tops of the steps' side extensions, and the raised rail centerline height
side_top_z = function (i) (i + 1) * step_rise - step_thickness + step_height;
rail_z = function (x) side_top_z(0) + rail_raise + (step_x(0) - x) / k;
rail_len = sqrt(pow(step_x(0) - step_x(num_steps - 1), 2)
              + pow(side_top_z(num_steps - 1) - side_top_z(0), 2)) + step_run;

color("lightyellow")
for (y_side = [-1, 1]) {
    translate([(step_x(0) + step_x(num_steps - 1)) / 2,
               y_side * rail_y,
               (side_top_z(0) + side_top_z(num_steps - 1)) / 2 + rail_raise])
        rotate([0, rail_angle, 0])
            cube([rail_len, step_thickness, step_thickness], center = true);

    // Pillars — embedded halfway into the side bar top, reaching up to the
    // railing centerline so they intersect the rail's lower half
    for (i = [0 : num_steps - 1]) {
        px = step_x(i);
        z0 = side_top_z(i) - step_thickness / 2;
        z1 = rail_z(px);
        translate([px, y_side * rail_y, (z0 + z1) / 2])
            cube([pillar_w, pillar_w, z1 - z0], center = true);
    }
}
