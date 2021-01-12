# Final awk script to measure "Throughput w.r.t UE" for a LTE network.		 
 
BEGIN {
	lineCount1 = 0
	lineCount2 = 0
	total_UE_sent = 0
	total_UE_receive = 0
}

{
	event = $1
	time = $2
	src_node = $3
	dst_node = $4
	pkt_type = $5
	pkt_size = $6	
	flow_id = $8

# UE_Sent Throughput: From UE to eNB (towards server)
	if ((event=="-") && (src_node>2)){
		total_UE_sent=total_UE_sent + 8 * pkt_size 
		
	if ( lineCount1==0 ) {
		timeBegin1 = time; 
		lineCount1 = lineCount1+1;
		} 
		timeEnd1 = time;
	  }      

# UE_Receive Throughput: From Server to aGW (towards UE)
	#if ((event=="-") && (src_node==2)){ 
	if ((event=="r") && (src_node==2) && (dst_node==1)){ 
		total_UE_receive=total_UE_receive + 8 * pkt_size 
		
	if ( lineCount2==0 ) {
		timeBegin2 = time; 
		lineCount2 = lineCount2+1;
		} 
		timeEnd2 = time;
          } 
}	
	
END {
	duration1 = timeEnd1-timeBegin1;
	duration2 = timeEnd2-timeBegin2;
	
	printf("\n")
	printf(" %25s:  %d\n", "UE_sent_start_time", timeBegin1)	
	printf(" %25s:  %d\n", "UE_sent_end_time", timeEnd1)	
	printf(" %25s:  %d\n", "UE_sent_bits", total_UE_sent)
	printf(" %25s:  %d\n", "UE_sent_duration", duration1)
	printf(" %25s:  %d\n", "UE_sent_throughput[kbps]", total_UE_sent/duration1/1e3)
	printf("\n")
	printf(" %25s:  %d\n", "UE_receive_start_time", timeBegin2)	
	printf(" %25s:  %d\n", "UE_receive_end_time", timeEnd2)	
	printf(" %25s:  %d\n", "UE_receive_bits", total_UE_receive)
	printf(" %25s:  %d\n", "UE_receive_duration", duration2)
	printf(" %25s:  %d\n", "UE_receive_throughput[kbps]", total_UE_receive/duration2/1e3)
}
























