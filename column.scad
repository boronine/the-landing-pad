// ============================================================================
// CENTRAL COLUMN - Main support structure for the platform
// ============================================================================
include <parameters.scad>

translate([0, 0, column_h / 2]) {
    cylinder(d = column_d, h = column_h, center = true);
}
