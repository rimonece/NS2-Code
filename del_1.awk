#This program is used to calculate the end-to-end delay for CBR

BEGIN {

highest_packet_id = 0;

}

{

action = $1;

time = $2;

from = $3;

to = $4;

type = $5;

pktsize = $6;

flow_id = $8;

src = $9;

dst = $10;

seq_no = $11;

packet_id = $12;

if ( packet_id > highest_packet_id )

highest_packet_id = packet_id;

if ( start_time[packet_id] == 0 )

start_time[packet_id] = time;

if ( from== 0 && to > 2 && flow_id == 0 && action != "d" ) {

if ( action == "r" ) {

end_time[packet_id] = time;

}

} else {

end_time[packet_id] = -1;

}

}

END {

for ( packet_id = 1; packet_id <= highest_packet_id; packet_id++ ) {

start = start_time[packet_id];
end = end_time[packet_id];
packet_duration = end - start;
#Avg_value = packet_duration/packet_id;
}

printf("Required Bandwidth in Macrocell [MHz]:\t%1.4f\n", packet_duration);

if ( start < end ) 
{
#printf("%f \n", Avg_value);

}


}
