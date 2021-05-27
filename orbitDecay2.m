%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   orbitDecay2.m
%   Miles DeWaele 12/1/2020
%
%   This script determines the orbit decay of a satellite
%   considering area, mass, altitude, and drag coeff
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear; clc;

%% INITIALIZATION
h = 500000; % altitude in m
A = 0.74; % area  in m^2
m = 32.4; % mass in kg
Re = 6378000; % m
mu = 3.99e14; % m^3/s^2
Cd = 1.5; % drag coefficient
rho = 6.15e-13; % atmospheric density (from text) in kg/m3
a = 6878000; % SMA in m
totalTime = 0;
%m/Cd/A


%% CALCULATIONS
r = h + Re;
V = sqrt(mu/r);
T = 2 * pi * sqrt(a^3/mu);
fprintf("Initial Altitude: %.2f km\n", a/1000-6378);
fprintf("Initial Velocity: %.2f km/s\n", V/1000);
fprintf("Initial Period: %.2f s\n", T);
fprintf("---------------------------------\n");
i = 1;
final = false;
altitude = h/1000.0;

while altitude > 100
    T = 2 * pi * sqrt(a^3/mu) / 86400;
    totalTime = totalTime + T;
    dV = pi*(Cd*A/m)*rho*a*V;
    V = V + dV;
    %a = mu / V^2;
    dA = -2*pi*(Cd*A/m)*rho*a^2;
    a = a + dA;
    altitude = (a-Re)/1000.0;
    altArr(i) = altitude;
    velArr(i) = V;
    delVelArr(i) = dV;
    timeArr(i) = totalTime / 365.0;
    i=i+1;
    if totalTime >= 1095 && final == false
        fprintf("Final Altitude: %.2f km\n", a/1000-6378);
        fprintf("Final Velocity: %.2f km/s\n", V/1000);
        fprintf("Final Period: %.2f s\n", T * 86400);
        index = i;
        final = true;
    end
end


%% OUTPUT
fprintf("\nTime to reentry (100 km): %.2f years\n", totalTime /365.0);

figure;
plot(timeArr, altArr);
hold on;
scatter(timeArr(index), altArr(index));
legend("Orbit Altitude", "Altitude at Mission End");
grid on;
title("GAEA Altitude over Time - Orbit Decay");
xlabel("Time (years)");
ylabel("Altitude (km)");


