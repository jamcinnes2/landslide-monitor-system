// MIT License
//
// Copyright (c) 2026 John Andrew McInnes
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// PCR trihedral reflector alignment tool, holds a generic laser pointer
// (C) 2025 John McInnes for Ground Truth Alaska
//
// 2025/09/26 - JohnM some tweaks

s_radius = 95;
wall_thick = 3;
laser_mnt_dia = 25.5;
laser_mnt_h = 118;
laser_h = 115;
laser_dia = 14.5;
laser_btn_h = 103; // centered on this distance

function dot_p(v1, v2, idx) = 
        v1[idx] * v2[idx] + (idx > 0 ? dot_p(v1, v2, idx-1) : 0);

function dot_product(v1, v2) = dot_p(v1, v2, len(v1)-1);

function angle( v1, v2) = acos(dot_product(v1, v2) / (norm(v1) * norm(v2)));

// calculate rotation to point it UP
up_vector = [0,0,1];

center_vector = [1,1,1];
cv_length = norm(center_vector);
cvec = [center_vector[0] / cv_length, center_vector[1] / cv_length, center_vector[2] / cv_length];

raxis = cross(cvec,up_vector);
rangle = angle(up_vector,cvec);
echo(rangle);

module refa_tool(){
    s_curve=10;
    mcube_z = sqrt(3.0) * (s_radius-s_curve/2) / 2.0;
    bottom_cut_z = 25;//8;

    translate([0,0,-bottom_cut_z])
    difference(){
        union(){
            // body
            translate([0,0,mcube_z])
            difference(){    
                minkowski(){
                    rotate(rangle,raxis)
                        cube(size=s_radius-s_curve,center=true);
                    sphere(d=s_curve,$fn=200);
                }
                
                // cut off top of cube
                translate([0,0,76])
                    cube(size=200,center=true);

                // partially hollow it out
                difference(){
                    rotate(rangle,raxis)
                        cube(size=s_radius-7,center=true);
                    translate([0,0,-150])
                        cube(size=200,center=true);
                }
            }
            
            // laser mnt
            translate([0,0,mcube_z-50.2])
            difference(){
                // shaft for laser mount w/ solid base
                cylinder(h=laser_mnt_h,d=laser_mnt_dia,center=false,$fn=6);            

                // laser pointer hole
                translate([0,0,laser_mnt_h-laser_h+0.1])
                    cylinder(h=laser_h, d=laser_dia, center=false, $fn=200);

                // notches for button
                btn_notch_dy = 1.0 + laser_dia/2;
                btn_notch_dz = laser_mnt_h-laser_btn_h+8; // lost of extra room vertically
                btn_notch_y = +btn_notch_dy/2;
                btn_notch_z = laser_mnt_h-btn_notch_dz/2 + 0.1;
                translate([0,btn_notch_y,btn_notch_z])
                    cube([6,btn_notch_dy,btn_notch_dz],center=true);
                translate([0,-btn_notch_y-0.5,btn_notch_z])
                    cube([6,btn_notch_dy,btn_notch_dz],center=true);
            }
        }
        
        // cut off bottom flat, so it will 3d print more stable
        translate([0,0,-100 + bottom_cut_z])
            cube(size=200,center=true);
    }
}


refa_tool();

flat_mnt_dz=30;
*translate([150,0,0])
difference(){
    translate([0,0,flat_mnt_dz/2])
        cylinder(h=flat_mnt_dz,d=100,center=true);
    refa_tool();
}