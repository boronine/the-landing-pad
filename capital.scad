// ============================================================================
// CAPITAL - Curved flare where the column meets the platform
// ============================================================================
include <parameters.scad>

// Non-linear blend: exponent > 1 curves inward (concave), = 1 is a linear cone.
// Higher exponent keeps the profile close to the shaft longer, reducing bulk
// and concentrating the flare just under the platform.
// Blend mixes a gentle quadratic taper with a sharp high-power flare at the
// platform. The quadratic term has zero slope at t = 0, so the capital leaves
// the cylindrical shaft tangentially (no kink at the midpoint joint).
easing_part = 0.25;
function blend(t) = easing_part * pow(t, 2) + (1 - easing_part) * pow(t, 9);

n_capital = 30;
capital_z0 = column_h / 2;
capital_z1 = column_h;
capital_dz = (capital_z1 - capital_z0) / n_capital;

// Radii at a given z parameter t (0 = bottom/circle, 1 = top/ellipse)
function rx_at(t) = column_d / 2 + (a - column_d / 2) * blend(t);
function ry_at(t) = column_d / 2 + (b - column_d / 2) * blend(t);

color("lightblue")
for (i = [0 : n_capital - 1]) {
    z0 = capital_z0 + i * capital_dz;
    z1 = z0 + capital_dz;
    t0 = i / n_capital;
    t1 = (i + 1) / n_capital;

    rx0 = rx_at(t0);
    ry0 = ry_at(t0);
    rx1 = rx_at(t1);
    ry1 = ry_at(t1);

    hull() {
        translate([0, 0, z0])
            scale([rx0, ry0, 1])
                cylinder(r = 1, h = 0.2, center = true);
        translate([0, 0, z1])
            scale([rx1, ry1, 1])
                cylinder(r = 1, h = 0.2, center = true);
    }
}
