// 1000 was very slow on another machine
$fn = 100;

// Fence segment dimensions — all constants are expressed in terms of section_depth (the largest dimension)
section_depth = 150; // cm
section_width = section_depth * (725/1466);
section_height = section_depth * (77/733);

// Recess parameters
recess_depth = section_depth * (18/733);
bezel_width_x = section_depth * (61/1466);
bezel_width_y = section_depth * (127/1466);

// Shared clearance value
clearance = section_depth * (43/733);

// Calculated recess dimensions
recess_width = section_width - (2 * bezel_width_x);
recess_depth_y = section_depth - (2 * bezel_width_y);

// Protruding section parameters
protrude_width = section_depth * (33/733);
protrude_depth = section_depth * (137/733);
protrude_height = section_depth * (18/733);
protrude_x_offset = (recess_width/2) - clearance - (protrude_width/2);

// Second protruding section parameters (maximum width with clearance on each side)
protrude2_width = recess_width - (2 * clearance);
protrude2_depth = section_depth * (33/733);
protrude2_height = section_depth * (18/733);
protrude2_y_offset = (recess_depth_y/2) - clearance - (protrude2_depth/2);

// Connecting section parameters (to create C shape)
connect_width = section_depth * (33/733);
connect_depth = protrude2_y_offset - (protrude_depth/2 + clearance);
connect_height = section_depth * (18/733);
connect_y_offset = protrude2_y_offset - (connect_depth/2);

// Ellipse dimensions
ellipse_x = 890;
ellipse_y = 1150;
ellipse_z = 20;

// Rectangle — 220cm x 160cm x 20cm, overlapping the ellipse's curve on the same plane
rect_x = 160;
rect_y = 220;
rect_z = 20;

// The ellipse + rectangle together form the "platform"

// Gap between the top of the platform and the bottom of the sections
gap = 4;

// Inset from the edge of the platform (ellipse or rectangle) to the sections
outer_rim = 10;

// Central column dimensions
column_d = 120;
column_h = 240;

// Position so the left 220cm edge kisses the ellipse at its corners
rect_center_x = (ellipse_x / 2) * sqrt(1 - pow(rect_y / ellipse_y, 2)) + rect_x / 2;

// Platform sits on top of the column (bottom at z = column_h, top at z = column_h + ellipse_z)
platform_z = column_h + ellipse_z / 2;

// ============================================================================
// ELLIPSE ARC-LENGTH UTILITIES — shared between fence sections and back wall
// ============================================================================
a = ellipse_x / 2;
b = ellipse_y / 2;
n_sections = 20;

// Arc-length integrand at angle t (degrees)
function ds(t) = sqrt(pow(a * sin(t), 2) + pow(b * cos(t), 2));

// Build table of 360 cumulative arc-length values (1° resolution)
n_fine = 360;
step_deg = 360 / n_fine;
step_rad = step_deg * PI / 180;

// Recursive cumsum: returns [cum_arc_0, cum_arc_1, ..., cum_arc_n]
function cumsum(i, acc, result) =
    i > n_fine ? result :
    let(d = ds(i * step_deg) * step_rad,
        new_acc = acc + d)
    cumsum(i + 1, new_acc, concat(result, [new_acc]));

arc_table = cumsum(1, 0, [0]);
total_perimeter = arc_table[len(arc_table) - 1];
target_arc = total_perimeter / n_sections;

// Find theta via linear interpolation in the arc_table
function find_theta(target, i) =
    i >= len(arc_table) - 1 ? 360 :
    arc_table[i + 1] >= target ?
        i * step_deg + (target - arc_table[i]) / (arc_table[i + 1] - arc_table[i]) * step_deg :
    find_theta(target, i + 1);

// The entrance (rectangle) blocks fence sections near the 3 o'clock position.
entrance_half_angle = atan2(rect_y / 2, rect_center_x - rect_x / 2);

// Convert parametric angle to geometric angle for angular cuts
function param_to_geom(theta) = let(
    g = atan2(b * sin(theta), a * cos(theta))
) g < 0 ? g + 360 : g;

// Helper: 2D pie-slice polygon for angular cutting
module pie_slice(r, angle_start, angle_end) {
    polygon(concat(
        [[0, 0]],
        [for (a = [angle_start : 1 : angle_end]) [r * cos(a), r * sin(a)]]
    ));
}
