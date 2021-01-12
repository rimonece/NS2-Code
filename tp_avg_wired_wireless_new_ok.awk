# Final awk script to measure average throughput for WIRED-cum-WIRELESS-NEW network.	 
 
BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0
}

{
	
	# Trace line format: WIRED
	if ($2 != "-t") {
		event = $1
		time = $2
		pkt_id = $12
		pkt_size = $6
		pkt_type = $5
		flow_id = $8
	}

	# Trace line format: WIRELESS NEW
	if ($2 == "-t") {
		event = $1
		time = $3
		pkt_type = $35
		pkt_size = $37		
		flow_id = $39
		pkt_id = $41

	}

	if ((event == "+" || event == "s") && flow_id = "2" && pkt_type=="tcp" && pkt_size>=512) {
	
	if (time < startTime) {
		startTime = time
		}
	}
	
	if ((event == "r") && flow_id = "2" && pkt_type=="tcp" && pkt_size>=512) {
		
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
