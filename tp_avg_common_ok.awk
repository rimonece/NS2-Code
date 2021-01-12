# Common AWK file to calculate : Avg Throughput
 

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
	}
	
	if (level == "AGT" && event == "r" ) {
		
	if (time > stopTime) {
		stopTime = time
	}
 
		
		# Rip off the header
		hdr_size = pkt_size % 512
  		pkt_size = pkt_size - hdr_size
		

		recvdSize = recvdSize + pkt_size
		recvdNum = recvdNum + 1
	}
}

END {
	
	if (recvdNum == 0) {
		printf("Warning: no packets were received, simulation may be too short  \n")
	}
	printf("\n")
	printf(" %15s:  %d\n", "startTime", startTime)
	printf(" %15s:  %d\n", "stopTime", stopTime)
	printf(" %15s:  %g\n", "receivedPkts", recvdNum)
	printf(" %15s:  %g\n", "avgTput[kbps]", (recvdSize/(stopTime-startTime))*(8/1000))
}
