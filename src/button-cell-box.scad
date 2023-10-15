// Battery box with magnet lid V1
//
// Torsten Paul <Torsten.Paul@gmx.de>, October 2021
// CC BY-SA 4.0
// https://creativecommons.org/licenses/by-sa/4.0/

// Which part to show
part = "assembly"; // [ "assembly", "box", "lid" ]
// Diameter of the button cell in mm
dia = 20; // [10:1:40]
// Thickness of the button cell in tenth of a mm
thickness = 32; // [10:1:80]
// Number of button cells in the box
count = 20;
// Wall size for the box in mm
wall = 3.0;
// Thickness of the insert between battery compartments in mm
spacing = 0.8;
// Diameter of the magnets in mm
magnet_dia = 4;
// Height of the magnets in mm
magnet_height = 2;
// Extra height inside the lid in mm, e.g. for foam tape
lid_extra_height = 3;
// Clearance gap for battery and magnet compartments in mm
gap = 0.2; // [0.0:0.1:0.5]

height = dia;
lid_add = lid_extra_height > 2 * gap ? lid_extra_height - 2 * gap : 0;
lid_height = 2 * wall + 4 * gap + lid_add;

t = thickness / 10 + 2 * gap;
length = count * t + (count - 1) * spacing;

module magnet_left_pos(z = 0)
    if (magnet_dia > 0)
        translate([-magnet_dia / 2 - wall, dia / 2, z])
            children();

module magnet_right_pos(z = 0)
    if (magnet_dia > 0)
        translate([length + magnet_dia / 2 + wall, dia / 2, z])
            children();

module base(h) {
    linear_extrude(h) offset(wall) square([length, dia]);
    magnet_left_pos()
        cylinder(h = h, d = magnet_dia + wall);
    magnet_right_pos()
        cylinder(h = h, d = magnet_dia + wall);
}

module magnets(h) {
    magnet_left_pos(h - magnet_height - gap)
        cylinder(h = magnet_height + 2 * gap, d = magnet_dia + 2 * gap);
    magnet_right_pos(h - magnet_height - gap)
        cylinder(h = magnet_height + 2 * gap, d = magnet_dia + 2 * gap);
}

module batteries_pos(a)
    translate([a * (t + spacing), dia / 2, dia / 2 + wall])
        children();

module batteries() {
    for (a = [0:1:count - 1]) {
        batteries_pos(a) {
           hull() {
                rotate([0, 90, 0])
                    cylinder(h = t, d = dia + 2 * gap);
                translate([0, 0, dia/ 2 - wall])
                    rotate([0, 90, 0])
                        cylinder(h = t, d = dia + 4 * gap);
            }
        }
    }
}

module box_base() {
    difference() {
        base(height);
        magnets(height);
        batteries();
    }
}

module box_text() {
    difference() {
        translate([0, -wall + eps, height - dia / 2 - wall]) {
            rotate([90, 0, 0]) {
                roof()
                    text(str("CR", dia, thickness), size = dia / 2);
            }
        }
        translate([0, -dia - wall - 2 * gap, 0]) cube([length, dia, dia]);
    }
}

module box() {
    box_base();
    box_text();
}

module lid() {
    difference() {
        base(lid_height);
        magnets(lid_height);
        translate([0, 0, wall]) linear_extrude(lid_height) square([length, dia]);
    }
}

if (part == "box") {
    box();
} else if (part == "lid") {
    lid();
} else {
    box();
    translate([0, 0, height + lid_height + 4 * wall]) mirror([0, 0, 1]) lid();
}

$fa = 5; $fs = 0.6;
eps = 0.01;
