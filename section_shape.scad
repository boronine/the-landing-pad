// ============================================================================
// FENCE SECTION SHAPE - Individual decorative fence section geometry
// ============================================================================

// Module libraries imported via `use` don't inherit the caller's variables,
// so pull in the shared parameters here to keep the section dimensions defined.
include <parameters.scad>

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
