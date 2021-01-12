# Final awk script to measure THROUGHPUT of a particular 1 link for WIRED network.

BEGIN {
fromNode=2; 
toNode=3;
lineCount = 0;
totalBits = 0;
type= tcp;
}

/^r/&& $3==fromNode &&$4==toNode{
    totalBits = totalBits + 8*$6;

if ( lineCount==0 ) {
timeBegin = $2; 
lineCount = lineCount+1;
} 

else {
timeEnd = $2;
 }
}

END{
duration = timeEnd-timeBegin;
print "Number of records is\t" NR;
print "Number of records is\t" NF;
print "Output:\n";
print "Transmission:N" fromNode "->N" toNode; 
print "Total transmitted bits = "totalBits" bits";
print "Duration = "duration" s"; 
print "Thoughput = "totalBits/duration/1e3" kbps"; 
}


