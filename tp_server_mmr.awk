# Final awk script to measure "Throughput w.r.t Server" for a LTE network.	 
 
BEGIN {
	lineCount1 = 0
	lineCount2 = 0
	total_server_rx = 0
	total_server_tx  = 0
}

{
	event = $1
	time = $2
	src_node = $3
	dst_node = $4
	pkt_type = $5
	pkt_size = $6	
	flow_id = $8

# Server_RX Throughput: 
	if ((event=="-") && (dst_node==2)){
		total_server_rx=total_server_rx + 8 * pkt_size 
	
	if ( lineCount1==0 ) {
		timeBegin1 = time; 
		lineCount1++
		} 
		timeEnd1 = time;
	  }      

# Server_TX Throughput: 
	if ((event=="-") && (src_node==2)){	
		total_server_tx=total_server_tx + 8 * pkt_size 
		
	if ( lineCount2==0 ) {
		timeBegin2 = time; 
		lineCount2++
		} 
		timeEnd2 = time;
          } 
}	
END {
	duration1 = timeEnd1-timeBegin1;
	duration2 = timeEnd2-timeBegin2;
	
	printf("\n")
	printf(" %25s:  %d\n", "server_rx_start_time", timeBegin1)	
	printf(" %25s:  %d\n", "server_rx_end_time", timeEnd1)	
	printf(" %25s:  %d\n", "server_rx_bits", total_server_rx)
	printf(" %25s:  %d\n", "server_rx_duration", duration1)
	printf(" %25s:  %d\n", "server_rx_throughput[kbps]", total_server_rx/duration1/1e3)
	printf("\n")
	printf(" %25s:  %d\n", "server_tx_start_time", timeBegin2)	
	printf(" %25s:  %d\n", "server_tx_end_time", timeEnd2)	
	printf(" %25s:  %d\n", "server_tx_bits", total_server_tx)
	printf(" %25s:  %d\n", "server_tx_duration", duration2)
	printf(" %25s:  %d\n", "server_tx_throughput[kbps]", total_server_tx/duration2/1e3)

}

 






















