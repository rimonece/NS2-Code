# Common AWK file to calculate : Avg Throughput, Avg Delay, Avg Jitter

BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0

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
	
	if (event=="+" && src_node==0 && dst_node>2 && sendTime[pkt_id] == 0){
		if (time < startTime) {
			startTime = time
		}
		sendTime[pkt_id] = time
}

	if (event == "r" && src_node==0 && dst_node>2) {
		if (time > stopTime) {
			stopTime = time
		}
		recvTime[pkt_id] = time
		recvdNum = recvdNum + 1  # Received Packet Number

	# To Rip-off Header
		hdr_size = pkt_size % 512
		pkt_size = pkt_size - hdr_size
		recvdSize = recvdSize + pkt_size
	}
}

END {

# To calculate "Average Throughput"

	if (recvdNum == 0) {
		printf("Warning: no packets were received, simulation may be too short  \n")
	}
	printf("\n")
	printf("Simultion Output:\n")
	printf("\n")
	printf("Throughput:\n")
	printf(" %20s:  %d\n", "Start Time[s]", startTime)
	printf(" %20s:  %d\n", "Stop Time[s]", stopTime)
	printf(" %20s:  %g\n", "Received Packets", recvdNum)
    	printf("\n")
	printf(" %15s:  %g\n", "Average Throughput[kbps]", (recvdSize/(stopTime-startTime))*(8/1000))


# To calculate "Average Delay"

	delay = avg_delay = recvdNum = 0
	
	for (i in recvTime) {
		if (sendTime[i] == 0) {
			printf("\nError in delay.awk: receiving a packet that wasn't sent %g\n",i)
		}
		delay = recvTime[i] - sendTime[i]
		delay = delay + 1
		recvdNum = recvdNum + 1
	}
	if (recvdNum != 0) {
		avg_delay = delay / recvdNum
	} else {
		avg_delay = 0
	}

	printf("\n")
	printf("Delay:\n")
	printf(" %20s:  %d\n", "Start Time[s]", startTime)
	printf(" %20s:  %d\n", "Stop Time[s]", stopTime)
	printf(" %20s:  %g\n", "Delay", delay)
	printf(" %20s:  %g\n", "Received Packets", recvdNum)
	printf("\n")
	printf(" %15s:  %g\n\n", "Avearge Delay[ms] ", avg_delay*1000)

	
# To calculate " Average Jitter"

jitter1 = jitter2 = jitter3 = jitter4 = jitter5 = 0
prev_time = delay = prev_delay = processed = deviation = 0
prev_delay = -1
recvdNum = recvdNum/4;

for (i=0; processed<recvdNum; i++) {  
	if(recvTime[i] != 0) {        
		if(prev_time != 0) {  

	delay = recvTime [i] - prev_time
	e2eDelay = recvTime[i] - sendTime[i]

	if(delay < 0) delay = 0
	if(prev_delay != -1) {
	
	jitter1 += abs(e2eDelay - prev_e2eDelay)
	jitter2 += abs(delay-prev_delay)
	jitter3 += (abs(e2eDelay-prev_e2eDelay) - jitter3) / 16
	jitter4 += (abs(delay-prev_delay) - jitter4) / 16

}
#	deviation += (e2eDelay-avg_delay)*(e2eDelay-avg_delay)
	prev_delay = delay
	prev_e2eDelay = e2eDelay
}
	prev_time = recvTime[i]
	processed++
}
	}
	if (recvdNum != 0) {
		jitter1 = jitter1*1000/recvdNum
		jitter2 = jitter2*1000/recvdNum
	}


	# Output
	if (recvdNum == 0) {
		printf("####################################################################\n" \
		       "#  Warning: no packets were received, simulation may be too short  #\n" \
		       "####################################################################\n\n")
	}
	
	printf("\n")
	printf("Jitter:\n")
	printf(" %15s:  %d\n", "startTime", startTime)
	printf(" %15s:  %d\n", "stopTime", stopTime)
	printf(" %15s:  %g\n", "receivedPkts", recvdNum)
	printf("\n")
	printf(" %15s:  %g\n", "avgJitter1[ms]", jitter1)
	printf(" %15s:  %g\n", "avgJitter2[ms]", jitter2)
	printf(" %15s:  %g\n", "avgJitter3[ms]", jitter3*1000)
	printf(" %15s:  %g\n", "avgJitter4[ms]", jitter4*1000)

}

function abs(value) {
	if (value < 0) value = 0-value
	return value
}
