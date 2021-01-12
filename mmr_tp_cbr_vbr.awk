
BEGIN { 
recv=0
tcpreceiveddata=0
tcpatdata=0
tcpack=0
acksize=0
tcpreceivedack=0
cbrreceived=0
cbrat=0
cbrdata=0
vbrreceived=0
vbrdata=0
cbrsimtime=0
vbrsimtime=0
}


#===========TCP received Data @ Destination UE ===========
{
if ($1 == "r" && $9 == "tcp" && $7>2){
tcpreceiveddata+=1
pkt_size = $11
recv += pkt_size-20
simtime=$3
}

#===========TCP packet Data @ eNB===========
if ($1 == "r" && $9 == "tcp" && $7==1){
tcpatdata+=1
}

#===========TCP received Acknowledged Data @ from Server===========
if ($1 == "r" && $9 == "ack" && $7==2){
tcpreceivedack+=1
acksize+=$11
}


#===========TCP Acknowledged Data @ eNB===========
if ($1 == "r" && $9 == "ack" && $7==0){
tcpack+=1
}


#===========CBR received Data @ UE===========
if ($1 == "r" && $9 == "cbr" && $7>2){
cbrreceived+=1
cbrdata+=$11-8
if (cbrsimtime==0){
cbrstarttime=$3
}
cbrsimtime=$3
}

#===========CBR received Data @ Server===========
if ($1 == "r" && $9 == "cbr" && $7==1){
cbrat+=1
}


#===========VBR received Data @ UE===========
if ($1 == "r" && $9 == "vbr" && $7>2){
vbrreceived+=1
vbrdata+=$11-8
if (vbrsimtime==0){vbrstarttime=$3
}
vbrsimtime=$3
}

#===========VBR received Data @ Server===========
if ($1 == "r" && $9 == "vbr" && $7==1){
vbrat+=1
}

}


END { 
#printf("TCP simulation time      :%g\n", simtime);
#printf("TCP sent data packets    :%g\n", tcpatdata);
#printf("TCP received data packets:%g\n", tcpreceiveddata);
#printf("TCP Throughput           :%g\n", (recv/simtime)*(8/1000));

#printf("CBR simulation time      :%g\n", cbrsimtime);
#printf("CBR sent data packets    :%g\n", cbrat);
#printf("CBR received data packets:%g\n", cbrreceived);
#printf("CBR Throughput           :%g\n", (cbrdata/(cbrsimtime-cbrstarttime))*(8/1000));

#printf("VBR simulation time      :%g\n", vbrsimtime);
#printf("VBR sent data packets    :%g\n", vbrat);
#printf("VBR received data packets:%g\n", vbrreceived);
printf("VBR Throughput           :%g\n", (vbrdata/(vbrsimtime-vbrstarttime))*(8/1000));

#printf("System Throughput[kbps] :%g\n",((recv+cbrdata+vbrdata)/(simtime+cbrsimtime+vbrsimtime)*(8/1000)));
}

