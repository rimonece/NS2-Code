# Common AWK file to calculate :  Avg Delay

BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0
}

{	
	# Trace line format: WIRELESS NEW
	if ($2 == "-t") {
		event = $1
		time = $3
		pkt_type = $35
		pkt_size = $37		
		pkt_id = $41
		level = $19
    }

	# Trace line format: WIRELESS OLD					
	if ($2 != "-t") {
	    if ($4=="AGT" || $4=="RTR" || $4=="MAC") {
		event = $1
		time = $2
		pkt_id = $6
		pkt_size = $8
		pkt_type = $7
		level = $4
	}
	   else {
	# Trace line format: WIRED
           	event = $1
		time = $2
		pkt_type = $5
		pkt_size = $6
		pkt_id = $12
		level = "AGT"
	}
}

	if ((event == "+" || event == "s") && level=="AGT" && sendTime[pkt_id]== 0) {
	
	if (time < startTime) {
		startTime = time
		}
	        sendTime[pkt_id] = time
	}
	
	if (event == "r" && level=="AGT") {
		
	if (time > stopTime) {
		stopTime = time
	}
 	recvTime[pkt_id] = time	
		
	# Rip off the header
	hdr_size = pkt_size % 512
  	pkt_size = pkt_size - hdr_size
	recvdSize = recvdSize + pkt_size
    }
}

END{
	
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
		}
	else {
	     avg_delay = 0
   	}
printf(" %15s:  %g\n", "avgDelay[ms] overall", avg_delay*1000)
}
