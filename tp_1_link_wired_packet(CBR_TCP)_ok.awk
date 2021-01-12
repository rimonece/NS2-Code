# Final awk script to measure THROUGHPUT of a particular link for WIRED network with specific Packet(CBR/TCP).

BEGIN {
lineCount = 0;
totalBits = 0;
}

# /^r/&& $3==2 && $4==3 && $5=="tcp" || $5=="cbr" {  

    /^r/&& $3==2 && $4==3 && $5=="tcp"{
    totalBits = totalBits + 8*$6;

   if(lineCount==0) {
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


