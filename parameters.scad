// 1000 was very slow on another machine
$fn = 1000;

// Fence segment dimensions — section_width and section_height are shared across
// components; the detailed recess/protrusion geometry lives in section_shape.scad.
section_depth = 150; // cm
section_width = section_depth * (725/1466);
section_height = section_depth * (77/733);

// Ellipse dimensions
ellipse_x = 890;
ellipse_y = 1150;
ellipse_z = 20;

// Rectangle — 220cm x 160cm, overlapping the ellipse's curve on the same plane
rect_x = 160;
rect_y = 220;

// The ellipse + rectangle together form the "platform"

// Gap between the top of the platform and the bottom of the sections
gap = 4;

// Central column dimensions
column_d = 120;
column_h = 240;

// Position so the left 220cm edge kisses the ellipse at its corners
rect_center_x = (ellipse_x / 2) * sqrt(1 - pow(rect_y / ellipse_y, 2)) + rect_x / 2;

// Platform sits on top of the column (bottom at z = column_h, top at platform_top)
platform_top = column_h + ellipse_z;

// ============================================================================
// ELLIPSE ARC-LENGTH UTILITIES — shared between fence sections and back wall
// ============================================================================
a = ellipse_x / 2;
b = ellipse_y / 2;
n_sections = 20;

// Fence section indices in this (inclusive) range are omitted and covered by the back wall.
back_wall_first = 8;
back_wall_last = 12;

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
