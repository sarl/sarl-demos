#!/bin/bash

# A very simple bash script to run demos
# It should work with other SARL projects using Maven
# Example (run FactorialQuery Demo)
# In console 1:
# ./run.sh io.sarl.demos.queryfactorial.FactorialAgent
# In console 2:
# ./run.sh io.sarl.demos.queryfactorial.FactorialQueryAgent



#Configuration Variables

# replace with eth0, wlan0 ... to use an specific interface
NET_IFACE=""

#Encryptation Key
AES_KEY="CHANGEMECHANGEME"

#Default Port. If used it will be changed to the next available one.
DEF_PORT=19118


################################
# Do not change from this point.
################################

usage()
{
    echo "\n USAGE: ./${0##*/} [AGENT_FQN] \n"
    echo "\t AGENT_FQN : Agent fully qualified name (e.g. io.sarl.demos.basic.HelloAgent)"
    exit
}


find_port()
{
	
    local host=${1}
    local port=${2}
	while : ; do
	    if nc -w 5 -z ${host-ip} ${port} 2>/dev/null
	    then
	        port=$(( $port + 1 ))
	    else
	    	PORT=$port
	        break
	    fi    
	done
    
}

[[ $# -ne 1 ]] && usage

#Get the first public IP
IP=`ifconfig $NET_IFACE| sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

#Find the port to use
find_port $IP $DEF_PORT

MVN=`which mvn`

JANUS_BOOT="exec:java -Dexec.mainClass=io.janusproject.Boot -Dnetwork.encrypter.aes.key=$AES_KEY -Dnetwork.pub.uri=tcp://$IP:$PORT"

AGENT="-Dexec.args='$*'"

RUN_CMD="$MVN $JANUS_BOOT $AGENT"

echo "--------------------------------------------------"
echo "- Running Janus Platfrom"
echo "- IP: $IP"
echo "- PORT: $PORT"
echo "- AGENT: $*"
echo "- RUN CMD: $RUN_CMD"
echo "--------------------------------------------------"

$RUN_CMD

