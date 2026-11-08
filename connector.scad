
/*
    L-shaped cable channel connector 40x16

    Width: 20 mm
    Depth: 18 mm
    Height: 42 mm

    Wall thickness: 1 mm

    Outer edge: R2
    Inner edge: straight (90°)
*/

$fn = 96;

width = 25;
depth = 18;
height = 40;

wall = 1;
corner_radius = 2;

print_mode = true;


// Corner profile in the XZ plane
// X — depth
// Z — height
module side_profile() {
    r = corner_radius;

    difference() {
        union() {
            // Horizontal shelf
            translate([0, height])
                square([depth, wall]);

            // Vertical wall
            translate([depth-wall, 0])
                square([wall, height]);
        }

        // Remove material ONLY from the outside.
        // Yields a convex R2 fillet.
        translate([depth-r, height+wall-r])
            difference() {
                square([r, r]);

                circle(r = r);
            }
    }
}


// Extrude the profile to a width of 20 mm
module connector() {
    rotate([90, 0, 90])
        linear_extrude(height = width)
            side_profile();
}


// Model orientation for printing
if (print_mode) {
    connector();
} else {
    connector();
}
