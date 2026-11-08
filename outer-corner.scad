
/*
    Surface-mounted OUTER 90° corner
    Cable channel 40x16 mm

    R3 rounding of three mating edges
    Wall thickness 1 mm
*/

$fn = 48;

// Dimensions
arm = 36;
depth = 18;
height = 40;

// Wall thickness
wall = 1;

// Rounding radius
corner_radius = 2;

// Orientation for printing
print_mode = true;


// L-shaped cover with rounded
// free outer corners
module rounded_L() {
    r = corner_radius;

    offset(r = r)
        offset(delta = -r)
            polygon([
                [0, 0],
                [arm, 0],
                [arm, depth],
                [depth, depth],
                [depth, arm],
                [0, arm]
            ]);
}


// Two side walls
module outer_walls_2d() {
    intersection() {
        rounded_L();

        union() {
            square([arm, wall]);
            square([wall, arm]);
        }
    }
}


// Base model made of three planes
module base_corner() {
    union() {
        // Top cover
        translate([0, 0, height])
            linear_extrude(height = wall)
                rounded_L();

        // Side walls
        linear_extrude(height = height + wall)
            outer_walls_2d();
    }
}


// Bounding volume with three
// rounded edges.
//
// Rounded intersections:
// X=0, Y=0
// X=0, Z=height+wall
// Y=0, Z=height+wall
//
// All three roundings converge smoothly
// at a single point.
module rounded_outer_mask() {
    r = corner_radius;
    H = height + wall;
    extra = 10;

    minkowski() {
        translate([r, r, -extra])
            cube([
                arm + extra,
                arm + extra,
                H - r + extra
            ]);

        sphere(r = r);
    }
}


// Finished model
module external_corner() {
    intersection() {
        base_corner();
        rounded_outer_mask();
    }
}


// Orientation for printing
if (print_mode) {
    translate([0, 0, height + wall])
        mirror([0, 0, 1])
            external_corner();
} else {
    external_corner();
}
