# Final awk script to measure average throughput for WIRED-cum-WIRELESS-NEW network.	 
 
BEGIN {
	tcp_pkt=0
	cbr_pkt=0
	ack_pkt=0
	rtp_pkt=0
	rtcp_pkt=0
	
}

{
	event = $1
	pkt_type = $5
	src_node = $3
	dst_node = $4
	flow_id = $8

	
	if ((pkt_type =="cbr") && src_node ==0 && (dst_node > 2 && dst_node < 13) && event=="r") 
		cbr_pkt++

	if ((pkt_type =="tcp") && event=="r"){
		if (src_node >2 && dst_node == 0) 
			tcp_pkt1++
		if (src_node==1 && dst_node==2)
			tcp_pkt2++
		if (src_node==2 && dst_node==1)
			tcp_pkt3++
		tcp_pkt=tcp_pkt1+tcp_pkt2+tcp_pkt3
}

	if ((pkt_type =="ack") && event=="r"){
		if (src_node ==0 && dst_node >= 2) 
			ack_pkt1++
		if (src_node==2 && dst_node==1)
			ack_pkt2++
		if (src_node>2 && dst_node==0)
			ack_pkt3++
		ack_pkt=ack_pkt1+ack_pkt2+ack_pkt3
}

	if (pkt_type =="rtp") 
		rtp_pkt++
	if (pkt_type =="rtcp") 
		rtcp_pkt++	
	
}

END {
	printf("\n")
	printf(" %15s:  %d\n", "TCP", tcp_pkt)
	printf(" %15s:  %d\n", "CBR", cbr_pkt)
	printf(" %15s:  %g\n", "ACK", ack_pkt)
	printf(" %15s:  %g\n", "RTP", rtp_pkt)
	printf(" %15s:  %g\n", "RTCP", rtcp_pkt)
	
}S
