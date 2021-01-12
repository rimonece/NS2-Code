# 6 am  ---- > 7 am  :

BEGIN {
	lineCount1 = 0
	lineCount2 = 0
	UEclass0=-1;
	UEclass1=-1;
	UEclass2=-1;
	UEclass3=-1;
	area_zone1 = 0.2827
	area_zone2 = 0.8482
	area_zone3 = 2.0106
	area_total = 3.1416
	user_vbr = 20	
	user_cbr = 15
	user_be = 10
	se_64qam = 6
	se_16qam = 4
	se_qpsk = 2
	bw_supplied_macrocell = 5e6
	
	vbr_startTime = 1e6
	vbr_stopTime = 0
	cbr_startTime = 1e6
	cbr_stopTime = 0
	be_startTime = 1e6
	be_stopTime = 0
	
	
}	

{
	event = $1;
	time = $2;
	src_node = $3;
	dst_node = $4;
	pkt_type = $5;
	pkt_size = $6;
	flow_id = $8;
	src_addr = $9;
	split(src_addr,tmp,".");
	src = tmp[1];

if(src_node > 2 && flow_id == 0 && UEclass0 == -1) {
 	 UEclass0 = src_node;
}
if(src_node > 2 && flow_id == 1 && UEclass1 == -1) {
	 UEclass1 = src_node;
}
if(src_node > 2 && flow_id == 2 && UEclass2 == -1 ) {
 	 UEclass2 = src_node;
}

#################### THROUGHPUT CALCULATION #######################

# received throughput: UE<========eNB

if(event == "-" && (src_node == 0) && (dst_node > 2)) {
	 ue_r_bit[flow_id] = ue_r_bit[flow_id] + (pkt_size-8) * 8 ;

	 if(lineCount1==0) {
		 timeBegin1=time;
		 lineCount1++;
 	}
 		 timeEnd1=time;
 	         
  }

# sent throughput : UE========>eNB

if(event == "-" && (src == UEclass0) || (src == UEclass1) || (src == UEclass2)){
	ue_s_bit[flow_id] = ue_s_bit[flow_id] + pkt_size * 8;
	
	if(lineCount2==0) {
		 timeBegin2=time;
		 lineCount2++;
 	}
 		 timeEnd2=time;

   }

#################### DELAY CALCULATION (VBR) #######################	UE<========eNB


	if (event=="+" && flow_id == 0 && src_node==0 && dst_node>2){
	 	if (time < vbr_startTime) {
			vbr_startTime = time
		}
			vbr_pkt_tx++
	}

	if (event=="r" && flow_id == 0 && src_node==0 && dst_node>2){
	 	if (time > vbr_stopTime) {
			vbr_stopTime = time
		}
			vbr_pkt_rx++
	}
		
		vbr_delay = vbr_stopTime - vbr_startTime
		vbr_delay++

 	if (vbr_pkt_rx!=0) {
		vbr_avg_delay = vbr_delay/vbr_pkt_rx
	} 
	else {
	vbr_avg_delay = 0
   }


#################### DELAY CALCULATION (CBR) #######################	UE<========eNB
	if (event=="+" && flow_id == 1 && src_node==0 && dst_node>2){
	 	if (time < cbr_startTime) {
			cbr_startTime = time
		}
			cbr_pkt_tx++
	}

	if (event=="r" && flow_id == 1 && src_node==0 && dst_node>2){
	 	if (time > cbr_stopTime) {
			cbr_stopTime = time
		}
			cbr_pkt_rx++
	}
		
		cbr_delay = cbr_stopTime - cbr_startTime
		cbr_delay++

 	if (cbr_pkt_rx!=0) {
		cbr_avg_delay = cbr_delay/cbr_pkt_rx
	} 
	else {
	cbr_avg_delay = 0
   }

#################### DELAY CALCULATION (BE) #######################	UE<========eNB
	if (event=="+" && flow_id == 2 && src_node==0 && dst_node>2){
	 	if (time < be_startTime) {
			be_startTime = time
		}
			be_pkt_tx++
	}

	if (event=="r" && flow_id == 2 && src_node==0 && dst_node>2){
	 	if (time > be_stopTime) {
			be_stopTime = time
		}
			be_pkt_rx++
	}
		
		be_delay = be_stopTime - be_startTime
		be_delay++

 	if (be_pkt_rx!=0) {
		be_avg_delay = be_delay/be_pkt_rx
	} 
	else {
	be_avg_delay = 0
   }


}
END {

for(i=0;i<3;i++)
{
 duration1 =  timeEnd1 - timeBegin1;
 duration2 =  timeEnd2 - timeBegin2;


#convert to kbps
 ue_r[i] = ue_r_bit[i]/duration1/1e3;
 #ue_s[i] = ue_s_bit[i]/duration2/1e3;


#total : convert vector to scalar
 total_r = total_r + ue_r[i];
 #total_s = total_s + ue_s[i];

 }
 
 printf("\n");	 
 printf("\t\t\t\tVBR\t\tCBR\t\tBE\t\tTotal\n");
 printf("\n");
 printf("Rx. Throughput[Kbps]:\t\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",ue_r[0],ue_r[1],ue_r[2],total_r);

 #printf("\n");	 
 #printf("\t\t\t\tVBR\tCBR\tBE\tTotal\n");
 #printf("\n");
 printf("Tx. Throughput[Kbps]:\t\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",ue_s[0],ue_s[1],ue_s[2],total_s);

# total calculation
printf("Macrocell Throughput[Kbps]:\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",ue_r[0]+ue_s[0],ue_r[1]+ ue_s[1],ue_r[2]+ue_s[2],total_r+total_s);

 #printf("\nDelay");
#	printf(" %20s:  %d\n", "Start Time[s]", vbr_startTime);
#	printf(" %20s:  %d\n", "Stop Time[s]", vbr_stopTime);
#	printf(" %15s:  %d\n", "VBR-TX",vbr_pkt_tx);
#	printf(" %15s:  %d\n", "VBR-RX",vbr_pkt_rx);
#	printf(" %15s:  %g\n", "Delay", vbr_delay);
#	printf(" %15s:  %g\n", "Average Delay[ms]", vbr_avg_delay*1000);
#printf("\nDelay");
#	printf(" %20s:  %d\n", "Start Time[s]", cbr_startTime);
#	printf(" %20s:  %d\n", "Stop Time[s]", cbr_stopTime);
#	printf(" %15s:  %d\n", "CBR-TX",cbr_pkt_tx);
#	printf(" %15s:  %d\n", "CBR-RX",cbr_pkt_rx);
#	printf(" %15s:  %g\n", "Delay", cbr_delay);
#	printf(" %15s:  %g\n", "Average Delay[ms]", cbr_avg_delay*1000);
#printf("\nDelay");
#	printf(" %20s:  %d\n", "Start Time[s]", be_startTime);
#	printf(" %20s:  %d\n", "Stop Time[s]", be_stopTime);
#	printf(" %15s:  %d\n", "BE-TX",be_pkt_tx);
#	printf(" %15s:  %d\n", "BE-RX",be_pkt_rx);
#	printf(" %15s:  %g\n", "Delay", be_delay);
#	printf(" %15s:  %g\n", "Average Delay[ms]", be_avg_delay*1000);
	total_average_delay = vbr_avg_delay + cbr_avg_delay + be_avg_delay;
#	printf(" %15s:  %g\n", "Total_Average_Delay[ms]", total_average_delay*1000);
	

printf("Average Delay[ms]:\t\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",vbr_avg_delay*1000,cbr_avg_delay*1000,be_avg_delay*1000,total_average_delay*1000);




printf("\n");
# VBR Bits Generated:
vbr_generated_bit_zone1 = (area_zone1/area_total)* ue_r[0];
vbr_generated_bit_zone2 = (area_zone2/area_total)* ue_r[0];
vbr_generated_bit_zone3 = (area_zone3/area_total)* ue_r[0];

# CBR Bits Generated:
cbr_generated_bit_zone1 = (area_zone1/area_total)* ue_r[1];
cbr_generated_bit_zone2 = (area_zone2/area_total)* ue_r[1];
cbr_generated_bit_zone3 = (area_zone3/area_total)* ue_r[1];

# BE Bits Generated:
be_generated_bit_zone1 = (area_zone1/area_total)* ue_r[2];
be_generated_bit_zone2 = (area_zone2/area_total)* ue_r[2];
be_generated_bit_zone3 = (area_zone3/area_total)* ue_r[2];

#printf("Bits Distri in zone1[kbps]:\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",vbr_generated_bit_zone1,cbr_generated_bit_zone1,be_generated_bit_zone1,(vbr_generated_bit_zone1+cbr_generated_bit_zone1+be_generated_bit_zone1));

#printf("Bits Distri in zone2[kbps]:\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",vbr_generated_bit_zone2,cbr_generated_bit_zone2,be_generated_bit_zone2,(vbr_generated_bit_zone2+cbr_generated_bit_zone2+be_generated_bit_zone2));

#printf("Bits Distri in zone3[kbps]:\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",vbr_generated_bit_zone3,cbr_generated_bit_zone3,be_generated_bit_zone3,(vbr_generated_bit_zone3+cbr_generated_bit_zone3+be_generated_bit_zone3));

# Number of user in zone1
#printf("\n");
user_vbr_zone1 = user_vbr * (area_zone1/area_total)
user_cbr_zone1 = user_cbr * (area_zone1/area_total)
user_be_zone1 = user_be * (area_zone1/area_total) 
total_user_zone1 = user_vbr_zone1 + user_cbr_zone1 + user_be_zone1
#printf("Number of User in zone1:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",user_vbr_zone1,user_cbr_zone1,user_be_zone1,total_user_zone1);
# Number of user in zone2
user_vbr_zone2 = user_vbr * (area_zone2/area_total)
user_cbr_zone2 = user_cbr * (area_zone2/area_total)
user_be_zone2 = user_be * (area_zone2/area_total) 
total_user_zone2 = user_vbr_zone2 + user_cbr_zone2 + user_be_zone2
#printf("Number of User in zone2:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",user_vbr_zone2,user_cbr_zone2,user_be_zone2,total_user_zone2);
# Number of user in zone3
user_vbr_zone3 = user_vbr * (area_zone3/area_total)
user_cbr_zone3 = user_cbr * (area_zone3/area_total)
user_be_zone3 = user_be * (area_zone3/area_total) 
total_user_zone3 = user_vbr_zone3 + user_cbr_zone3 + user_be_zone3
#printf("Number of User in zone3:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",user_vbr_zone3,user_cbr_zone3,user_be_zone3,total_user_zone3);

printf("\n");
# VBR Bits Generated:
vbr_generated_bit_zone1 = user_vbr_zone1 * ue_r[0];
vbr_generated_bit_zone2 = user_vbr_zone2 * ue_r[0];
vbr_generated_bit_zone3 = user_vbr_zone3 * ue_r[0];

# CBR Bits Generated:
cbr_generated_bit_zone1 = user_cbr_zone1 * ue_r[1];
cbr_generated_bit_zone2 = user_cbr_zone2 * ue_r[1];
cbr_generated_bit_zone3 = user_cbr_zone3 * ue_r[1];

# BE Bits Generated:
be_generated_bit_zone1 = user_be_zone1 * ue_r[2];
be_generated_bit_zone2 = user_be_zone2 * ue_r[2];
be_generated_bit_zone3 = user_be_zone3 * ue_r[2];

#printf("Bits Generated in zone1[kbps]:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",vbr_generated_bit_zone1,cbr_generated_bit_zone1,be_generated_bit_zone1,(vbr_generated_bit_zone1+cbr_generated_bit_zone1+be_generated_bit_zone1));

#printf("Bits Generated in zone2[kbps]:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",vbr_generated_bit_zone2,cbr_generated_bit_zone2,be_generated_bit_zone2,(vbr_generated_bit_zone2+cbr_generated_bit_zone2+be_generated_bit_zone2));

#printf("Bits Generated in zone3[kbps]:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",vbr_generated_bit_zone3,cbr_generated_bit_zone3,be_generated_bit_zone3,(vbr_generated_bit_zone3+cbr_generated_bit_zone3+be_generated_bit_zone3));


# Required Bandwidth 
bw_required_zone1 = (vbr_generated_bit_zone1+cbr_generated_bit_zone1+be_generated_bit_zone1)*1000/se_64qam;
bw_required_zone2 = (vbr_generated_bit_zone2+cbr_generated_bit_zone2+be_generated_bit_zone2)*1000/se_16qam;
bw_required_zone3 = (vbr_generated_bit_zone3+cbr_generated_bit_zone3+be_generated_bit_zone3)*1000/se_qpsk;
bw_required_macrocell = bw_required_zone1 + bw_required_zone2 + bw_required_zone3;


#printf("\n");
#printf("Required Bandwidth in zone1 [MHz]:\t%1.4f\n", bw_required_zone1/1e6);
#printf("Required Bandwidth in zone2 [MHz]:\t%1.4f\n", bw_required_zone2/1e6);
#printf("Required Bandwidth in zone3 [MHz]:\t%1.4f\n", bw_required_zone3/1e6);
printf("Required Bandwidth in Macrocell [MHz]:\t%1.4f\n", bw_required_macrocell/1e6);
printf("Supplied Bandwidth in Macrocell [MHz]:\t%1.4f\n", bw_supplied_macrocell/1e6);

if (bw_required_macrocell > bw_supplied_macrocell) {
          extra_bw = (bw_required_macrocell - bw_supplied_macrocell)
		num_scn = extra_bw/1e6
		power_total = 1673 + 12 * num_scn 
    }
   else {
	num_scn = 0
}	
printf("Number of SCN:\t\t\t\t%d\n",num_scn)
printf("Total Power [Watt] : \t\t\t%1.2f\n", power_total)


}



function abs(value) {
	if (value < 0) value = 0-value
	return value
}













