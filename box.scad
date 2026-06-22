// Box dimensions — all constants are expressed in terms of box_depth (the largest dimension)
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

// Protruding box parameters
protrude_width = box_depth * (33/733);
protrude_depth = box_depth * (137/733);
protrude_height = box_depth * (18/733);
protrude_x_offset = (recess_width/2) - clearance - (protrude_width/2);

// Second protruding box parameters (maximum width with clearance on each side)
protrude2_width = recess_width - (2 * clearance);
protrude2_depth = box_depth * (33/733);
protrude2_height = box_depth * (18/733);
protrude2_y_offset = (recess_depth_y/2) - clearance - (protrude2_depth/2);

// Connecting boxes parameters (to create C shape)
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

// Position so the left 220cm edge kisses the oval at its corners
rect_center_x = (oval_x / 2) * sqrt(1 - pow(rect_y / oval_y, 2)) + rect_x / 2;

oval_z_offset = box_height / 2 + oval_z / 2;

// Oval on top of the box
translate([0, 0, oval_z_offset]) {
    linear_extrude(height = oval_z, center = true)
        scale([oval_x / 2, oval_y / 2])
            circle(r = 1, $fn = 128);
}

// Rectangle: same z-plane, centered at y=0, left edge overlaps the oval's curve
// Left edge corners at (436.8, ±110) sit on the oval boundary
translate([rect_center_x, 0, oval_z_offset]) {
    cube([rect_x, rect_y, rect_z], center = true);
}

union() {
    difference() {
        // Main box
        cube([box_width, box_depth, box_height], center=true);

        // Recess cutouts on top and bottom using a loop
        for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
            translate([0, 0, z_pos]) {
                cube([recess_width, recess_depth_y, recess_depth + 0.1], center=true);
            }
        }
    }

    // Protruding boxes on both sides of top and bottom recess areas
    for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
        for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
            translate([x_pos, 0, z_pos]) {
                cube([protrude_width, protrude_depth, protrude_height], center=true);
            }
        }
    }

    // Second protruding box on both sides of top and bottom recess areas
    for (z_pos = [-(box_height - recess_depth) / 2, (box_height - recess_depth) / 2]) {
        for (y_pos = [protrude2_y_offset, -protrude2_y_offset]) {
            translate([0, y_pos, z_pos]) {
                cube([protrude2_width, protrude2_depth, protrude2_height], center=true);
            }
        }
    }

    // Connecting boxes to create C shape (extending from horizontal boxes toward corner boxes)
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
