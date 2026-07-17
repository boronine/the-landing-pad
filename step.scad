// ============================================================================
// STEP — A single stair step
// ============================================================================
// Each step is a box that is thin along Z, long along Y and narrow along X,
// curving 90° upward at each end (along Y). `stair_width` is the total Y span
// of the step, including the curved ends.

module step(x, y, z, step_run, stair_width, step_thickness) {
    curve_radius = step_thickness * 7;

    // Flat body width: total width minus the two curved ends. Each curved end
    // reaches curve_radius plus half a cross-section beyond the flat body.
    flat_width = stair_width - 2 * curve_radius - step_thickness;

    // Straight step body
    translate([x, y, z])
        cube([step_run, flat_width, step_thickness], center = true);

    // 90° curved ends — traced from the body edge outward and up
    n = 8;
    for (y_side = [-1, 1]) {
        for (j = [0 : n - 1]) {
            a0 = j / n * 90;
            a1 = (j + 1) / n * 90;
            y0 = y + y_side * (flat_width / 2 + curve_radius * sin(a0));
            z0 = z + curve_radius * (1 - cos(a0));
            y1 = y + y_side * (flat_width / 2 + curve_radius * sin(a1));
            z1 = z + curve_radius * (1 - cos(a1));
            hull() {
                translate([x, y0, z0])
                    cube([step_run, step_thickness, step_thickness], center = true);
                translate([x, y1, z1])
                    cube([step_run, step_thickness, step_thickness], center = true);
            }
        }
    }
}
