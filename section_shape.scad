// ============================================================================
// FENCE SECTION SHAPE - Individual decorative fence section geometry
// ============================================================================

// Module libraries imported via `use` don't inherit the caller's variables,
// so pull in the shared parameters here to keep the section dimensions defined.
include <parameters.scad>

module section_shape() {
    // Section geometry — all derived from section_depth (see parameters.scad).
    // Every interlocking part shares one thickness and one rib width.
    feature_thickness = section_depth * (18/733); // z-height of every recess/protrusion
    rib_width = section_depth * (33/733);          // cross-section of the C-shape ribs
    clearance = section_depth * (43/733);

    recess_depth = feature_thickness;
    bezel_width_x = section_depth * (61/1466);
    bezel_width_y = section_depth * (127/1466);
    recess_width = section_width - (2 * bezel_width_x);
    recess_depth_y = section_depth - (2 * bezel_width_y);

    protrude_width = rib_width;
    protrude_depth = section_depth * (137/733);
    protrude_height = feature_thickness;
    protrude_x_offset = (recess_width/2) - clearance - (protrude_width/2);

    // Second protrusion: maximum width with clearance on each side.
    protrude2_width = recess_width - (2 * clearance);
    protrude2_depth = rib_width;
    protrude2_height = feature_thickness;
    protrude2_y_offset = (recess_depth_y/2) - clearance - (protrude2_depth/2);

    // Connecting ribs that close the C shape.
    connect_width = rib_width;
    connect_depth = protrude2_y_offset - (protrude_depth/2 + clearance);
    connect_height = feature_thickness;
    connect_y_offset = protrude2_y_offset - (connect_depth/2);

    recess_z = (section_height - recess_depth) / 2; // z of each recess/protrusion band
    overcut = 0.1;                                  // extra cut depth to avoid z-fighting
    union() {
        difference() {
            // Main fence section body
            cube([section_width, section_depth, section_height], center=true);

            // Recess cutouts on top and bottom using a loop
            for (z_pos = [-recess_z, recess_z]) {
                translate([0, 0, z_pos]) {
                    cube([recess_width, recess_depth_y, recess_depth + overcut], center=true);
                }
            }
        }

        // Protruding sections on both sides of top and bottom recess areas
        for (z_pos = [-recess_z, recess_z]) {
            for (x_pos = [protrude_x_offset, -protrude_x_offset]) {
                translate([x_pos, 0, z_pos]) {
                    cube([protrude_width, protrude_depth, protrude_height], center=true);
                }
            }
        }

        // Second protruding section on both sides of top and bottom recess areas
        for (z_pos = [-recess_z, recess_z]) {
            for (y_pos = [protrude2_y_offset, -protrude2_y_offset]) {
                translate([0, y_pos, z_pos]) {
                    cube([protrude2_width, protrude2_depth, protrude2_height], center=true);
                }
            }
        }

        // Connecting sections to create C shape (extending from horizontal sections toward corner sections)
        for (z_pos = [-recess_z, recess_z]) {
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
