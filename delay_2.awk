# Find out the THROUGHPUT of the network

# calculate each class delay

BEGIN{
UEclass0=-1;
UEclass1=-1;
UEclass2=-1;
UEclass3=-1;
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
 src = $9;
split(src_,tmp,".");
src = tmp[1];
if(node_d > 2 && classid == 0 && UEclass0 == -1) {
 UEclass0 = node_d;
}
if(node_d > 2 && classid == 1 && UEclass1 == -1) {
 UEclass1 = node_d;
}
if(node_d > 2 && classid == 2 && UEclass2 == -1) {
 UEclass2 = node_d;
}
if(node_d > 2 && classid == 3 && UEclass3 == -1) {
 UEclass3 = node_d;
}

#   UE<==============eNB
if (event == "+" && node_s==0 && node_d>2)
 {
 packet[pkt_id]=time;
 }

#   UE<==============eNB
if (event == "r" && node_s==0 && node_d>2)
{
if(packet[pkt_id]!=0){
 delay[classid,0] = delay[classid,0] + time- packet[pkt_id];
 delay[classid,1] = delay[classid,1] + 1;
 }
 }



# UE to server
 if (event == "+" && node_s >2)
 {
 packet[pkt_id]=time;
 }

#classid id =2 is HTTP traffic, cache is aGW (event == "r" && node_d>=2)

 #if (event == "r" && (node_d==UEclass2) )
 if (event == "r" && (node_d>2 || node_d==1) )
 {
 if(packet[pkt_id]!=0){
 delayy[classid,0] = delayy[classid,0] + time - packet[pkt_id];
 delayy[classid,1] = delayy[classid,1] + 1;
 }
 }
}
END {
 for(classid=0;classid<4;classid++) {
 av_delay[classid]=delay[classid,0]/delay[classid,1];
 #av_delayy[classid]=delayy[classid,0]/delayy[classid,1];
 
 total[0] = total[0] + delay[classid,0] + delayy[2,0];
 #total[1] = total[1] + delay[classid,1] + delayy[2,1];
 }
 print "0 1 2 3 total";
 print av_delay[0]," ",av_delay[1],"  ",av_delayy[2]," ",av_delay[3]," ",total[0]/total[1];
} 
