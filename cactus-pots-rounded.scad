// Nine integrated flower pots, rounded square top plate
plate_size = 229;
rows = 3;
cols = 3;
pot_outer_d = 65;
pot_spacing = 7;
height = 70.5;
wall = 1.5;
bottom = 1.5;
plate_thickness = 2;
corner_radius = pot_outer_d / 2; // 32.5 mm
// Drain holes: 0 to disable
drain_hole_d = 0;
$fn = 96;

pitch = pot_outer_d + pot_spacing;
array_width = (cols - 1) * pitch + pot_outer_d;
array_depth = (rows - 1) * pitch + pot_outer_d;
inner_d = pot_outer_d - 2 * wall;
eps = 0.05;

assert(array_width <= plate_size && array_depth <= plate_size,
       "Pots exceed plate size");
assert(corner_radius >= 0 && corner_radius <= plate_size/2,
       "Invalid corner radius");
assert(inner_d > 0 && bottom < height && plate_thickness <= height,
       "Invalid wall/bottom/height dimensions");

module positions() {
    for (y = [0 : rows-1])
        for (x = [0 : cols-1])
            translate([
                (plate_size-array_width)/2 + pot_outer_d/2 + x*pitch,
                (plate_size-array_depth)/2 + pot_outer_d/2 + y*pitch,
                0
            ]) children();
}

module rounded_plate() {
    translate([0, 0, height-plate_thickness])
        linear_extrude(height=plate_thickness)
            offset(r=corner_radius)
                translate([corner_radius, corner_radius])
                    square([plate_size-2*corner_radius,
                            plate_size-2*corner_radius]);
}

module tray() {
    difference() {
        union() {
            rounded_plate();
            positions() cylinder(d=pot_outer_d, h=height);
        }
        positions()
            translate([0, 0, bottom])
                cylinder(d=inner_d, h=height-bottom+eps);
        if (drain_hole_d > 0)
            positions()
                translate([0, 0, -eps])
                    cylinder(d=drain_hole_d, h=bottom+2*eps);
    }
}

tray();
