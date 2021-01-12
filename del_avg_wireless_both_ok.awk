# Final awk acript for calculating Average End-to-End Delay for Wireless network (OLD_NEW).

BEGIN {
 	     seqno = -1;    
 	     droppedPackets = 0; 
    	     receivedPackets = 0; 
             count = 0;
}

{

 # Trace line format: NORMAL
  if ($2 != "-t") {
  event = $1
  time = $2
  level=$4
  pkt_size = $8
  pkt_type = $7
  pkt_id = $6
  }

 # Trace line format: NEW
 if ($2 == "-t") {
  event = $1
  time = $3
  level = $19
  pkt_size = $37
  pkt_type = $35
  pkt_id = $41
}

    if(level == "AGT" && event == "s" && pkt_id > seqno) {
            seqno = pkt_id;
    } 
    else if(level == "AGT" && event == "r") {
            receivedPackets++;
    } 
    else if ((event == "D" || event =="d") && pkt_type == "tcp" &&  pkt_size > 512){
            droppedPackets++;            
  } 

    #end-to-end delay

    if(level == "AGT" && event == "s") {
          start_time[pkt_id] = time;
    } 
    else if(event == "r" && pkt_type == "tcp") {
          end_time[pkt_id] = time;
    } 
    else if((event == "D" || event == "d") && pkt_type == "tcp") {
          end_time[pkt_id] = -1;
    } 
}
 
END {        
    for(i=0; i<=seqno; i++) {
          if(end_time[i] > 0) {
              delay[i] = end_time[i] - start_time[i];
                  count++;
        }

          else
       {
              delay[i] = -1;
        }
    }


    for(i=0; i<=seqno; i++) {
          if(delay[i] > 0) {
              n_to_n_delay = n_to_n_delay + delay[i];
        }         
    }
    n_to_n_delay = n_to_n_delay/count;


    print "\n";

    print "GeneratedPackets            = " seqno+1;

    print "ReceivedPackets             = " receivedPackets;

    print "Packet Delivery Ratio      = " receivedPackets/(seqno+1)*100"%";

    print "Total Dropped Packets      = " droppedPackets;

    print "Average End-to-End Delay    = " n_to_n_delay * 1000 " ms";

    print "\n";

} 

# http://205.196.121.184/fnufnnc17mwg/zjkxzk4bkrwqhkc/e2edelay.awk
# http://mohittahiliani.blogspot.dk/2010/02/few-more-awk-scripts-for-ns2.html
# ==================================================================
