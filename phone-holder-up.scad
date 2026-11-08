// ================================================
// Overhead phone holder - V5
//
// Two identical brackets mounted under a shelf.
// Phone rests at 45 degrees.
//
// Latest changes:
// - Mounting hole moved close to diagonal beam
// - Actual phone clearance = 10 mm
// - Hook retaining tips = 2 mm thick
// ================================================

layout = "pair";   // "single" or "pair"

// ================================================
// MAIN DIMENSIONS
// ================================================

x_len = 80;          // Phone support length
a_len = 40;          // Diagonal arm from shelf
b_mount = 50;        // Mounting plate length
c_width = 10;        // Bracket width

d_angle = 32;        // Diagonal arm angle

thickness = 6;       // Main structural thickness

support_joint = 0.30;

// ================================================
// PHONE HOOKS
// ================================================

// Actual free space for phone thickness
phone_clearance = 13;

// Thickness of retaining hook tips
hook_wall = 2;

// Length of the small retaining returns
z_return = 5;

// Gives true 10 mm free phone space
hook_offset =
    phone_clearance
    + thickness/2
    + hook_wall/2;

// ================================================
// MOUNTING HARDWARE
// ================================================

hole_d = 4.2;

// Moved close to the diagonal beam,
// while keeping enough plastic around it
single_hole_x = 7;

recess_d = 6;
recess_depth = 2;

// ================================================
// PRINT SETTINGS
// ================================================

pair_spacing = 120;

$fn = 96;

// ================================================
// VECTOR HELPERS
// ================================================

function add(a,b) = [
    a[0]+b[0],
    a[1]+b[1]
];

function sub(a,b) = [
    a[0]-b[0],
    a[1]-b[1]
];

function mul(a,s) = [
    a[0]*s,
    a[1]*s
];

// ================================================
// GEOMETRY DIRECTIONS
// ================================================

// Connector goes diagonally down-left
connector_dir = [
    -cos(d_angle),
     sin(d_angle)
];

// Phone support perpendicular to connector
support_dir = [
    sin(d_angle),
    cos(d_angle)
];

// Hooks point to same side as connector
hook_dir = connector_dir;

// ================================================
// KEY POINTS
// ================================================

connector_start = [
    0,
    thickness/2
];

joint = add(
    connector_start,
    mul(connector_dir,a_len)
);

upper_end = sub(
    joint,
    mul(support_dir,x_len*support_joint)
);

lower_end = add(
    upper_end,
    mul(support_dir,x_len)
);

// Hook tips, corrected for real 10 mm clearance
upper_tip = add(
    upper_end,
    mul(hook_dir,hook_offset)
);

lower_tip = add(
    lower_end,
    mul(hook_dir,hook_offset)
);

// Small retaining lips toward the center
upper_return = add(
    upper_tip,
    mul(support_dir,z_return)
);

lower_return = sub(
    lower_tip,
    mul(support_dir,z_return)
);

// ================================================
// 2D SHAPE HELPERS
// ================================================

module bar2d(p1,p2,w) {
    hull() {
        translate(p1)
            circle(r=w/2);

        translate(p2)
            circle(r=w/2);
    }
}

module mounting_plate_2d() {
    r = min(1.5, thickness/2);

    hull() {
        for (xx=[
            -b_mount/2+r,
             b_mount/2-r
        ])
            for (yy=[
                r,
                thickness-r
            ])
                translate([xx,yy])
                    circle(r=r);
    }
}

// ================================================
// PHONE HOOK
// ================================================

module phone_hook(start_point, tip_point, return_point) {

    // Main hook arm, structural thickness 5 mm
    bar2d(
        start_point,
        tip_point,
        thickness
    );

    // Retaining return, only 2 mm thick
    bar2d(
        tip_point,
        return_point,
        hook_wall
    );
}

// ================================================
// SIDE PROFILE
// ================================================

module side_profile() {
    union() {

        // Horizontal shelf mounting plate
        mounting_plate_2d();

        // Diagonal structural arm
        bar2d(
            connector_start,
            joint,
            thickness
        );

        // Main phone support
        bar2d(
            upper_end,
            lower_end,
            thickness
        );

        // Upper phone retaining hook
        phone_hook(
            upper_end,
            upper_tip,
            upper_return
        );

        // Lower phone retaining hook
        phone_hook(
            lower_end,
            lower_tip,
            lower_return
        );
    }
}

// ================================================
// MOUNTING HOLE
// ================================================

module mounting_holes() {

    hx = single_hole_x;

    // Through hole
    translate([
        hx,
        thickness/2,
        c_width/2
    ])
        rotate([90,0,0])
            cylinder(
                d=hole_d,
                h=thickness+2,
                center=true
            );

    // Recess from underside
    translate([
        hx,
        thickness-recess_depth/2+0.01,
        c_width/2
    ])
        rotate([90,0,0])
            cylinder(
                d=recess_d,
                h=recess_depth+0.02,
                center=true
            );
}

// ================================================
// COMPLETE BRACKET
// ================================================

module bracket() {
    difference() {
        linear_extrude(height=c_width)
            side_profile();

        mounting_holes();
    }
}

// ================================================
// OUTPUT
// ================================================

if (layout == "single") {

    bracket();

}
else if (layout == "pair") {

    translate([0,0,0])
        bracket();

    translate([pair_spacing,0,0])
        bracket();

}