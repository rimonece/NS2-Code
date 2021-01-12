# Final awk script to measure average throughput for WIRED-cum-WIRELESS-OLD network.	 
 
BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0
}

{
	 # Trace line format: WIRELESS OLD
	   if ($4=="AGT" || $4=="RTR" || $4=="MAC") {
		event = $1
		time = $2
		level = $4
		pkt_id = $6
		pkt_size = $8
		pkt_type = $7
	}
	   else {
	# Trace line format: WIRED
           	event = $1
		time = $2
		pkt_type = $5
		pkt_size = $6
		pkt_id = $12
	}

	if ((event == "+" || event == "s") && pkt_type=="tcp" && pkt_size>=512) {
	
	if (time < startTime) {
		startTime = time
		}
	}
	
	if ((event == "r") && pkt_type=="tcp" && pkt_size>=512) {
		
	if (time > stopTime) {
		stopTime = time
	}
		
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
