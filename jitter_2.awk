# Common AWK file to calculate : Avg Throughput, Avg Delay, Avg Jitter

BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	vbr_pkt_rx = 0

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
		vbr_stopTime[pkt_id] = time
		vbr_pkt_rx = vbr_pkt_rx + 1  # Received Packet Number

	# To Rip-off Header
		hdr_size = pkt_size % 512
		pkt_size = pkt_size - hdr_size
		recvdSize = recvdSize + pkt_size
	}
}

END {

# To calculate " Average Jitter" -------VBR

vbr_jitter1 = vbr_jitter2 = vbr_jitter3 = vbr_jitter4 = vbr_jitter5 = 0
vbr_prev_time = vbr_delay_for_jitter = vbr_prev_delay = vbr_processed = vbr_deviation = 0
vbr_prev_delay = -1

#for (v=0; vbr_processed < vbr_pkt_rx; v++) {  
	if(vbr_stopTime != 0) {        
		if(vbr_prev_time != 0) {  

	vbr_delay_for_jitter = vbr_stopTime - vbr_prev_time
	vbr_e2eDelay_for_jitter = vbr_stopTime - vbr_startTime

			if(vbr_delay_for_jitter < 0) {
				vbr_delay_for_jitter = 0
				}
			
			if(vbr_prev_delay != -1) {
				
	vbr_jitter1 += abs(vbr_e2eDelay_for_jitter - vbr_prev_e2eDelay)
	vbr_jitter2 += abs(vbr_delay_for_jitter - vbr_prev_delay)
	vbr_jitter3 += (abs(vbr_e2eDelay_for_jitter - vbr_prev_e2eDelay) - vbr_jitter3) / 16
	vbr_jitter4 += (abs(vbr_delay_for_jitter - vbr_prev_delay) - vbr_jitter4) / 16

}
#	deviation += (e2eDelay-avg_delay)*(e2eDelay-avg_delay)
	vbr_prev_delay = vbr_delay_for_jitter
	vbr_prev_e2eDelay = vbr_e2eDelay_for_jitter
}
	vbr_prev_time = vbr_stopTime
	#vbr_processed++
}
	
	if (vbr_pkt_rx != 0) {
		vbr_jitter1 = vbr_jitter1*1000/vbr_pkt_rx
		vbr_jitter2 = vbr_jitter2*1000/vbr_pkt_rx
	}


	# Output
	if (vbr_pkt_rx == 0) {
		printf("####################################################################\n" \
		       "#  Warning: no packets were received, simulation may be too short  #\n" \
		       "####################################################################\n\n")
	}
	
	printf("\n")
	printf("vbr_Jitter:\n")
	printf(" %15s:  %d\n", "startTime", vbr_startTime)
	printf(" %15s:  %d\n", "stopTime", vbr_stopTime)
	printf(" %15s:  %g\n", "receivedPkts", vbr_pkt_rx)
	printf("\n")
	printf(" %15s:  %g\n", "avgJitter1[ms]", vbr_jitter1)
	printf(" %15s:  %g\n", "avgJitter2[ms]", vbr_jitter2)
	printf(" %15s:  %g\n", "avgJitter3[ms]", vbr_jitter3*1000)
	printf(" %15s:  %g\n", "avgJitter4[ms]", vbr_jitter4*1000)

}

function abs(value) {
	if (value < 0) value = 0-value
	return value
}
