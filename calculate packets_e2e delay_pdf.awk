
# Final awk script to measure send, receive, routing and drop packets. Packet
#delivery ratio, routing overhead, normalize routing load, average end to
#end delay for wireless network (OLD_NEW).

BEGIN {
	     sends=0;
	     recvs=0;
	     routing_packets=0.0;
	     droppedBytes=0;
	     droppedPackets=0;
	     highest_packet_id =0;
	     sum=0;
	     recvnum=0;
	   }

{
	if($2 == "-t"){
	action = $1;
	time = $3;
        packet_id = $41;
	level=$19;
	packet_type=$35; 
	}


        if($2!= "-t"){
	action = $1;
	time = $2;
	packet_id = $6;
	level=$4;
	packet_type=$7; 
	}




# CALCULATE PACKET DELIVERY FRACTION

if (( action== "s") &&  ( packet_type == "tcp" ) && ( level =="AGT" )) {
sends++; }

if ( start_time[packet_id] == 0 )  
	start_time[packet_id] = time;

if (( action == "r") &&  ( packet_type == "tcp" ) && ( level =="AGT" ))   {
	recvs++;
	end_time[packet_id] = time; 
}

else {  
        end_time[packet_id] = -1;  
}

# CALCULATE TOTAL DSR OVERHEAD 

	if ((action == "s" || action == "f") && level == "RTR" && packet_type =="DSR")
routing_packets++;

# DROPPED DSR PACKETS 

	if (( action == "d" ) && ( packet_type == "cbr" )  && ( $3 > 0 ))

	     {
	           droppedBytes=droppedBytes+$37;
	           droppedPackets=droppedPackets+1;
	     }

#find the number of packets in the simulation

   if (packet_id > highest_packet_id)
	           highest_packet_id = packet_id;
}

END {
	for ( i in end_time )
	{
	start = start_time[i];
	end = end_time[i];
	packet_duration = end - start;
	if ( packet_duration > 0 )  
	{    
	sum =sum + packet_duration;
        recvnum=recnum+1; 
	}
}

	   delay=sum/recvnum;
	   NRL = routing_packets/recvs;  #normalized routing load 
	   PDF = (recvs/sends)*100;  #packet delivery ratio[fraction]
	   printf("send = %.2f\n",sends);

	   printf("recv = %.2f\n",recvs);

	   printf("routingpkts = %.2f\n",routing_packets++);

	   printf("PDF = %.2f\n",PDF);

	   printf("NRL = %.2f\n",NRL);

	   printf("Average e-e delay(ms)= %.2f\n",delay*1000/1e6);

	   printf("No. of dropped data (packets) = %d\n",droppedPackets);

	   printf("No. of dropped data (bytes)   = %d\n",droppedBytes);

	}


	
