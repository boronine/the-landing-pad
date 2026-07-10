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

// Wall at the back of the oval — a continuous curved wall following the oval's contour,
// covering the region where fence segments 8–12 were removed.
// Taller than the fence and flush with the outer edge of the platform.
wall_height = 240;            // 2.4m tall
wall_thickness = box_height;  // same radial thickness as fence segments

module back_wall(start_angle, end_angle) {
    // Wall rises vertically from the platform edge — outer face flush with platform edge,
    // thickness extends inward, bottom sits directly on the platform surface.
    translate([0, 0, cylinder_h + oval_z + wall_height / 2]) {
        linear_extrude(height = wall_height, center = true) {
            intersection() {
                difference() {
                    // Outer boundary — exactly at the platform edge
                    scale([a, b])
                        circle(r = 1, $fn = 256);
                    // Inner boundary — thickness goes inward from the edge
                    scale([a - wall_thickness, b - wall_thickness])
                        circle(r = 1, $fn = 256);
                }
                // Angular wedge to cover only the gap between existing fence segments
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
    }
}

// Helper: 2D pie-slice polygon for angular cutting
module pie_slice(r, angle_start, angle_end) {
    polygon(concat(
        [[0, 0]],
        [for (a = [angle_start : 1 : angle_end]) [r * cos(a), r * sin(a)]]
    ));
}

// Roof over the wall — 1m deep, extending inward from the top of the wall
roof_depth = 40;  // 0.4m inward
roof_thickness = box_height;  // same thickness as the wall

module back_roof(start_angle, end_angle) {
    // Sits on top of the wall
    translate([0, 0, cylinder_h + oval_z + wall_height + roof_thickness / 2]) {
        linear_extrude(height = roof_thickness, center = true) {
            intersection() {
                difference() {
                    // Outer edge — flush with wall outer face (platform edge)
                    scale([a, b])
                        circle(r = 1, $fn = 256);
                    // Inner edge — 1m inward from the outer edge
                    scale([a - roof_depth, b - roof_depth])
                        circle(r = 1, $fn = 256);
                }
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
    }
}

// Lip hanging down from the inner edge of the roof
lip_height = box_height;      // downward extension
lip_thickness = box_height;   // radial thickness

module roof_lip(start_angle, end_angle) {
    // Hangs from the roof bottom, inner face flush with roof inner edge,
    // lip extends outward underneath the roof toward the wall.
    translate([0, 0, cylinder_h + oval_z + wall_height - lip_height / 2]) {
        linear_extrude(height = lip_height, center = true) {
            intersection() {
                difference() {
                    // Outer edge — extends outward under the roof toward the wall
                    scale([a - roof_depth + lip_thickness, b - roof_depth + lip_thickness])
                        circle(r = 1, $fn = 256);
                    // Inner edge — flush with the roof's inner edge
                    scale([a - roof_depth, b - roof_depth])
                        circle(r = 1, $fn = 256);
                }
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
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

// Back wall — covers the gap left by removed fence segments 8–12.
// Boundaries are the midpoints between segments 7-8 and 12-13 to avoid overlap.
// find_theta returns parametric angles; convert to geometric for the pie-slice cut.
function param_to_geom(theta) = let(
    g = atan2(b * sin(theta), a * cos(theta))
) g < 0 ? g + 360 : g;

back_wall_start = param_to_geom(find_theta(7.5 * target_arc, 0));
back_wall_end   = param_to_geom(find_theta(12.5 * target_arc, 0));

color("lightgreen")
    back_wall(back_wall_start, back_wall_end);

color("lightblue")
    back_roof(back_wall_start, back_wall_end);

color("lightblue")
    roof_lip(back_wall_start, back_wall_end);

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

// Stairs — a single wide staircase facing the entrance gap head-on,
// with levitating steps and blocky handrails on both sides.
num_steps = 7;
total_rise = cylinder_h + oval_z;  // 260cm ground to platform top
step_rise = total_rise / num_steps; // ~37.1cm vertical spacing
step_thickness = step_rise * 0.4;  // ~14.9cm — thinner levitating steps
step_run = 34;

// Stair width fits between the two entrance fence segments on the rectangle
stair_width = rect_y - 2 * outer_rim - box_height;
platform_edge_x = rect_center_x + rect_x / 2;

// Railing parameters — thinner, matching fence thickness (box_height ≈ 15.8cm)
post_r = box_height / 2;     // ~7.9cm radius → 15.8cm square posts
rail_r = box_height * 0.35;  // ~5.5cm radius → 11cm square handrail
handrail_h = 85;             // handrail height above step surface
post_inset = 6;              // inset from stair edge

module stair_railing() {
    for (y_side = [-1, 1]) {
        y_pos = y_side * (stair_width / 2 - post_inset);

        // Continuous blocky handrail — hulled cubes along the stair slope
        for (i = [0 : num_steps - 2]) {
            sx1 = platform_edge_x + (num_steps - i - 0.5) * step_run;
            sz1 = (i + 0.5) * step_rise + handrail_h;
            sx2 = platform_edge_x + (num_steps - i - 1.5) * step_run;
            sz2 = (i + 1.5) * step_rise + handrail_h;

            hull() {
                translate([sx1, y_pos, sz1])
                    cube(rail_r * 2, center = true);
                translate([sx2, y_pos, sz2])
                    cube(rail_r * 2, center = true);
            }
        }

        // Vertical blocky posts sitting on top of each levitating step
        for (i = [0 : num_steps - 1]) {
            sx = platform_edge_x + (num_steps - i - 0.5) * step_run;
            step_top_z = (i + 0.5) * step_rise + step_thickness / 2;
            post_h = handrail_h - step_thickness / 2;
            post_center_z = step_top_z + post_h / 2;

            translate([sx, y_pos, post_center_z]) {
                cube([post_r * 2, post_r * 2, post_h], center = true);
            }
        }

        // Top extension — railing curves to meet the platform
        sx_top = platform_edge_x + 0.5 * step_run;
        sz_top = (num_steps - 0.5) * step_rise + handrail_h;
        hull() {
            translate([sx_top, y_pos, sz_top])
                cube(rail_r * 2, center = true);
            translate([platform_edge_x - step_run * 0.3, y_pos, total_rise + handrail_h])
                cube(rail_r * 2, center = true);
        }
        // End post at platform (sitting on platform surface)
        platform_post_h = handrail_h;
        translate([platform_edge_x - step_run * 0.3, y_pos, total_rise + platform_post_h / 2]) {
            cube([post_r * 2, post_r * 2, platform_post_h], center = true);
        }
    }
}

// Steps
color("lightyellow")
for (i = [0 : num_steps - 1]) {
    sx = platform_edge_x + (num_steps - i - 0.5) * step_run;
    sz = (i + 0.5) * step_rise;

    translate([sx, 0, sz]) {
        cube([step_run, stair_width, step_thickness], center = true);
    }
}

// Railings
color("lightyellow")
stair_railing();

// Central cylinder — diameter 120cm, height 240cm
translate([0, 0, cylinder_h / 2]) {
    cylinder(d = cylinder_d, h = cylinder_h, center = true, $fn = 128);
}
