
# Find out THROUGHPUT of a End-to-End WIRED network with flow id.

BEGIN {
fromNode=2; toNode=3;
src0 = 0.0; dst0 = 3.0;
src1 = 1.0; dst1 = 3.1;
flow_id_1=1;
flow_id_2=2;
lineCount0 = 0;totalBits0 = 0;
lineCount1 = 0;totalBits1 = 0;
}

/^r/ &&$3==fromNode &&$4==toNode &&$8==flow_id_1 {
    totalBits0 += 8*$6;
	if ( lineCount0==0 ) {
		timeBegin0 = $2; 
		lineCount0++;
} 
	else {
		timeEnd0 = $2;
}
}

/^r/ &&$3==fromNode &&$4==toNode &&$8==flow_id_2 {
    totalBits1 += 8*$6;
	if ( lineCount1==0 ) {
		timeBegin1 = $2; 
		lineCount1++;
} 
	else {
		timeEnd1 = $2;
}
}

END{
duration0 = timeEnd0-timeBegin0;
print "\nTransmission for TCP 0: source "src0".0" " -> Destination "dst0".0"; 
print "  - Total transmitted bits =" totalBits0 " bits";
print "  - Duration = " duration0  " s"; 
print "  - Thoughput = "  totalBits0/duration0/1e3 " kbps"; 
print " " ;

duration1 = timeEnd1-timeBegin1;
print "\nTransmission for TCP 1: source "src1".0" " -> Destination "dst1; 
print "  - Total transmitted bits =" totalBits1 " bits";
print "  - Duration = " duration1  " s"; 
print "  - Thoughput = "  totalBits1/duration1/1e3 " kbps"; 
print " " ; 
};























