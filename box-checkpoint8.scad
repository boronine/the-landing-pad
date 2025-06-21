// Box dimensions
box_width = 725;
box_depth = 1466;
box_height = 154;

// Recess parameters
recess_depth = 36;
bezel_width_x = 61;
bezel_width_y = 127;

// Calculated recess dimensions
recess_width = box_width - (2 * bezel_width_x);
recess_depth_y = box_depth - (2 * bezel_width_y);

// Protruding box parameters
protrude_width = 66;
protrude_depth = 274;
protrude_height = 36;
protrude_x_offset = (recess_width/2) - 86 - (protrude_width/2); // 86 units from end of recess

// Second protruding box parameters (maximum width with 86 clearance)
protrude2_width = recess_width - (2 * 86); // Maximum width leaving 86 on each side
protrude2_depth = 66;
protrude2_height = 36;
protrude2_y_offset = (recess_depth_y/2) - 86 - (protrude2_depth/2); // 86 units from end of recess

// Connecting boxes parameters (to create C shape)
connect_width = 66;
connect_depth = protrude2_y_offset - (protrude_depth/2 + 86); // Extend toward corner boxes with 86 clearance
connect_height = 36;
connect_y_offset = protrude2_y_offset - (connect_depth/2); // Position between horizontal and corner boxes

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