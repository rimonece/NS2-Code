# Find out the packet delivery ratio of the network:Common

   BEGIN {
         sendLine = 0;
         recvLine = 0;
         fowardLine = 0;
	 dropLine = 0;
  }
   
  $0 ~/^s.* AGT/ {
          sendLine ++ ;
  }
   
  $0 ~/^r.* AGT/ {
          recvLine ++ ;
  }
   
  $0 ~/^f.* RTR/ {
          fowardLine ++ ;
  }
   
  $0 ~/^D.* cbr/ {

        dropLine ++ ;

}
 
 END {
          printf "CBR Packets:\n send:%d receive:%d PDR:%.4f forward:%d drop:%d\n", sendLine, recvLine, (recvLine/sendLine),fowardLine, dropLine;
}
  


