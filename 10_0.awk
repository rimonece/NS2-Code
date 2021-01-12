# ISD = 0.5

BEGIN {
	lineCount1 = 0
	lineCount2 = 0
	UEclass0=-1;
	UEclass1=-1;
	UEclass2=-1;
	UEclass3=-1;

	area_zone1 = 0.15
	area_zone2 = 0.3
	area_zone3 = 0.5
	area_total = 0.7854
	se_64qam = 6
	se_16qam = 4
	se_qpsk = 2
	bw_supplied_macrocell = 10
	
	vbr_startTime = 1e6
	vbr_stopTime = 0
	cbr_startTime = 1e6
	cbr_stopTime = 0
	be_startTime = 1e6
	be_stopTime = 0
	
	vbr_pkt=0
	cbr_pkt=0
	tcp_pkt=0
	ack_pkt=0
	d0_pkt=0
	d1_pkt=0
	d2_pkt=0
	d_pkt=0
	total_pkt=0
	sim_time = 10
	
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
	pkt_id = $12;
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


#################### PACKET CALCULATION #######################

	if (flow_id==0 && event=="-" && $3==0 && $4>2) 
		vbr_pkt++
	if (flow_id==1 && event=="-" && $3==0 && $4>2) 
		cbr_pkt++
	if (flow_id==2 && event=="-" && $3==0 && $4>2) 
		tcp_pkt++
	if (flow_id==2 && event=="-" && $3>2 && $4==0) 
		ack_pkt++
	if (flow_id==0 && event == "d" && $3==0 && $4>2)
		d0_pkt++
	if (flow_id==1 && event == "d" && $3==0 && $4>2)
		d1_pkt++
	if (flow_id==2 && event == "d" && $3==0 && $4>2)
		d2_pkt++
	d_pkt = d0_pkt + d1_pkt + d2_pkt
	total_pkt = vbr_pkt + cbr_pkt + tcp_pkt 
	
#################### THROUGHPUT CALCULATION #######################

# received throughput: UE<========eNB

if(event == "-" && (src_node == 0) && (dst_node > 2)) {
	 ue_r_bit[flow_id] = ue_r_bit[flow_id] + pkt_size * 8 ;

	 if(lineCount1==0) {
		 timeBegin1=time;
		 lineCount1++;
 	}
 		 timeEnd1=time;
 	         
  }

# sent throughput : UE========>eNB

if(event == "-" && (src == UEclass0) || (src == UEclass1) || (src == UEclass2)){
#if(event == "-" && (src_node > 2) && (dst_node ==0)) {
	ue_s_bit[flow_id] = ue_s_bit[flow_id] + pkt_size * 8;
	
	if(lineCount2==0) {
		 timeBegin2=time;
		 lineCount2++;
 	}
 		 timeEnd2=time;

   }

#################### DELAY CALCULATION (VBR) #######################	UE<========eNB


	if (event=="+" && flow_id == 0 && dst_node>2){
	 	if (time < vbr_startTime) {
			vbr_startTime = time
		}
			vbr_pkt_tx++
	}

	if (event=="r" && flow_id == 0 && dst_node>2){
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
	if (event=="+" && flow_id == 1 && dst_node>2){
	 	if (time < cbr_startTime) {
			cbr_startTime = time
		}
			cbr_pkt_tx++
	}

	if (event=="r" && flow_id == 1 && dst_node>2){
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
	if (event=="+" && flow_id == 2 && dst_node>2){
	 	if (time < be_startTime) {
			be_startTime = time
		}
			be_pkt_tx++
	}

	if (event=="r" && flow_id == 2 && dst_node>2){
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


#################### JITTER CALCULATION  #######################	

if (event == "+" && src_node== 2)
	{
		packet[pkt_id]=time;
	}

if (event == "r" && (dst_node >2)){

		if(packet[pkt_id]!=0){
			delay[flow_id,0] = time - packet[pkt_id];
			if(class[i]>0){
				if(delay[flow_id,0]>previous[flow_id])
					jitter[flow_id]=jitter[flow_id]+delay[flow_id,0]-previous[flow_id];
				if(delay[flow_id,0]<=previous[flow_id])
					jitter[flow_id]=jitter[flow_id]+previous[flow_id]-delay[flow_id,0];
			}
			if(class[i]==0){
				class[i]=class[i]+1;
			}
			previous[flow_id]=delay[flow_id,0];
			delay[flow_id,1] = delay[flow_id,1] + 1;
		}
	}
}


END {

for(i=0;i<3;i++)
{
 duration1 =  timeEnd1 - timeBegin1;
 duration2 =  timeEnd2 - timeBegin2;

#convert to Mbps
 ue_r[i] = ue_r_bit[i]/duration1/1e6;
 ue_s[i] = ue_s_bit[i]/duration2/1e6;


#total : convert vector to scalar
 total_r = total_r + ue_r[i];
 total_s = total_s + ue_s[i];

}
 
#================Throughput and Packet Calculation====================

 printf("\n");	 
 printf("\t\t\t\tConversational\t\tStreaming\t\tBackground\t\tTotal");
 printf("\n");
 printf("Tx. Throughput [Mbps]:\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\n",ue_s[0],ue_s[1],ue_s[2],total_s);
 printf("Rx. Throughput [Mbps]:\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\n",ue_r[0],ue_r[1],ue_r[2],total_r);


#================Delay Calculation====================
total_average_delay = vbr_avg_delay + cbr_avg_delay + be_avg_delay;
#	printf(" %15s:  %g\n", "Total_Average_Delay[ms]", total_average_delay*1000);
	

printf("Average Delay[ms]:\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\n",vbr_avg_delay*1000,cbr_avg_delay*1000,be_avg_delay*1000,total_average_delay*1000);


#================Jitter Calculation====================
for(flow_id=0;flow_id<3;flow_id++) {
		av_jitter[flow_id]=jitter[flow_id]/(delay[flow_id,1]-1);
		total[0] = total[0] + jitter[flow_id];
		total[1] = total[1] + delay[flow_id,1]-1;
	}

total_average_jitter = av_jitter[0]*1000 + av_jitter[1]*1000 + av_jitter[2]*1000;
printf("Average Jitter [ms]:\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\n",av_jitter[0]*1000,av_jitter[1]*1000,av_jitter[2]*1000,total_average_jitter);


 printf("\n");
 printf("No.of Rx.  Packet:\t\t%1.2f\t\t%1.2f\t\t\t%1.2f\t\t%1.2f\n",vbr_pkt,cbr_pkt,tcp_pkt,total_pkt);
 printf("No.of Drop Packet:\t\t%1.2f\t\t%1.2f\t\t\t%1.2f\t\t\t%1.2f\n",d0_pkt,d1_pkt,d2_pkt,d_pkt);

 printf("\n");

#===================Zonewise Distribution=============================

se = total_r/6;
ase = se/area_total;
printf("Area Spectral Efficiency(bps/Hz/Km^2:\t\t1.2f\n",ase);

vbr_bit_rate_zone1 = (area_zone1/area_total) * ue_r[0];
vbr_bit_rate_zone2 = (area_zone2/area_total) * ue_r[0];
vbr_bit_rate_zone3 = (area_zone3/area_total) * ue_r[0];

cbr_bit_rate_zone1 = (area_zone1/area_total) * ue_r[1];
cbr_bit_rate_zone2 = (area_zone2/area_total) * ue_r[1];
cbr_bit_rate_zone3 = (area_zone3/area_total) * ue_r[1];

be_bit_rate_zone1 = (area_zone1/area_total) * ue_r[2];
be_bit_rate_zone2 = (area_zone2/area_total) * ue_r[2];
be_bit_rate_zone3 = (area_zone3/area_total) * ue_r[2];

bit_rate_zone1 = vbr_bit_rate_zone1 + cbr_bit_rate_zone1 + be_bit_rate_zone1;
bit_rate_zone2 = vbr_bit_rate_zone2 + cbr_bit_rate_zone2 + be_bit_rate_zone2;
bit_rate_zone3 = vbr_bit_rate_zone3 + cbr_bit_rate_zone3 + be_bit_rate_zone3;

#bit_rate_zone1 = vbr_bit_rate_zone1 + vbr_bit_rate_zone2  + vbr_bit_rate_zone3; 
#bit_rate_zone2 = cbr_bit_rate_zone1 + cbr_bit_rate_zone2  + cbr_bit_rate_zone3; 
#bit_rate_zone3 = be_bit_rate_zone1 + be_bit_rate_zone2  + be_bit_rate_zone3; 



#====================Bandwidth calculation============================
bw_zone1 = (bit_rate_zone1)/se_64qam;
bw_zone2 = (bit_rate_zone2)/se_16qam;
bw_zone3 = (bit_rate_zone3)/se_qpsk;

# bandwidth calculation - total (Mbps)

bw_required_macrocell = bw_zone1 + bw_zone2 + bw_zone3;

printf("Required Bandwidth in Macrocell [MHz]:\t%1.4f\n", bw_required_macrocell);
printf("Supplied Bandwidth in Macrocell [MHz]:\t%1.4f\n", bw_supplied_macrocell);

if (bw_required_macrocell > bw_supplied_macrocell) {
          extra_bw = (bw_required_macrocell - bw_supplied_macrocell);
		num_scn = extra_bw;
	}
else {
	num_scn = 0
}	
power_total = 1673 + 12 * num_scn; 

printf("Number of SCN:\t\t\t\t%d\n",num_scn);
printf("Total Power [Watt] : \t\t\t%1.2f\n", power_total);

}
















