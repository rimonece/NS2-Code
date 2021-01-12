# Define the multicast mechanism 
set ns [new Simulator -multicast on] 
 
# Predefine tracing 
set f [open mmr_no_qos.tr w] 
$ns trace-all $f 
set nf [open mmr_no_qos.nam w] 
$ns namtrace-all $nf 
 
# Set the number of subscribers 
set numberClass0 20    
set numberClass1 15    
set numberClass2 10    
set number [expr {$numberClass0 + $numberClass1 + $numberClass2}] 
# qos_ means whether classfication/scheduling mechanism is used 
#Queue/LTEQueue set qos_ true 
#Queue/LTEQueue set qos_ false 
# flow_control_ is used in the model phase 
#Queue/LTEQueue set flow_control_ true 
 
 
# step 1: define the nodes, the order is fixed!! 
set eNB [$ns node];#node id is 0 
set aGW [$ns node];#node id is 1 
set server [$ns node];#node id is 2 
for { set i 0} {$i<$number} {incr i} { 
	set UE($i) [$ns node];#node id is > 2 
} 
 
# step 2: define the links to connect the nodes 
for { set i 0} {$i<$number} {incr i} { 
$ns simplex-link $UE($i) $eNB 10Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE($i) 10Mb 2ms LTEQueue/DLAirQueue 
} 
 
$ns simplex-link $eNB $aGW 2Mb 2ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 2Mb 2ms LTEQueue/DLS1Queue 

 
# The bandwidth between aGW and server is not the bottleneck. 
$ns simplex-link $aGW $server 5000Mb 2ms DropTail 
$ns simplex-link $server $aGW 5000Mb 2ms LTEQueue/DLQueue 
 
 
#--------manual set constant-------------((the best one until 17 Augus))-- 
# to change the RNG manually global defaultRNG 
#  to be changed manually from 1(default) to approximate value equal to 7.6x10^22 
$defaultRNG seed 10 
#---------------------------------------------- 
 
# step 3: define the traffic, based on  TR23.107 QoS concept and architecture 
#    class id class type simulation application
  
#    ------------------------------------------------- 
#    0:  Streaming:   VBR/UdpAgent (only downlink)
#    1:  Streaming:   CBR/UdpAgent (only downlink)
#    2:  Background:  FTP/TcpAgent   



# define the VBR traffic 
 for { set i 0} {$i < $numberClass0} {incr i} {
 set null($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null($i) $udp($i) 
 $udp($i) set class_ 0 
 set vbr($i) [new Application/Traffic/VBR] 
 $vbr($i) attach-agent $udp($i)
 $vbr($i) set rate_ 3.25Mb  # no. of VBR packets/sec(20:00) = 12840 * 210B
 $vbr($i) set rate_dev_ 0.25
 $vbr($i) set packetSize_ 210
 $vbr($i) set burst_time_ 1
 $vbr($i) set time_dev_ 0.5
 $ns at 0.4 "$vbr($i) start" 
 $ns at 30.4 "$vbr($i) stop" 
} 

# define the CBR traffic 
 for { set i $numberClass0} {$i< ($numberClass0+$numberClass1)} {incr i} { 
 set null($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null($i) $udp($i) 
 $udp($i) set class_ 1 
 set cbr($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i)
 $cbr($i) set rate_ 1.25Mb  # no. of CBR packets/sec(20:00) = 745 * 210B
 $cbr($i) set packetSize_ 210
 $ns at 0.5 "$cbr($i) start" 
 $ns at 30.5 "$cbr($i) stop" 
}  
 
# define the Background traffic 

for { set i [expr $numberClass0+$numberClass1]} {$i< 
($numberClass0+$numberClass1+$numberClass2)} {incr i} {   

 set sink($i) [new Agent/TCPSink] 
 $ns attach-agent $UE($i) $sink($i) 
 set tcp($i) [new Agent/TCP] 
 $tcp($i) set window_ 40
 $tcp($i) set packetSize_ 100
 $tcp($i) set minrto_ 0.2
 $ns attach-agent $server $tcp($i) 
 $ns connect $sink($i) $tcp($i) 
 $tcp($i) set class_ 2 
 set ftp($i) [new Application/FTP] 
 $ftp($i) attach-agent $tcp($i)
  
 $ns at 0.6 "$ftp($i) start" 
 $ns at 30.6 "$ftp($i) stop" 
} 
 
# finish tracing 
 $ns at 35 "finish" 
 proc finish {} { 
 global ns f nf 
 $ns flush-trace 
 close $nf
 close $f 
 exit 0 
} 
 
# Finally, start the simulation. 
$ns run
