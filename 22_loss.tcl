# Define the multicast mechanism 
set ns [new Simulator -multicast on] 
 
# Predefine tracing 
set f [open 22.tr w] 
$ns trace-all $f 
#set nf [open mmr_on_on.nam w]
#$ns namtrace-all $nf 
 
# Set the number of subscribers 
set numberClass0 14    
set numberClass1 52    
set numberClass2 14   
set number [expr {$numberClass0 + $numberClass1 + $numberClass2}] 

Queue/LTEQueue set qos_ true 
#Queue/LTEQueue set flow_control_ false 
 
 
# step 1: define the nodes, the order is fixed!! 
set eNB [$ns node];#node id is 0 
set aGW [$ns node];#node id is 1 
set server [$ns node];#node id is 2 
for { set i 0} {$i<$number} {incr i} { 
	set UE($i) [$ns node];#node id is > 2 
} 
 
# step 2: define the links to connect the nodes 
for { set i 0} {$i<$number} {incr i} { 
$ns simplex-link $UE($i) $eNB 1Mb 2ms LTEQueue/ULAirQueue 
#$ns queue-limit $UE($i) $eNB 1
$ns simplex-link $eNB $UE($i) 1Mb 2ms LTEQueue/DLAirQueue 
$ns queue-limit $eNB $UE($i) 50
} 
 
$ns simplex-link $eNB $aGW 50Mb 2ms LTEQueue/ULS1Queue
#$ns queue-limit $eNB $aGW 6 
$ns simplex-link $aGW $eNB 50Mb 2ms LTEQueue/DLS1Queue 
#$ns queue-limit $aGW $eNB 100
 
# The bandwidth between aGW and server is not the bottleneck. 
$ns simplex-link $aGW $server 5000Mb 2ms DropTail
#$ns queue-limit $aGW $server 5000  
$ns simplex-link $server $aGW 5000Mb 2ms LTEQueue/DLQueue 
#$ns queue-limit $server $aGW 5000 

$defaultRNG seed 10 
 

# define the VBR traffic 
 for { set i 0} {$i < $numberClass0} {incr i} {
 set null0($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null0($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null0($i) $udp($i) 
 $udp($i) set fid_ 0 
 set vbr($i) [new Application/Traffic/CBR] 
 $vbr($i) attach-agent $udp($i)
 $vbr($i) set rate_ 1.01Mb  

 set loss_module1 [new ErrorModel]
 $loss_module1 set rate_ 0.02
 $loss_module1 ranvar [new RandomVariable/Uniform]
 $loss_module1 drop-target [new Agent/Null]
 $ns lossmodel $loss_module1 $eNB $UE($i)
 $ns at 0.4 "$vbr($i) start" 
 $ns at 10.4 "$vbr($i) stop" 
} 

# define the CBR traffic 
 for { set i $numberClass0} {$i< ($numberClass0+$numberClass1)} {incr i} { 
 set null($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null($i) $udp($i) 
 $udp($i) set fid_ 1 
 set cbr($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i)
 $cbr($i) set rate_ 0.99Mb  
 
 set loss_module2 [new ErrorModel]
 $loss_module2 set rate_ 0.02
 $loss_module2 ranvar [new RandomVariable/Uniform]
 $loss_module2 drop-target [new Agent/Null]
 $ns lossmodel $loss_module2 $eNB $UE($i)
 $ns at 0.5 "$cbr($i) start" 
 $ns at 10.5 "$cbr($i) stop" 
}  
 
# define the Background traffic 
for { set i [expr $numberClass0+$numberClass1]} {$i< 
($numberClass0+$numberClass1+$numberClass2)} {incr i} {   
 
 set tcp($i) [new Agent/TCP/Linux]
 $tcp($i) set timestamps_ true
 $tcp($i) set fid_ 2  
 $ns attach-agent $server $tcp($i) 
 set sink($i) [new Agent/TCPSink/Sack1] 
 $ns attach-agent $UE($i) $sink($i)
 $ns connect $sink($i) $tcp($i) 
 set ftp($i) [new Application/FTP] 
 $ftp($i) attach-agent $tcp($i)
 $ftp($i) set type_ FTP

 set loss_module3 [new ErrorModel]
 $loss_module3 set rate_ 0.02
 $loss_module3 ranvar [new RandomVariable/Uniform]
 $loss_module3 drop-target [new Agent/Null]
 $ns lossmodel $loss_module3 $eNB $UE($i)

 $ns at 0.6 "$ftp($i) start" 
 $ns at 10.6 "$ftp($i) stop" 
} 

set loss_module4 [new ErrorModel]
$loss_module4 set rate_ 0.0002
$loss_module4 ranvar [new RandomVariable/Uniform]
$loss_module4 drop-target [new Agent/Null]
$ns lossmodel $loss_module4 $aGW $eNB

set loss_module5 [new ErrorModel]
$loss_module5 set rate_ 0.00002
$loss_module5 ranvar [new RandomVariable/Uniform]
$loss_module5 drop-target [new Agent/Null]
$ns lossmodel $loss_module5 $server $aGW

# finish tracing 
 $ns at 15 "finish" 
 proc finish {} { 
 global ns f 
 #global ns f nf 
 $ns flush-trace 
 #close $nf
 close $f 
 exit 0 
} 
 
$ns run
