# Common AWK file to calculate : Avg Throughput, Avg Delay, Avg Jitter

BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0
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


#################### DELAY CALCULATION (VBR) #######################	UE<========eNB	
if (event=="+" && flow_id == 0 && src_node==0 && dst_node>2 && vbr_sendTime[pkt_id] == 0){
		if (time < vbr_startTime) {
			vbr_startTime = time
		}
		vbr_sendTime[pkt_id] = time
}

if (event=="r" && flow_id == 0 && src_node==0 && dst_node>2) {
		if (time > vbr_stopTime) {
			vbr_stopTime = time
		}
		vbr_recvTime[pkt_id] = time
		vbr_recvdNum++  # Received Packet Number -VBR
	}

#################### DELAY CALCULATION (CBR) #######################	UE<========eNB
if (event=="+" && flow_id == 1 && src_node==0 && dst_node>2 && cbr_sendTime[pkt_id] == 0){
		if (time < cbr_startTime) {
			cbr_startTime = time
		}
		cbr_sendTime[pkt_id] = time
}

if (event=="r" && flow_id == 1 && src_node==0 && dst_node>2) {
		if (time > cbr_stopTime) {
			cbr_stopTime = time
		}
		cbr_recvTime[pkt_id] = time
		cbr_recvdNum++  # Received Packet Number -CBR
	}

#################### DELAY CALCULATION (BE) #######################	UE<========eNB
if (event=="+" && flow_id == 2 && src_node==0 && dst_node>2 && be_sendTime[pkt_id] == 0){
		if (time < be_startTime) {
			be_startTime = time
		}
		be_sendTime[pkt_id] = time
}

if (event=="r" && flow_id == 2 && src_node==0 && dst_node>2) {
		if (time > be_stopTime) {
			be_stopTime = time
		}
		be_recvTime[pkt_id] = time
		be_recvdNum++  # Received Packet Number -BE
	}

}
END {

#################### DELAY CALCULATION (VBR) #######################	UE<========eNB
{
	for (i in vbr_recvTime) {
		if (vbr_sendTime[i] == 0) {
			printf("\nError in delay.awk: receiving a packet that wasn't sent %g\n",i)
		}
		vbr_delay = vbr_recvTime[i] - vbr_sendTime[i]
		vbr_delay = vbr_delay + 1
		vbr_recvdNum++
	}
	if (vbr_recvdNum != 0) {
		vbr_avg_delay = vbr_delay / vbr_recvdNum
	} else {
		vbr_avg_delay = 0
	}

}

#################### DELAY CALCULATION (CBR) #######################	UE<========eNB
{	
	for (i in cbr_recvTime) {
		if (cbr_sendTime[i] == 0) {
			printf("\nError in delay.awk: receiving a packet that wasn't sent %g\n",i)
		}
		cbr_delay = cbr_recvTime[i] - cbr_sendTime[i]
		cbr_delay = cbr_delay + 1
		cbr_recvdNum++
	}
	if (cbr_recvdNum != 0) {
		cbr_avg_delay = cbr_delay / cbr_recvdNum
	} else {
		cbr_avg_delay = 0
	}

}
#################### DELAY CALCULATION (BE) #######################	UE<========eNB
{
	for (i in be_recvTime) {
		if (be_sendTime[i] == 0) {
			printf("\nError in delay.awk: receiving a packet that wasn't sent %g\n",i)
		}
		be_delay = be_recvTime[i] - be_sendTime[i]
		be_delay = be_delay + 1
		be_recvdNum++
	}
	if (be_recvdNum != 0) {
		be_avg_delay = be_delay / be_recvdNum
	} else {
		be_avg_delay = 0
	}

}

#printf("\nDelay");
	printf(" %20s:  %d\n", "vbr_Start Time[s]", vbr_startTime);
	printf(" %20s:  %d\n", "vbr_Stop Time[s]", vbr_stopTime);
	printf(" %15s:  %g\n", "vbr_delay", vbr_delay);
	printf(" %15s:  %d\n", "vbr_rx",vbr_recvdNum);	
	printf(" %15s:  %g\n", "vbr_Average Delay[ms]", vbr_avg_delay*1000);

	printf(" %20s:  %d\n", "cbr_Start Time[s]", cbr_startTime);
	printf(" %20s:  %d\n", "cbr_Stop Time[s]", cbr_stopTime);
	printf(" %15s:  %g\n", "cbr_delay", cbr_delay);
	printf(" %15s:  %d\n", "cbr_rx",cbr_recvdNum);	
	printf(" %15s:  %g\n", "cbr_Average Delay[ms]", cbr_avg_delay*1000);

	printf(" %20s:  %d\n", "be_Start Time[s]", be_startTime);
	printf(" %20s:  %d\n", "be_Stop Time[s]", be_stopTime);
	printf(" %15s:  %g\n", "be_delay", be_delay);
	printf(" %15s:  %d\n", "be_rx",be_recvdNum);	
	printf(" %15s:  %g\n", "be_Average Delay[ms]", be_avg_delay*1000);


	total_average_delay = vbr_avg_delay + cbr_avg_delay + be_avg_delay;
#	printf(" %15s:  %g\n", "Total_Average_Delay[ms]", total_average_delay*1000);
	

printf("Average Delay[ms]:\t\t%1.2f\t\t%1.2f\t\t%1.2f\t\t%1.2f\n",vbr_avg_delay*1000,cbr_avg_delay*1000,be_avg_delay*1000,total_average_delay*1000);

}


