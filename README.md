# Project-GAEA
Project GAEA was my senior design project at Purdue University.  These are my contributions.

Project GAEA utilized Signals of Opportunity communication technology to measure and analyze soil moisture data.  We were tasked with developing a satellite constellation to most efficiently and effectively gather the required data.  From the launch systems to orbit architecture, we had to design the entire process.
I was the mission operations and orbit architecture lead, so I did a lot of coding for analysis of the orbits.  The GAEA_Printer.py file was used as a generator in a simulation that our professor gave us.  My file allowed for various inputs to change true anomaly, inclination, and various other input parameters and it would generate the correct simulation input file.
orbitDecay2.m calculated the orbit decay time for a specific satellite and its altitude. This was used to generate an end-of-mission plan.
plotrevist2.m was where I spent most of my time.  This script plotted the coverage for P-band and I-band measurements based on simulation outputs.  I generated grids of various intensity to get a coverage percentage for the specific simulation parameters.  We had several focus regions, so this script was fundamental in our success of the project.
