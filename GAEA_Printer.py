# -*- coding: utf-8 -*-
"""
Created on Wed Oct 21 22:36:26 2020

@author: milde

Description: Creates GAEA orbit files for inclinations 0 to 90
"""

print("I'm gonna make GAEA files!")

for x in range(12):
    TA = x * 30
    TA = str(TA)
    name = "Orb_GAEA_70b_" + str(x+1) + ".txt"
    f = open(name, "w")
    body1 = "<<<<<<<<<<<<<<<<<  42: Orbit Description File   >>>>>>>>>>>>>>>>>\n\
Low Earth Orbit               !  Description\n\
CENTRAL                       !  Orbit Type (ZERO, FLIGHT, CENTRAL, THREE_BODY)\n\
::::::::::::::  Use these lines if ZERO           :::::::::::::::::\n\
MINORBODY_2                   !  World\n\
FALSE                         ! Use Polyhedron Gravity\n\
::::::::::::::  Use these lines if FLIGHT   :::::::::::::::::\n\
0                             !  Region Number\n\
FALSE                         ! Use Polyhedron Gravity\n\
::::::::::::::  Use these lines if Body-Centered Orbit  :::::::::::::::::\n\
EARTH                         !  Orbit Center\n\
FALSE                         !  Secular Orbit Drift Due to J2\n\
KEP                           !  Use Keplerian elements (KEP) or (RV) or FILE\n\
PA                            !  Use Peri/Apoapsis (PA) or min alt/ecc (AE)\n\
500.0  500.0                  !  Periapsis & Apoapsis Altitude, km\n\
500.0  0.0                    !  Min Altitude (km), Eccentricity\n\
70.0                          !  Inclination (deg)\n\
0.0                           !  Right Ascension of Ascending Node (deg)\n\
0.0                           !  Argument of Periapsis (deg)\n"
    TA = TA + ".0                           !  True Anomaly (deg)\n"
    body2 = "0.0  0.0  0.0                 !  RV Initial Position (km)\n\
0.0  0.0  0.0                 !  RV Initial Velocity (km/sec)\n\
TRV  \"ORB_ID\"                 !  TLE or TRV format, Label to find in file\n\
\"TRV.txt\"                     !  File name\n\
:::::::::::::  Use these lines if Three-Body Orbit  ::::::::::::::::\n\
SUNEARTH                      !  Lagrange system\n\
LAGDOF_MODES                  !  Propagate using LAGDOF_MODES or LAGDOF_COWELL or LAGDOF_SPLINE\n\
MODES                         !  Initialize with MODES or XYZ or FILE\n\
L2                            !  Libration point (L1, L2, L3, L4, L5)\n\
800000.0                      !  XY Semi-major axis, km\n\
45.0                          !  Initial XY Phase, deg\n\
CW                            !  Sense (CW, CCW), viewed from +Z\n\
0.0                           !  Second XY Mode Semi-major Axis, km (L4, L5 only)\n\
0.0                           !  Second XY Mode Initial Phase, deg (L4, L5 only)\n\
CW                            !  Sense (CW, CCW), viewed from +Z (L4, L5 only)\n\
400000.0                      !  Z Semi-axis, km\n\
60.0                          !  Initial Z Phase, deg\n\
1.05  0.5  0.0                !  Initial X, Y, Z (Non-dimensional)\n\
0.0   0.0  0.0                !  Initial Xdot, Ydot, Zdot (Non-dimensional)\n\
TRV  \"ORB_ID\"                 !  TLE, TRV or SPLINE format, Label to find in file\n\
\"TRV.txt\"                     !  File name\n\
******************* Formation Frame Parameters ************************\n\
L                             !  Formation Frame Fixed in [NL]\n\
0.0  0.0  0.0  123            !  Euler Angles (deg) and Sequence\n\
L                             !  Formation Origin expressed in [NL]\n\
0.0  0.0  0.0                 !  Formation Origin wrt Ref Orbit (m)"
    text = body1 + TA + body2
    f.write(text)
    f.close()

#open and read the file after the appending:
#f = open("demofile2.txt", "r")
#print(f.read())