set ns [new Simulator] 
set nf [open 1.nam w] 
set tf [open 1.tr w] 
$ns namtrace-all $nf
$ns trace-all $tf
proc  finish {  } { 
global ns nf tf
$ns flush-trace
close $nf
close $tf
exec nam 1.nam &
exit 0
}
set n0 [$ns node] 
set n1 [$ns node]
set n2 [$ns node]
$ns duplex-link $n0 $n1 500Mb 10ms DropTail 
$ns duplex-link $n1 $n2 100Mb 5ms DropTail 
$ns queue-limit $n0 $n1 10
$n0 label "UDP"
$n2 label "NULL"
set udp0 [new Agent/UDP] 
$ns attach-agent $n0 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n2 $null0
$ns color 1 Red
$udp0  set fid_  1
set cbr0 [new Application/Traffic/CBR] 
$cbr0 set packetSize_  500 
$cbr0 set interval_  0.005
$cbr0 attach-agent $udp0
$ns connect $udp0 $null0
$ns at 0.1 "$cbr0 start"
$ns at 1.0 "finish"
$ns run
