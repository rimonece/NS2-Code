# Define the multicast mechanism 
set ns [new Simulator] 
 
# Predefine tracing 
set f [open 10_0.tr w] 
$ns trace-all $f 
#set nf [open mmr_on_on.nam w]
#$ns namtrace-all $nf 
 
# Set the number of subscribers 
set numberClass0 32    
set numberClass1 15    
set numberClass2 31   
set number [expr {$numberClass0 + $numberClass1 + $numberClass2}] 
 
Queue/LTEQueue set qos_ true 
 
# step 1: define the nodes, the order is fixed!! 
set eNB [$ns node];#node id is 0 

set aGW [$ns node];#node id is 1 
set server [$ns node];#node id is 2 
for { set i 0} {$i<$number} {incr i} { 
	set UE($i) [$ns node];#node id is > 2 
} 
 
# step 2: define the links to connect the nodes 
for { set i 0} {$i<$number} {incr i} { 
$ns simplex-link $UE($i) $eNB 5Mb 2ms LTEQueue/ULAirQueue 
#$ns queue-limit $UE($i) $eNB 5
$ns simplex-link $eNB $UE($i) 5Mb 2ms LTEQueue/DLAirQueue 
$ns queue-limit $eNB $UE($i) 3000
} 
 
$ns simplex-link $eNB $aGW 100Mb 2ms LTEQueue/ULS1Queue
#$ns queue-limit $eNB $aGW 6 
$ns simplex-link $aGW $eNB 100Mb 2ms LTEQueue/DLS1Queue 
#$ns queue-limit $aGW $eNB 2000
 
# The bandwidth between aGW and server is not the bottleneck. 
$ns simplex-link $aGW $server 1000Mb 2ms DropTail
#$ns queue-limit $aGW $server 5000  
$ns simplex-link $server $aGW 1000Mb 2ms LTEQueue/DLQueue 
#$ns queue-limit $server $aGW 5000 
  
#--------manual set constant-------------((the best one until 17 Augus))-- 
# to change the RNG manually global defaultRNG 
#  to be changed manually from 1(default) to approximate value equal to 7.6x10^22 
$defaultRNG seed 10 
#---------------------------------------------- 
 
# step 3: define the traffic, based on  TR23.107 QoS concept and architecture 
#    class id class type simulation application
  
#    ------------------------------------------------- 
#    0:  Conversational:   CBR/UdpAgent (Uplink + downlink)
#    1:  Streaming:   VBR/UdpAgent (only downlink)
#    2:  Background:  FTP/TcpAgent   

# define the Conversational traffic 
 
 for { set i 0} {$i < $numberClass0} {incr i} {
 set null($i) [new Agent/Null] 
 set nullS($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 $ns attach-agent $server $nullS($i) 
 set udp($i) [new Agent/UDP] 
 set udpUE($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns attach-agent $UE($i) $udpUE($i) 
 $ns connect $null($i) $udp($i) 
 $ns connect $nullS($i) $udpUE($i) 
 $udp($i) set class_ 0 
 $udpUE($i) set class_ 0 
 set cbr($i) [new Application/Traffic/CBR] 
 set cbrS($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i) 
 $cbrS($i) attach-agent $udpUE($i)
 $cbr($i) set rate_ 0.99Mb
 $cbrS($i) set rate_ 0.99Mb
 $ns at 1.5 "$cbr($i) start" 
 $ns at 1.5 "$cbrS($i) start" 
 $ns at 6.5 "$cbr($i) stop" 
 $ns at 6.5 "$cbrS($i) stop"  
 }

# define the Streaming traffic 
 for { set i $numberClass0} {$i< ($numberClass0+$numberClass1)} {incr i} { 
 set null1($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null1($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null1($i) $udp($i) 
 $udp($i) set class_ 1 
 set cbr($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i)
 $cbr($i) set rate_ 56.04Mb
 #$cbr($i) set packetSize_ 512  
 $ns at 2.5 "$cbr($i) start" 
 $ns at 7.5 "$cbr($i) stop" 
}  
 
# define the Background traffic 
for { set i [expr $numberClass0+$numberClass1]} {$i< 
($numberClass0+$numberClass1+$numberClass2)} {incr i} {   

 set sink($i) [new Agent/TCPSink] 
 $ns attach-agent $UE($i) $sink($i) 
 set tcp($i) [new Agent/TCP] 
 $ns attach-agent $server $tcp($i) 
 $ns connect $sink($i) $tcp($i) 
 $tcp($i) set class_ 2
 $tcp($i) set packetSize_ 1000
 #$tcp($i) set window_ 40
 set ftp($i) [new Application/FTP] 
 $ftp($i) attach-agent $tcp($i)
 $ns at 3.5 "$ftp($i) start" 
 $ns at 8.5 "$ftp($i) stop" 
} 
 
# finish tracing 
 $ns at 20 "finish" 
 proc finish {} { 
 global ns f 
 #global ns f nf 
 $ns flush-trace 
 #close $nf
 close $f 
 exit 0 
} 
 
# Finally, start the simulation. 
$ns run
