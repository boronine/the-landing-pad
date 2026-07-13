// ============================================================================
// STEP SIDE CURVE — Curved side extensions flanking a stair step
// ============================================================================

module step_side_curve(x, y, z, step_run, stair_width, step_thickness) {
    // 90° curved side extensions — traces from step edge outward and up
    n = 8;
    curve_r = step_thickness * 7;   // radius of the quarter-turn side sweep
    for (y_side = [-1, 1]) {
        for (j = [0 : n - 2]) {
            a0 = j / n * 90;
            a1 = (j + 1) / n * 90;
            y0 = y_side * (stair_width / 2 + curve_r * sin(a0));
            z0 = z + curve_r * (1 - cos(a0));
            y1 = y_side * (stair_width / 2 + curve_r * sin(a1));
            z1 = z + curve_r * (1 - cos(a1));
            hull() {
                translate([x, y0, z0])
                    cube([step_run, step_thickness, step_thickness], center = true);
                translate([x, y1, z1])
                    cube([step_run, step_thickness, step_thickness], center = true);
            }
        }
    }
}
