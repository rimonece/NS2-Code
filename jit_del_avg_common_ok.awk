# # Common AWK file to calculate : Avg Delay with Avg Jitter


BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
}

{
	# Trace line format: WIRELESS NEW
	if ($2 == "-t") {
		event = $1
		time = $3
		pkt_type = $35
		pkt_size = $37		
		pkt_id = $41
                level=$19
    }

	# Trace line format: WIRELESS OLD					
	if ($2 != "-t") {
	    if ($4=="AGT" || $4=="RTR" || $4=="MAC") {
		event = $1
		time = $2
		pkt_id = $6
		pkt_size = $8
		pkt_type = $7
		level=$4
	}
	
	else {
	# Trace line format: WIRED
           	event = $1
		time = $2
		pkt_type = $5
		pkt_size = $6
		pkt_id = $12
		level= "AGT"
	}
}
	
	if (level == "AGT" && (event == "+" || event == "s") && sendTime[pkt_id] == 0 ) {
		if (time < startTime) {
			startTime = time
		}
		sendTime[pkt_id] = time
	}

	
	if (level == "AGT" && event == "r" ) {
		if (time > stopTime) {
			stopTime = time
		}
		recvTime[pkt_id] = time

		hdr_size = pkt_size % 512
		pkt_size = pkt_size - hdr_size
		recvdSize = recvdSize + pkt_size
	}
}

END {
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
# To calculate "Jitter"

jitter1 = jitter2 = jitter3 = jitter4 = jitter5 = 0
prev_time = delay = prev_delay = processed = deviation = 0
prev_delay = -1

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
	
	printf(" %15s:  %d\n", "startTime", startTime)
	printf(" %15s:  %d\n", "stopTime", stopTime)
	printf(" %15s:  %g\n", "receivedPkts", recvdNum)
	printf(" %15s:  %g\n", "avgJitter1[ms]", jitter1)
	printf(" %15s:  %g\n", "avgJitter2[ms]", jitter2)
	printf(" %15s:  %g\n", "avgJitter3[ms]", jitter3*1000)
	printf(" %15s:  %g\n", "avgJitter4[ms]", jitter4*1000)

}

function abs(value) {
	if (value < 0) value = 0-value
	return value
}
