 # Final awk script to measure average end-to-end delay for wireless network_NEW.  ==>(MAHA)


BEGIN {
  
   highest_packet_id = 0;
   avg_delay = 0.0;
   count = 1;
}
	
{
                action = $1
		time = $3
		node_id = $5
		flow_id = $39
		packet_id = $41
		pkt_size = $37
		
   if ( packet_id > highest_packet_id ) 
		highest_packet_id = packet_id;

   if ( start_time[packet_id] == 0 )  
		start_time[packet_id] = time;
   
   if ( action == "r" ) { 
	        end_time[packet_id] = time;
      }
	
   else {
         end_time[packet_id] = -1;
   }
}					
		  
END {
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) 
	{
          packet_duration = end_time[packet_id] - start_time[packet_id]; 

       if ( packet_duration > 0) {
       #printf("start=%d packet_duration=%f\n", start, packet_duration);
       avg_delay = avg_delay + packet_duration;
       count = count + 1; 
       #printf(" count=%d avg_delay=%f\n",count,avg_delay);
       }
   }
printf("Average end-to-end delay : %f\n",avg_delay/count);
exit(0);
}
