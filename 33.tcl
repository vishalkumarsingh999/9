set ns [new Simulator]
#Use colors to differentiate the traffics
$ns color 1 Blue
$ns color 2 Red
#Open trace and NAM trace file
set ntrace [open 33.tr w]
$ns trace-all $ntrace
set namfile [open 33.nam w]
$ns namtrace-all $namfile
#Finish Procedure
proc Finish {} {
global ns ntrace namfile
$ns flush-trace
close $ntrace
close $namfile
exec nam 33.nam &
#Calculate the number of packets dropped due to collision
puts "The number of packet drops due to collision is:"
exec grep "^d" 33.tr | cut -d " " -f 4 | grep -c "3" &
exit 0
}
#Create 6 nodes
for {set i 0} {$i < 6} {incr i} {
set n($i) [$ns node]
}
#Create duplex links between the nodes
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 0.2Mb 100ms DropTail
#Nodes n(3), n(4) and n(5) are considered in a LAN
set lan0 [$ns newLan "$n(3) $n(4) $n(5)" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]
#Orientation to the nodes
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right
#Set up queue between n(2) and n(3) and monitor the queue
$ns queue-limit $n(2) $n(3) 20
$ns simplex-link-op $n(2) $n(3) queuePos 0.5
#Setup TCP connection between n(0) and n(4)
set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n(0) $tcp0
set sink0 [new Agent/TCPSink/DelAck]
$ns attach-agent $n(4) $sink0
$ns connect $tcp0 $sink0
$tcp0 set fid_ 1
$tcp0 set window_ 8000
$tcp0 set packetSize_ 552
#Apply FTP application over TCP
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP
#Setup another TCP connection between n(5) and n(1)
set tcp1 [new Agent/TCP/Newreno]
$ns attach-agent $n(5) $tcp1
set sink1 [new Agent/TCPSink/DelAck]
$ns attach-agent $n(1) $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2
$tcp1 set window_ 8000
$tcp1 set packetSize_ 552
#Apply FTP application over TCP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
set file1 [open file1.tr w]
$tcp0 attach $file1
set file2 [open file2.tr w]
$tcp1 attach $file2
$tcp0 trace cwnd_
$tcp1 trace cwnd_
#Schedule the events
$ns at 0.1 "$ftp0 start"
$ns at 0.2 "$ftp1 start"
$ns at 24.8 "$ftp0 stop"
$ns at 24.9 "$ftp1 stop"
$ns at 25.0 "Finish"
#Run the simulation
$ns run
