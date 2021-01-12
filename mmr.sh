#!/bin/bash
# My first script

tcl_file=('10_0.tcl' '10_1.tcl' '10_2.tcl' '10_3.tcl' '10_4.tcl')
tr_file=('10_0.tr' '10_1.tr' '10_2.tr' '10_3.tr' '10_4.tr')
awk_file=('10_0.awk' '10_1.awk' '10_2.awk' '10_3.awk' '10_4.awk')
txt_file=('10_0.txt' '10_1.txt' '10_2.txt' '10_3.txt' '10_4.txt')


for i in {0..4}
do
	echo 'Start==================Start'$i;
	ns ${tcl_file[$i]} > ${txt_file[$i]}	
	gawk -f ${awk_file[$i]} ${tr_file[$i]} 
	echo 'End====================End'$i;
done



