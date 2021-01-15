# NS2-Code
I created and collected  the following NS2 codes for 5G wireless communication network scenarios. 

To design a 4G/5G wireless network, you can use these codes. The .tcl files are used to design network. After running .tcl file you will get .tr file. To get the throughput, delay, and jitter, you need to run .awk files.
I installed NS2.35 in Ubuntu LTS 14.04. I use a hour-wise traffic profile of different users (CBR, VBR, and TCP). In the terminal, I run this way:

ns2.35 ns mmr.tcl

% after that I got mmr.tr
% Then to get throughput, delay, and jitter ( You can use different files)

gawk -k common.awk mmr.tr

% then I will get results and plot in the excel file to generate figures.

Related Paper: 
A Green Communication Model for 5G Systems (https://ieeexplore.ieee.org/document/7918597) and 
Energy Efficient Backhauling for 5G Small Cell Networks (https://ieeexplore.ieee.org/document/8361042).
An energy efficient resource management and planning system for 5G networks (https://ieeexplore.ieee.org/document/7983108)
