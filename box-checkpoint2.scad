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