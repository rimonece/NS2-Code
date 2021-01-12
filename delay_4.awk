#!/usr/bin/awk -f
# calculate each class delay

BEGIN{
}
{
	event = $1;
      time = $2;
      src_node = $3;
      dst_node = $4;
      trace_type = $5;
      pkt_size = $6;
      flag = $7;
	flow_id = $8
	pkt_id = $12;	
	
# delay: UE<========eNB

	if (event == "+" && src_node==0 && dst_node>2)
        {
		packet[pkt_id]=time;
	}
	
	if (event == "r" && src_node==0 && dst_node>2)
	{
		if(packet[pkt_id]!=0){
			delay[flow_id,0] = delay[flow_id,0] + time - packet[pkt_id];
			delay[flow_id,1] = delay[flow_id,1] + 1;
		}
	}
}
END {      
	for(flow_id=0;flow_id<3;flow_id++) {
		av_delay[flow_id]=delay[flow_id,0]/delay[flow_id,1];
		total[0] = total[0] + delay[flow_id,0];
		total[1] = total[1] + delay[flow_id,1];
	}
     	print "0		 1		 2		 3		 total";
	print av_delay[0],"	",av_delay[1],"	",av_delay[2],"	",  total[0]/total[1];
}
