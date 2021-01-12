# packet Calculation for VBR/CBR/TCP	 
 
BEGIN {
	
	vbr_pkt=0
	cbr_pkt=0
	tcp_pkt=0
	ack_pkt=0
	d0_pkt=0
	d1_pkt=0
	d2_pkt=0
	d_pkt=0
	total=0
	
}

{
	event = $1
	pkt_type = $5
	flow_id=$8
		
	if (flow_id==0 && event=="-" && $3==0 && $4>2) 
		vbr_pkt++
	if (flow_id==1 && event=="-" && $3==0 && $4>2) 
		cbr_pkt++
	if (flow_id==2 && event=="-" && $3==0 && $4>2) 
		tcp_pkt++
	if (flow_id==2 && event=="-" && $3>2 && $4==0) 
		ack_pkt++
	if (event == "d" && flow_id==0)
		d0_pkt++
	if (event == "d" && flow_id==1)
		d1_pkt++
	if (event == "d" && flow_id==2)
		d2_pkt++
	if ($1 == "d")
		d_pkt++
	total = vbr_pkt + cbr_pkt + tcp_pkt + ack_pkt + d0_pkt + d1_pkt + d2_pkt
	
}

END {
	printf("\n")
	printf(" %15s:  %d\n", "VBR", vbr_pkt)
	printf(" %15s:  %d\n", "CBR", cbr_pkt)
	printf(" %15s:  %d\n", "TCP", tcp_pkt)
	printf(" %15s:  %d\n", "ACK", ack_pkt)
	printf(" %15s:  %g\n", "DROP_VBR", d0_pkt)
	printf(" %15s:  %g\n", "DROP_CBR", d1_pkt)
	printf(" %15s:  %g\n", "DROP_TCP", d2_pkt)
	printf(" %15s:  %g\n", "DROP_TOTAL", d_pkt)
	printf(" %15s:  %g\n", "Total", total)
	
	
}
