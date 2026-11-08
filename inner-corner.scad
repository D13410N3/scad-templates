
/*
    Surface-mounted INNER 90° corner
    Cable channel 40x16 mm

    Two outer horizontal R2 edges
    with a common smooth blend.

    Central vertical edge is straight.
    Rear corner (0,0) is straight.
*/

$fn = 96;

arm = 36;
depth = 18;
height = 40;
wall = 1;
corner_radius = 2;
print_mode = true;

H = height + wall;
eps = 0.02;


// L-shaped cover
module rounded_L() {
    r = corner_radius;

    union() {
        offset(delta = -r)
            offset(r = r)
                polygon([
                    [0,0],
                    [arm,0],
                    [arm,depth],
                    [depth,depth],
                    [depth,arm],
                    [0,arm]
                ]);

        // Straight rear corner
        difference() {
            square([r,r]);

            translate([r,r])
                circle(r=r);
        }
    }
}


// Cover footprint mask
module footprint_mask() {
    translate([0,0,-eps])
        linear_extrude(height=H+2*eps)
            rounded_L();
}


// Base construction made of three walls
module base_corner() {
    union() {
        // Cover
        translate([0,0,height])
            linear_extrude(height=wall)
                rounded_L();

        // Vertical walls
        intersection() {
            footprint_mask();

            union() {
                translate([depth,depth-wall,0])
                    cube([
                        arm-depth,
                        wall,
                        height
                    ]);

                translate([depth-wall,depth,0])
                    cube([
                        wall,
                        arm-depth,
                        height
                    ]);

                // Central joint
                translate([
                    depth-wall,
                    depth-wall,
                    0
                ])
                    cube([
                        wall,
                        wall,
                        height
                    ]);
            }
        }
    }
}


// Auxiliary extended outline.
// Its far edges do not intersect
// the actual part.
module extended_L() {
    e = 12;

    polygon([
        [-e,-e],
        [arm+e,-e],
        [arm+e,depth],
        [depth,depth],
        [depth,arm+e],
        [-e,arm+e]
    ]);
}


// Single 3D rounding mask.
//
// Rounds both outer horizontal edges
// at once and forms a consistent
// blend at their junction.
module rounded_outer_mask() {
    r = corner_radius;

    minkowski() {
        translate([0,0,-10])
            linear_extrude(height=H-r+10)
                offset(delta=-r)
                    extended_L();

        sphere(r=r, $fn=48);
    }
}


// Final model
module internal_corner() {
    intersection() {
        base_corner();
        rounded_outer_mask();
    }
}


// Orientation for printing
if (print_mode) {
    translate([0,0,H])
        mirror([0,0,1])
            internal_corner();
} else {
    internal_corner();
}
