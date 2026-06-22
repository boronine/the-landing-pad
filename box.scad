// Fence segment dimensions — all constants are expressed in terms of box_depth (the largest dimension)
// ("box" = fence segment throughout this file)
box_depth = 150; // cm
box_width = box_depth * (725/1466);
box_height = box_depth * (77/733);

// Recess parameters
recess_depth = box_depth * (18/733);
bezel_width_x = box_depth * (61/1466);
bezel_width_y = box_depth * (127/1466);

// Shared clearance value
clearance = box_depth * (43/733);

// Calculated recess dimensions
recess_width = box_width - (2 * bezel_width_x);
recess_depth_y = box_depth - (2 * bezel_width_y);

// Protruding fence segment parameters
protrude_width = box_depth * (33/733);
protrude_depth = box_depth * (137/733);
protrude_height = box_depth * (18/733);
protrude_x_offset = (recess_width/2) - clearance - (protrude_width/2);

// Second protruding fence segment parameters (maximum width with clearance on each side)
protrude2_width = recess_width - (2 * clearance);
protrude2_depth = box_depth * (33/733);
protrude2_height = box_depth * (18/733);
protrude2_y_offset = (recess_depth_y/2) - clearance - (protrude2_depth/2);

// Connecting fence segment parameters (to create C shape)
connect_width = box_depth * (33/733);
connect_depth = protrude2_y_offset - (protrude_depth/2 + clearance);
connect_height = box_depth * (18/733);
connect_y_offset = protrude2_y_offset - (connect_depth/2);

// Oval (elliptical cylinder) — x: 8.9m, y: 11.5m, z: 20cm
oval_x = 890;
oval_y = 1150;
oval_z = 20;

// Rectangle — 220cm x 160cm x 20cm, overlapping the oval's curve on the same plane
// 220cm runs along y (oval's longer side); 160cm protrudes outward in x
rect_x = 160;  // protrusion depth outward from oval
rect_y = 220;  // width along oval's long axis
rect_z = 20;

// The oval + rectangle together form the "platform"

// Gap between the top of the platform and the bottom of the fence segments
gap = 4;

// Inset from the edge of the platform (oval or rectangle) to the fence segments
outer_rim = 10;

// Central column dimensions
cylinder_d = 120;
cylinder_h = 240;

// Position so the left 220cm edge kisses the oval at its corners
rect_center_x = (oval_x / 2) * sqrt(1 - pow(rect_y / oval_y, 2)) + rect_x / 2;

// Platform sits on top of the column (bottom at z = cylinder_h, top at z = cylinder_h + oval_z)
platform_z = cylinder_h + oval_z / 2;

// Platform (oval)
translate([0, 0, platform_z]) {
    linear_extrude(height = oval_z, center = true)
        scale([oval_x / 2, oval_y / 2])
            circle(r = 1, $fn = 128);
}

// Platform (rectangle)
// Left edge corners at (436.8, ±110) sit on the oval boundary
translate([rect_center_x, 0, platform_z]) {
    cube([rect_x, rect_y, rect_z], center = true);
}

module box_shape() {
    // Fence segment geometry ("box" = fence segment)
    union() {
        difference() {
            // Main fence segment body
            cube([box_width, box_depth, box_height], center=true);

            // Recess cutouts on top and bottom using a loop
            for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
                translate([0, 0, z_pos]) {
                    cube([recess_width, recess_depth_y, recess_depth + 0.1], center=true);
                }
            }
        }

        // Protruding fence segments on both sides of top and bottom recess areas
        for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
            for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
                translate([x_pos, 0, z_pos]) {
                    cube([protrude_width, protrude_depth, protrude_height], center=true);
                }
            }
        }

        // Second protruding fence segment on both sides of top and bottom recess areas
        for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
            for (y_pos = [protrude2_y_offset, -protrude2_y_offset]) {
                translate([0, y_pos, z_pos]) {
                    cube([protrude2_width, protrude2_depth, protrude2_height], center=true);
                }
            }
        }

        // Connecting fence segments to create C shape (extending from horizontal boxes toward corner boxes)
        for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
            for (y_pos = [connect_y_offset, -connect_y_offset]) {
                for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
                    translate([x_pos, y_pos, z_pos]) {
                        cube([connect_width, connect_depth, connect_height], center=true);
                    }
                }
            }
        }
    }
}

// Two fence segments sitting on top of the rectangle with a 4cm z-gap
// and a 10cm inset from the rectangle's y-edges
// Rotated so longest side (150cm) runs along x (rectangle edge),
// second-longest side (74.2cm) points up (z), shortest (15.8cm) extends in y
segment_z = cylinder_h + oval_z + gap + box_width / 2;
box_y_offset = rect_y / 2 - outer_rim - box_height / 2;
for (y_pos = [box_y_offset, -box_y_offset]) {
    translate([rect_center_x, y_pos, segment_z]) {
        rotate([0, 0, 90])
            rotate([0, 90, 0])
                box_shape();
    }
}

// Fence segments placed along the oval's perimeter with equal arc-length gaps
// Uses numerical integration to find 20 evenly-spaced positions on the ellipse perimeter
// Longest side (150cm) runs tangentially, shortest (15.8cm) points radially
// Center is pushed inward by outer_rim + box_height/2 so the fence edge
// (not the center) is outer_rim from the platform boundary
a = oval_x / 2;
b = oval_y / 2;
n_segments = 20;

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
target_arc = total_perimeter / n_segments;

// Find theta via linear interpolation in the arc_table
function find_theta(target, i) =
    i >= len(arc_table) - 1 ? 360 :
    arc_table[i + 1] >= target ?
        i * step_deg + (target - arc_table[i]) / (arc_table[i + 1] - arc_table[i]) * step_deg :
    find_theta(target, i + 1);

// The entrance (rectangle) blocks fence segments near the 3 o'clock position.
entrance_half_angle = atan2(rect_y / 2, rect_center_x - rect_x / 2);

for (i = [0 : n_segments - 1]) {
    target = i * target_arc;
    theta = find_theta(target, 0);
    // Skip the segment centered within the entrance opening (3 o'clock)
    // and the 5 segments on the opposite side (9 o'clock)
    if (theta > entrance_half_angle && theta < 360 - entrance_half_angle
        && !(i >= 8 && i <= 12)) {
        inset_x = (a - outer_rim - box_height / 2) * cos(theta);
        inset_y = (b - outer_rim - box_height / 2) * sin(theta);
        alpha = atan2(oval_x * sin(theta), oval_y * cos(theta));
        translate([inset_x, inset_y, segment_z]) {
            rotate([0, 0, alpha])
                rotate([0, 90, 0])
                    box_shape();
            }
        }
    }

// Transition shape: interpolates from the middle of the column (circle)
// to the bottom of the platform (ellipse) with an inward-curved profile.
// Uses pow(t, 2) so the waist stays narrow near the column,
// then flares outward to meet the elliptical platform.

// Non-linear blend: p>1 → inward curve (concave), p=1 → linear cone
function blend(t) = pow(t, 3);

n_transition = 30;
transition_z0 = cylinder_h / 2;
transition_z1 = cylinder_h;
transition_dz = (transition_z1 - transition_z0) / n_transition;

// Radii at a given z parameter t (0 = bottom/circle, 1 = top/ellipse)
function rx_at(t) = cylinder_d / 2 + (oval_x / 2 - cylinder_d / 2) * blend(t);
function ry_at(t) = cylinder_d / 2 + (oval_y / 2 - cylinder_d / 2) * blend(t);

color("lightblue")
for (i = [0 : n_transition - 1]) {
    z0 = transition_z0 + i * transition_dz;
    z1 = z0 + transition_dz;
    t0 = i / n_transition;
    t1 = (i + 1) / n_transition;

    rx0 = rx_at(t0);
    ry0 = ry_at(t0);
    rx1 = rx_at(t1);
    ry1 = ry_at(t1);

    hull() {
        translate([0, 0, z0])
            scale([rx0, ry0, 1])
                cylinder(r = 1, h = 0.2, center = true, $fn = 128);
        translate([0, 0, z1])
            scale([rx1, ry1, 1])
                cylinder(r = 1, h = 0.2, center = true, $fn = 128);
    }
}

// Central cylinder — diameter 120cm, height 240cm
translate([0, 0, cylinder_h / 2]) {
    cylinder(d = cylinder_d, h = cylinder_h, center = true, $fn = 128);
}
