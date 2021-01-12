#Final awk script to measure average end-to-end delay for wireless network_NEW+OLD ==> Specific Packet_CBR/TCP.

BEGIN { 
        sends = 0; 
        receives = 0; 
	routing_packets = 0; 
	end_to_end_delay = 0; 
	highest_packet_id = 0;
	} 
 
{ 
        if($2 == "-t"){
	action = $1;
	if(action!="d"){
        time = $3;
        packet_id = $41;
	level=$19;
	packet_type=$35; 
	}
}

        if($2!= "-t"){
	action = $1;
	if(action!="D"){
	time = $2;
	packet_id = $6;
	level=$4;
	packet_type=$7; 
	}
} 
	   
	#calculate the sent packets 
	if(action == "s" && level == "AGT" && packet_type == "tcp") 
		       sends++; 
		 
	#find the number of packets in the simulation 
	if(packet_id > highest_packet_id) 
		highest_packet_id = packet_id; 
		 
	#set the start time, only if its not already set 
	if(start_time[packet_id] == 0) 
		start_time[packet_id] = time; 
		 
	#calculate the receive packets
	if(action == "r" && level == "AGT" && packet_type == "tcp") 
		{	 
		       receives++; 
		       end_time[packet_id]= time; 
		} 
		else 
		       end_time[packet_id] = -1; 

	#calculate the routing packets
	if(action=="s" || action=="f" && $19=="RTR")
			routing_packets++;
}

END { 
	#calculate the packet duration for all the packets 
	
	for(packet_id = 0; packet_id < highest_packet_id; packet_id++) 
	{ 
              packet_duration = end_time[packet_id] - start_time[packet_id];     		
	        if(packet_duration > 0) 
			end_to_end_delay = end_to_end_delay + packet_duration;
	}
			        
        #calculate the average end-to-end packet delay 
	        avg_end_to_end_delay =  end_to_end_delay / receives;
	printf("Average End_to_End_Delay:%0.2f\n",avg_end_to_end_delay);
		pdfraction = (receives / sends) * 100; 
	printf ("CBR packets:\n sent:%d\n received:%d\n r/s Ratio:%0.2f\n routing:%d \n", sends, receives, pdfraction, routing_packets); 
}	

