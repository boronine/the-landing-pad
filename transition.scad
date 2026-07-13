// ============================================================================
// TRANSITION - Curved connection between column and platform
// ============================================================================
include <parameters.scad>

// Non-linear blend (cubic): exponent > 1 curves inward (concave), = 1 is a linear cone
blend_exp = 3;
function blend(t) = pow(t, blend_exp);

n_transition = 30;
column_r = column_d / 2;
slice_h = 0.2; // thickness of each hulled slice
transition_z0 = column_h / 2;
transition_z1 = column_h;
transition_dz = (transition_z1 - transition_z0) / n_transition;

// Radii at a given z parameter t (0 = bottom/circle, 1 = top/ellipse)
function rx_at(t) = column_r + (a - column_r) * blend(t);
function ry_at(t) = column_r + (b - column_r) * blend(t);

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
                cylinder(r = 1, h = slice_h, center = true);
        translate([0, 0, z1])
            scale([rx1, ry1, 1])
                cylinder(r = 1, h = slice_h, center = true);
    }
}
