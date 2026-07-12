// ============================================================================
// BACK WALL, ROOF & LIP - Protective structure at the back of the platform
// ============================================================================
include <parameters.scad>

// Wall-to-fence height ratio measured in IMG_0687.HEIC: 1680:600.
// The fence height includes the gap between the fence and the platform (gap + section_width).
wall_height = (gap + section_width) * 1680 / 600;
wall_thickness = section_height;
// Roof depth measured from IMG_0727.PNG: outer wall thickness + 49cm span + roof-lip thickness
// (section_height + 49 + section_height, i.e. 15.76 + 49 + 15.76).
roof_depth = section_height + 49 + section_height;
roof_thickness = section_height;
lip_height = section_height;
lip_thickness = section_height;

platform_top = column_h + ellipse_z;

// A hollow elliptical band, centered at z_center, extruded vertically and
// clipped to the angular wedge between start_angle and end_angle.
module elliptical_band(z_center, height, outer_x, outer_y, inner_x, inner_y, start_angle, end_angle) {
    translate([0, 0, z_center]) {
        linear_extrude(height = height, center = true) {
            intersection() {
                difference() {
                    scale([outer_x, outer_y])
                        circle(r = 1);
                    scale([inner_x, inner_y])
                        circle(r = 1);
                }
                pie_slice(max(a, b) * 1.5, start_angle, end_angle);
            }
        }
    }
}

// Covers the gap left by removed fence sections 8–12.
// Boundaries are the midpoints between sections 7-8 and 12-13 to avoid overlap.
back_wall_start = param_to_geom(find_theta(7.5 * target_arc, 0));
back_wall_end   = param_to_geom(find_theta(12.5 * target_arc, 0));

// Each top corner of the wall+roof+lip combo is sheared off by a single planar
// cut (see IMG_0687.HEIC / IMG_0727.PNG). Facing the stairs (+X) with the wall
// behind, these are the top-left (+Y) and top-right (-Y) corners; symmetric about X.
// The cut is fixed by two points:
//   - on the wall's outer side edge it descends to the fence top;
//   - on the roof it starts only roof_cut_width in from the corner (a smaller
//     bite), giving a steep — not 45° — bevel.
combo_top = platform_top + wall_height + roof_thickness;   // top of the roof
fence_top = platform_top + gap + section_width;            // top of a fence section incl. gap
// The wall's outer side edge sits where the pie-slice ray (geometric angle
// back_wall_start) meets the outer ellipse scale([a, b]) circle(1).
edge_r = 1 / sqrt(pow(cos(back_wall_start) / a, 2) + pow(sin(back_wall_start) / b, 2));
edge_x = edge_r * cos(back_wall_start);
edge_y = edge_r * sin(back_wall_start);
// Roof cut width measured from the photos: 320 : 600 of the fence+gap height.
roof_cut_width = (gap + section_width) * 320 / 600;
cut_drop = combo_top - fence_top;                          // vertical span of the cut
cut_tilt = atan2(cut_drop, roof_cut_width);                // steepness from horizontal

// Half-space that shears off a top corner. The wedge is rotated about Z to align
// with the wall's radial end face, so viewed straight down the cut edge follows
// the ellipse radius. It descends to the fence top at the outer corner and bites
// roof_cut_width into the wall at the roof.
module top_corner_wedge() {
    big = 5000;
    translate([edge_x, edge_y, fence_top])
        rotate([0, 0, back_wall_start])
            rotate([cut_tilt, 0, 0])
                translate([0, 0, big / 2])
                    cube(big, center = true);
}

difference() {
    union() {
        // Wall — rises vertically from the platform edge, thickness extending inward.
        color("lightgreen")
            elliptical_band(platform_top + wall_height / 2, wall_height,
                a, b, a - wall_thickness, b - wall_thickness,
                back_wall_start, back_wall_end);

        // Roof — sits on top of the wall, extending inward from the outer edge.
        color("lightblue")
            elliptical_band(platform_top + wall_height + roof_thickness / 2, roof_thickness,
                a, b, a - roof_depth, b - roof_depth,
                back_wall_start, back_wall_end);

        // Lip — hangs from the roof's inner edge, extending back outward under the roof.
        color("lightblue")
            elliptical_band(platform_top + wall_height - lip_height / 2, lip_height,
                a - roof_depth + lip_thickness, b - roof_depth + lip_thickness,
                a - roof_depth, b - roof_depth,
                back_wall_start, back_wall_end);
    }

    top_corner_wedge();                    // top-left (+Y) corner
    mirror([0, 1, 0]) top_corner_wedge();  // top-right (-Y) corner
}
