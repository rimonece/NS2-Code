# http://mailman.isi.edu/pipermail/ns-users/2007-August/060808.html
#
#         AWK script for compute delay jitter
#    Jitter.awk
#



   BEGIN {
         num_recv=0
   }
   
  {
       # Trace line format: normal
       if ($2 != "-t") {
             event = $1
             time = $2
             if (event == "+" || event == "-") node_id = $3
             if (event == "r" || event == "d") node_id = $4
             flow_id = $8
             pkt_id = $12
             pkt_size = $6
             flow_t = $5
             level = "AGT"
       }
       # Trace line format: new
       if ($2 == "-t") {
             event = $1
             time = $3
             node_id = $5
             flow_id = $39
             pkt_id = $41
             pkt_size = $37
             flow_t = $45
             level = $19
       }
   
  # Store packets send time
  if (level == "AGT" && sendTime[pkt_id] == 0 && (event == "+" || event == "s") && pkt_size >= 512) {
       sendTime[pkt_id] = time
  }
   
  # Store packets arrival time
  if (level == "AGT" && event == "r" && pkt_size >= 512) {
             recvTime[pkt_id] = time
             num_recv++
       }
  }
   
  END {
       # Compute average jitter
       jitter1 = jitter2 = tmp_recv = 0
       prev_time = delay = prev_delay = processed = 0
       prev_delay = -1
       for (i=0; processed<num_recv; i++) {
             if(recvTime[i] != 0) {
                     tmp_recv++
                  if(prev_time != 0) {
                       delay = recvTime[i] - prev_time
                       e2eDelay = recvTime[i] - sendTime[i]
                       if(delay < 0) delay = 0
                       if(prev_delay != -1) {
                       jitter1 += abs(e2eDelay - prev_e2eDelay)
                       jitter2 += abs(delay-prev_delay)
                       }
                       prev_delay = delay
                       prev_e2eDelay = e2eDelay
                  }
                  prev_time = recvTime[i]
             }
             processed++
       }
  }
   
  END {
      
         printf("Jitter1 = %.2f\n",jitter1*1000/tmp_recv);
         printf("Jitter2 = %.2f\n",jitter2*1000/tmp_recv);
  }
   
  function abs(value) {
       if (value < 0) value = 0-value
       return value
  }
