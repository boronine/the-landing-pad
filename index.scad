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
// CENTRAL COLUMN - Main support structure for the platform
// ============================================================================
translate([0, 0, column_h / 2]) {
    cylinder(d = column_d, h = column_h, center = true);
}

// ============================================================================
// PLATFORM - Ellipse and rectangle base on top of column
// ============================================================================

// Platform (ellipse)
translate([0, 0, platform_z]) {
    linear_extrude(height = ellipse_z, center = true)
        scale([ellipse_x / 2, ellipse_y / 2])
            circle(r = 1);
}

// Platform (rectangle)
translate([rect_center_x, 0, platform_z]) {
    cube([rect_x, rect_y, rect_z], center = true);
}

// ============================================================================
// TRANSITION - Curved connection between column and platform
// ============================================================================
// Non-linear blend: p>1 → inward curve (concave), p=1 → linear cone
function blend(t) = pow(t, 3);

n_transition = 30;
transition_z0 = column_h / 2;
transition_z1 = column_h;
transition_dz = (transition_z1 - transition_z0) / n_transition;

// Radii at a given z parameter t (0 = bottom/circle, 1 = top/ellipse)
function rx_at(t) = column_d / 2 + (ellipse_x / 2 - column_d / 2) * blend(t);
function ry_at(t) = column_d / 2 + (ellipse_y / 2 - column_d / 2) * blend(t);

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
                cylinder(r = 1, h = 0.2, center = true);
        translate([0, 0, z1])
            scale([rx1, ry1, 1])
                cylinder(r = 1, h = 0.2, center = true);
    }
}

// ============================================================================
// FENCE SECTIONS - Individual decorative fence sections along the platform
// ============================================================================

module section_shape() {
    // Fence section geometry
    union() {
        difference() {
            // Main fence section body
            cube([section_width, section_depth, section_height], center=true);

            // Recess cutouts on top and bottom using a loop
            for (z_pos = [-(section_height - recess_depth) / 2, (section_height - recess_depth) / 2]) {
                translate([0, 0, z_pos]) {
                    cube([recess_width, recess_depth_y, recess_depth + 0.1], center=true);
                }
            }
        }

        // Protruding sections on both sides of top and bottom recess areas
        for (z_pos = [-(section_height - recess_depth) / 2, (section_height - recess_depth) / 2]) {
            for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
                translate([x_pos, 0, z_pos]) {
                    cube([protrude_width, protrude_depth, protrude_height], center=true);
                }
            }
        }

        // Second protruding section on both sides of top and bottom recess areas
        for (z_pos = [-(section_height - recess_depth) / 2, (section_height - recess_depth) / 2]) {
            for (y_pos = [protrude2_y_offset, -protrude2_y_offset]) {
                translate([0, y_pos, z_pos]) {
                    cube([protrude2_width, protrude2_depth, protrude2_height], center=true);
                }
            }
        }

        // Connecting sections to create C shape (extending from horizontal sections toward corner sections)
        for (z_pos = [-(section_height - recess_depth) / 2, (section_height - recess_depth) / 2]) {
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

// Two fence sections sitting on top of the rectangle
section_z = column_h + ellipse_z + gap + section_width / 2;
section_y_offset = rect_y / 2 - outer_rim - section_height / 2;
for (y_pos = [section_y_offset, -section_y_offset]) {
    translate([rect_center_x, y_pos, section_z]) {
        rotate([0, 0, 90])
            rotate([0, 90, 0])
                section_shape();
    }
}

// Fence sections placed along the ellipse's perimeter with equal arc-length gaps
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
        }
    }

// ============================================================================
// BACK WALL - Protective wall at the back of the platform
// ============================================================================
wall_height = 240;
wall_thickness = section_height;

module back_wall(start_angle, end_angle) {
    // Wall rises vertically from the platform edge — outer face flush with platform edge,
    // thickness extends inward, bottom sits directly on the platform surface.
    translate([0, 0, column_h + ellipse_z + wall_height / 2]) {
        linear_extrude(height = wall_height, center = true) {
            intersection() {
                difference() {
                    // Outer boundary — exactly at the platform edge
                    scale([a, b])
                        circle(r = 1);
                    // Inner boundary — thickness goes inward from the edge
                    scale([a - wall_thickness, b - wall_thickness])
                        circle(r = 1);
                }
                // Angular wedge to cover only the gap between existing fence sections
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

// Back wall — covers the gap left by removed fence sections 8–12.
// Boundaries are the midpoints between sections 7-8 and 12-13 to avoid overlap.
function param_to_geom(theta) = let(
    g = atan2(b * sin(theta), a * cos(theta))
) g < 0 ? g + 360 : g;

back_wall_start = param_to_geom(find_theta(7.5 * target_arc, 0));
back_wall_end   = param_to_geom(find_theta(12.5 * target_arc, 0));

color("lightgreen")
    back_wall(back_wall_start, back_wall_end);

// ============================================================================
// BACK ROOF - Protective roof structure over the back wall
// ============================================================================
roof_depth = 40;
roof_thickness = section_height;

module back_roof(start_angle, end_angle) {
    // Sits on top of the wall
    translate([0, 0, column_h + ellipse_z + wall_height + roof_thickness / 2]) {
        linear_extrude(height = roof_thickness, center = true) {
            intersection() {
                difference() {
                    // Outer edge — flush with wall outer face (platform edge)
                    scale([a, b])
                        circle(r = 1);
                    // Inner edge — 1m inward from the outer edge
                    scale([a - roof_depth, b - roof_depth])
                        circle(r = 1);
                }
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
    }
}

color("lightblue")
    back_roof(back_wall_start, back_wall_end);

// ============================================================================
// ROOF LIP - Decorative hanging element from the inner roof edge
// ============================================================================
lip_height = section_height;
lip_thickness = section_height;

module roof_lip(start_angle, end_angle) {
    // Hangs from the roof bottom, inner face flush with roof inner edge,
    // lip extends outward underneath the roof toward the wall.
    translate([0, 0, column_h + ellipse_z + wall_height - lip_height / 2]) {
        linear_extrude(height = lip_height, center = true) {
            intersection() {
                difference() {
                    // Outer edge — extends outward under the roof toward the wall
                    scale([a - roof_depth + lip_thickness, b - roof_depth + lip_thickness])
                        circle(r = 1);
                    // Inner edge — flush with the roof's inner edge
                    scale([a - roof_depth, b - roof_depth])
                        circle(r = 1);
                }
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
    }
}

color("lightblue")
    roof_lip(back_wall_start, back_wall_end);

// ============================================================================
// STAIRS - Main staircase accessing the platform
// ============================================================================
num_steps = 7;
total_rise = column_h + ellipse_z;
step_rise = total_rise / num_steps;
step_thickness = step_rise * 0.4;
step_run = 34;

// Stair width fits between the two entrance fence sections on the rectangle
stair_width = rect_y - 2 * outer_rim - section_height;
platform_edge_x = rect_center_x + rect_x / 2;

// Railing parameters — thinner, matching fence thickness (section_height ≈ 15.8cm)
post_r = section_height / 2;
rail_r = section_height * 0.35;
handrail_h = 85;
post_inset = 6;

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
