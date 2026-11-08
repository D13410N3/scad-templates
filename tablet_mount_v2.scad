
 // Tablet mounts for two vertical 25 mm tubes.
 // Bambu Lab A1 - 256 x 256 mm bed.
 // Four clamps, eight separate printed parts.
 // Units: millimeters.

 // =============================================
 // OUTPUT SETTINGS
 // =============================================

 model = "all";       // "long", "short", "pair", "all"
 view = "print";      // "assembled" or "print"

 // =============================================
 // DIMENSIONS
 // =============================================

 long_reach = 120;
 short_reach = 22;

 tube_d = 25;
 bore_d = 25.2;

 clamp_wall = 4;
 clamp_height = 20;
 split_gap = 1.2;

 arm_width = 20;
 arm_height = 12;

 hook_gap = 13;
 hook_wall = 3;
 hook_depth = 10;

 // M4 hardware
 bolt_clearance = 4.5;
 head_d = 8.2;
 head_depth = 4.7;

 nut_af = 7.3;
 nut_depth = 5.0;

 // Transition and reinforcement
 transition_length = 8;

 rib_height = 4;
 rib_end_height = 0.8;
 rib_width = 4;
 rib_end_offset = 2;

 $fn = 96;
 eps = 0.05;

 // =============================================
 // DERIVED DIMENSIONS
 // =============================================

 ri = bore_d / 2;
 ro = ri + clamp_wall;

 lug_y = ro + 5.5;
 lug_length_y = 15;
 lug_depth_x = 9;

 // =============================================
 // CLAMP RING
 // =============================================

 module clamp_ring(front=true) {
     intersection() {
         difference() {
             cylinder(h=clamp_height, r=ro);

             translate([0,0,-1])
                 cylinder(
                     h=clamp_height+2,
                     r=ri
                 );
         }

         if (front)
             translate([
                 split_gap/2,
                 -ro-1,
                 -1
             ])
                 cube([
                     ro+2,
                     2*ro+2,
                     clamp_height+2
                 ]);
         else
             translate([
                 -ro-2,
                 -ro-1,
                 -1
             ])
                 cube([
                     ro+2-split_gap/2,
                     2*ro+2,
                     clamp_height+2
                 ]);
     }
 }

 // =============================================
 // CLAMP LUGS
 // =============================================

 module clamp_lugs(front=true) {
     for (sgn=[-1,1])
         translate([
             front
                 ? split_gap/2
                 : -lug_depth_x-split_gap/2,
             sgn*lug_y-lug_length_y/2,
             0
         ])
             cube([
                 lug_depth_x,
                 lug_length_y,
                 clamp_height
             ]);
 }

 // =============================================
 // SCREW HOLES
 // =============================================

 module screw_cylinder(
     d,len,x,y,z,sides=64
 ) {
     translate([x,y,z])
         rotate([0,90,0])
             cylinder(
                 d=d,
                 h=len,
                 center=true,
                 $fn=sides
             );
 }

 module bolt_cutouts(front=true) {
     for (sgn=[-1,1]) {
         yy = sgn*lug_y;

         screw_cylinder(
             bolt_clearance,
             30,
             0,
             yy,
             clamp_height/2
         );

         if (front)
             screw_cylinder(
                 head_d,
                 head_depth+0.15,
                 split_gap/2
                     +lug_depth_x
                     -head_depth/2
                     +0.05,
                 yy,
                 clamp_height/2
             );
         else
             screw_cylinder(
                 2*nut_af/sqrt(3),
                 nut_depth+0.15,
                 -split_gap/2
                     -lug_depth_x
                     +nut_depth/2
                     -0.05,
                 yy,
                 clamp_height/2,
                 6
             );
     }
 }

 // =============================================
 // REAR CLAMP HALF
 // =============================================

 module back_clamp() {
     difference() {
         union() {
             clamp_ring(false);
             clamp_lugs(false);
         }

         bolt_cutouts(false);
     }
 }

 // =============================================
 // SMOOTH CLAMP-TO-ARM TRANSITION
 // =============================================

 module smooth_transition() {
     hull() {
         intersection() {
             cylinder(
                 h=arm_height,
                 r=ro
             );

             translate([
                 split_gap/2,
                 -ro-1,
                 0
             ])
                 cube([
                     ro+2,
                     2*ro+2,
                     arm_height
                 ]);
         }

         translate([
             ro+transition_length,
             -arm_width/2,
             0
         ])
             cube([
                 1,
                 arm_width,
                 arm_height
             ]);
     }
 }

 // =============================================
 // ARM AND TABLET HOOK
 // =============================================

 module arm_and_hook(reach) {
     end_x = ro + reach;

     outer_hook_x = end_x - hook_wall;
     inner_hook_x = outer_hook_x - hook_gap;
     inner_lip_x = inner_hook_x - hook_wall;

     base_z = 0;

     // Main arm
     translate([
         ro-1,
         -arm_width/2,
         base_z
     ])
         cube([
             end_x-(ro-1),
             arm_width,
             arm_height
         ]);

     // Solid transition
     smooth_transition();

     // Inner hook lip
     translate([
         inner_lip_x,
         -arm_width/2,
         base_z+arm_height
     ])
         cube([
             hook_wall,
             arm_width,
             hook_depth
         ]);

     // Outer hook lip
     translate([
         outer_hook_x,
         -arm_width/2,
         base_z+arm_height
     ])
         cube([
             hook_wall,
             arm_width,
             hook_depth
         ]);

     // Reinforcement ribs
     if (reach > 50)
         for (sy=[-1,1])
             hull() {
                 translate([
                     ro-2,
                     sy*(arm_width/2-2)-2,
                     base_z+arm_height-eps
                 ])
                     cube([
                         3,
                         rib_width,
                         rib_height+eps
                     ]);

                 translate([
                     inner_lip_x-rib_end_offset,
                     sy*(arm_width/2-2)-2,
                     base_z+arm_height-eps
                 ])
                     cube([
                         3,
                         rib_width,
                         rib_end_height+eps
                     ]);
             }
 }

 // =============================================
 // COMPLETE FRONT PART
 // =============================================

 module front_part(reach) {
     difference() {
         union() {
             clamp_ring(true);
             clamp_lugs(true);
             arm_and_hook(reach);
         }

         // Pipe hole
         translate([0,0,-1])
             cylinder(
                 h=clamp_height+2,
                 r=ri
             );

         // Clamp split plane
         translate([
             -ro-transition_length-2,
             -ro-lug_length_y-10,
             -1
         ])
             cube([
                 ro+transition_length+2+split_gap/2,
                 2*(ro+lug_length_y+10),
                 clamp_height+2
             ]);

         // M4 holes
         bolt_cutouts(true);
     }
 }

 // =============================================
 // PRINT LAYOUT
 // =============================================

 // The 8 components are arranged in four rows:
 //
 //  Row 1: long front  + short front
 //  Row 2: long front  + short front
 //  Row 3: rear half   + rear half
 //  Row 4: rear half   + rear half
 //
 // Rear halves rotated 90 degrees around Z.
 //
 // Layout for default parameters:
 // X occupied: approx 25..217 mm
 // Y occupied: approx 22..209 mm
 //
 // Bed: 256 x 256 mm.

 module print_front(reach,x,y) {
     translate([x,y,0])
         front_part(reach);
 }

 module print_back(x,y) {
     translate([x,y,0])
         rotate([0,0,90])
             back_clamp();
 }

 // 2 long parts
 module print_long_parts() {
     print_front(long_reach,25,52);
     print_front(long_reach,25,121);
 }

 // 2 short parts
 module print_short_parts() {
     print_front(short_reach,178,52);
     print_front(short_reach,178,121);
 }

 // 4 rear clamp halves
 module print_rear_parts() {
     print_back(60,184);
     print_back(140,184);

     print_back(60,209);
     print_back(140,209);
 }

 // Single bracket print layout
 module print_single(reach) {
     print_front(reach,25,65);
     print_back(70,155);
 }

 // =============================================
 // ASSEMBLED VIEW
 // =============================================

 module assembled_bracket(reach) {
     color("#e6a34b")
         front_part(reach);

     color("#8ca9c8")
         back_clamp();
 }

 // =============================================
 // OUTPUT SELECTION
 // =============================================

 if (view == "print") {

     if (model == "all") {
         print_long_parts();
         print_short_parts();
         print_rear_parts();
     }

     else if (model == "pair") {
         print_front(long_reach,25,52);
         print_front(short_reach,178,52);

         print_back(60,150);
         print_back(140,150);
     }

     else if (model == "long") {
         print_single(long_reach);
     }

     else if (model == "short") {
         print_single(short_reach);
     }
 }

 else if (view == "assembled") {

     if (model == "long")
         assembled_bracket(long_reach);

     else if (model == "short")
         assembled_bracket(short_reach);

     else if (model == "pair") {
         translate([0,-65,0])
             assembled_bracket(long_reach);

         translate([0,65,0])
             assembled_bracket(short_reach);
     }

     else if (model == "all") {
         translate([0,0,0])
             assembled_bracket(long_reach);

         translate([0,75,0])
             assembled_bracket(long_reach);

         translate([0,150,0])
             assembled_bracket(short_reach);

         translate([0,225,0])
             assembled_bracket(short_reach);
     }
 }
