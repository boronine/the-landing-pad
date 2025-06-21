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
    
    // Protruding boxes on both sides of the top recess area
    for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
        translate([x_pos, 0, (box_height - recess_depth) / 2]) {
            cube([protrude_width, protrude_depth, protrude_height], center=true);
        }
    }
}