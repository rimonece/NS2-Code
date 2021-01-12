# Final awk script to measure "Throughput w.r.t Class" for a LTE network.

BEGIN {
	lineCount1 = 0
	lineCount2 = 0
	UEclass0=-1;
	UEclass1=-1;
	UEclass2=-1;
	UEclass3=-1;

}

{
	event = $1;
	time = $2;
	src_node = $3;
	dst_node = $4;
	pkt_type = $5;
	pkt_size = $6;
	flow_id = $8;
	src_addr = $9;
	split(src_addr,tmp,".");
	src = tmp[1];

if(src_node > 2 && flow_id == 0 && UEclass0 == -1) {
 	 UEclass0 = src_node;
}
if(src_node > 2 && flow_id == 1 && UEclass1 == -1) {
	 UEclass1 = src_node;
}
if(src_node > 2 && flow_id == 2 && UEclass2 == -1 ) {
 	 UEclass2 = src_node;
}
if(src_node > 2 && flow_id == 3 && UEclass3 == -1) {
	 UEclass3 = src_node;
}

# received throughput are the ones received by the UE : UE<========server

if(event == "-" && (src_node == 2)){
	 ue_r_bit[flow_id] = ue_r_bit[flow_id] + pkt_size * 8 ;

	 if(lineCount1==0) {
		 timeBegin1=time;
		 lineCount1++;
 	}
 		 timeEnd1=time;
 	         
  }

#  sent ones are the ones received by the server    : UE=============>server

if(event == "-" && (src == UEclass0) || (src == UEclass1) || (src == UEclass2) ||(src == UEclass3)){
	ue_s_bit[flow_id] = ue_s_bit[flow_id] + pkt_size * 8;
	
	if(lineCount2==0) {
		 timeBegin2=time;
		 lineCount2++;
 	}
 		 timeEnd2=time;

   }
}
	
END {
       for(i=0;i<4;i++)
{
 
 duration1 =  timeEnd1 - timeBegin1;
 duration2 =  timeEnd2 - timeBegin2;


#convert to kb
 ue_r[i] = ue_r_bit[i]/duration1/1e3;
 ue_s[i] = ue_s_bit[i]/duration2/1e3;


#total : convert vector to scalar
 total_r = total_r + ue_r[i];
 total_s = total_s + ue_s[i];

 }
 
 printf("\n");	 
 printf("\t\t\tclass0\tclass1\tclass2\tclass3\ttotal(kbps)\n");
 printf("\n");
 printf("ue_rx/server_tx:\t%1.2f\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",ue_r[0],ue_r[1],ue_r[2],ue_r[3],total_r);
 printf("ue_tx/server_rx::\t%1.2f\t%1.2f\t%1.2f\t%1.2f\t%1.2f\n",ue_s[0],ue_s[1],ue_s[2],ue_s[3],total_s);
 

}



