// Clamp-on tablet holder for 25 mm vertical tube
// One mount = front hook half + rear clamp half.
// Print TWO copies of each half to support a tablet.

// ---- Parameters, mm ----
tube_d = 25;
bore_d = 24.6;            // Slight interference; adjust after test fit
wall = 8;                 // Radial clamp wall thickness
clamp_h = 14;             // Height along the tube
split_gap = 1.0;          // Gap between the two clamp halves

bolt_d = 4.5;             // M4 clearance hole
head_d = 8.2;             // Recess for socket-head M4
head_depth = 3.0;
nut_af = 7.3;             // M4 hex nut across flats
nut_depth = 3.5;

hook_gap = 10;            // Useful space for tablet thickness
hook_width = 24;          // Width of contact along tablet edge
hook_floor = 4;           // Vertical thickness of support ledge
hook_lip = 4;             // Front retaining lip thickness
hook_height = 18;         // Front lip height above shelf bottom
back_wall = 3;            // Thickness of back contact plate

// "assembled" or "print"
layout = "print";
$fn = 96;

// ---- Derived dimensions ----
ri = bore_d / 2;
ro = ri + wall;
lug_x = ro + 7;
lug_len = 14;
lug_y = 6;
half_gap = split_gap / 2;

// Hook geometry. Tablet goes between back_y and lip_inner_y.
back_y = -(ro + 0.5);
lip_inner_y = back_y - hook_gap;
lip_outer_y = lip_inner_y - hook_lip;

module annulus() {
    difference() {
        cylinder(h=clamp_h, r=ro);
        translate([0,0,-1])
            cylinder(h=clamp_h+2, r=ri);
    }
}

module half_ring(front=true) {
    intersection() {
        annulus();
        if (front)
            translate([-ro-1,-ro-2,-1])
                cube([2*ro+2, ro+2-half_gap, clamp_h+2]);
        else
            translate([-ro-1,half_gap,-1])
                cube([2*ro+2, ro+2-half_gap, clamp_h+2]);
    }
}

module lugs(front=true) {
    for (sgn=[-1,1]) {
        translate([(sgn>0 ? 1 : -1)*(ro+lug_len/2-2),
                   front ? -(lug_y+half_gap)/2 : (lug_y+half_gap)/2,
                   clamp_h/2])
            cube([lug_len, lug_y-half_gap, clamp_h], center=true);
    }
}

// Axis along Y.
module y_cylinder(d, h, y, x, z, fn=64) {
    translate([x,y,z]) rotate([90,0,0])
        cylinder(d=d,h=h,center=true,$fn=fn);
}

module holes(front=true) {
    for (x=[-lug_x,lug_x]) {
        y_cylinder(bolt_d, 30, 0, x, clamp_h/2);

        if (front)
            y_cylinder(head_d, head_depth+0.2,
                       -lug_y+head_depth/2-0.05,
                       x,clamp_h/2);
        else
            // Nut recess entered from the rear (+Y) face.
            y_cylinder(2*nut_af/sqrt(3),nut_depth+0.2,
                       lug_y-nut_depth/2+0.05,
                       x,clamp_h/2,6);
    }
}

module hook() {
    // 4-mm-thick shelf supports the weight of the tablet.
    translate([-hook_width/2,lip_outer_y,0])
        cube([hook_width,(-ro+2)-lip_outer_y,hook_floor]);

    // Outer retaining lip.
    translate([-hook_width/2,lip_outer_y,0])
        cube([hook_width,hook_lip,hook_height]);

    // Flat rear contact surface: exactly hook_gap away from the lip.
    translate([-hook_width/2,back_y,0])
        cube([hook_width,back_wall,hook_height]);
}

module front_half() {
    difference() {
        union() {
            half_ring(true);
            lugs(true);
            hook();
        }
        holes(true);
    }
}

module rear_half() {
    difference() {
        union() {
            half_ring(false);
            lugs(false);
        }
        holes(false);
    }
}

if (layout == "assembled") {
    color("orange") front_half();
    color("lightsteelblue") rear_half();
} else {
    // Two disconnected pieces, ready to place in slicer.
    translate([-45,0,0]) front_half();
    translate([45,0,0]) rear_half();
}
