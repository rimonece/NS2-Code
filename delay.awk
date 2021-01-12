#!/usr/bin/awk -f
# calculate each class delay

BEGIN{
}
{
	event = $1;
      time = $2;
      node_s = $3;
      node_d = $4;
      trace_type = $5;
      pkt_size = $6;
      flag = $7;
	classid = $8
	pkt_id = $12;	
	
	if (event == "+" && node_s >1)
	{
		packet[pkt_id]=time;
	}
	
#classid id =2 is HTTP traffic, cache is aGW
	if (event == "-" && ((node_d>0 && classid!=2)||(node_d>0&&classid==2)))
	{
		if(packet[pkt_id]!=0){
			delay[classid,0] = delay[classid,0] + time - packet[pkt_id];
			delay[classid,1] = delay[classid,1] + 1;
		}
	}
}
END {      
	for(classid=0;classid<4;classid++) {
		av_delay[classid]=delay[classid,0]/delay[classid,1];
		total[0] = total[0] + delay[classid,0];
		total[1] = total[1] + delay[classid,1];
	}
     	print "0		 1		 2		 3		 total";
	print av_delay[0],"	",av_delay[1],"	",av_delay[2],"	",av_delay[3],"	",total[0]/total[1];
}
