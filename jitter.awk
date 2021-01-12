#!/usr/bin/awk -f
#calculate each class jitter

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
	
	

if (event == "+" && src_node== 0)
	{
		packet[pkt_id]=time;
	}

if (event == "r" && (dst_node >2)){

		if(packet[pkt_id]!=0){
			delay[flow_id,0] = time - packet[pkt_id];
			if(class[i]>0){
				if(delay[flow_id,0]>previous[flow_id])
					jitter[flow_id]=jitter[flow_id]+delay[flow_id,0]-previous[flow_id];
				if(delay[flow_id,0]<=previous[flow_id])
					jitter[flow_id]=jitter[flow_id]+previous[flow_id]-delay[flow_id,0];
			}
			if(class[i]==0){
				class[i]=class[i]+1;
			}
			previous[flow_id]=delay[flow_id,0];
			delay[flow_id,1] = delay[flow_id,1] + 1;
		}
	}
}

END {      
	for(flow_id=0;flow_id<3;flow_id++) {
		av_jitter[flow_id]=jitter[flow_id]/(delay[flow_id,1]-1);
		total[0] = total[0] + jitter[flow_id];
		total[1] = total[1] + delay[flow_id,1]-1;
	}
     	print "0		 1		 2		 3		 total";
	print av_jitter[0],"	",av_jitter[1],"	",av_jitter[2],"	",av_jitter[3],"	",total[0]/total[1];
}
