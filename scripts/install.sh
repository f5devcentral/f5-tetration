#!/bin/sh
declare -a viparray
declare -a poolarray
declare -a membersarray
rm *.txt 
 is_valid() {
    IP_ADDRESS="$1"
    # Check if the format looks right_
    echo "$IP_ADDRESS" | egrep -qE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || return 1
    #check that each octect is less than or equal to 255:
    echo $IP_ADDRESS | awk -F'.' '$1 <=255 && $2 <= 255 && $3 <=255 && $4 <= 255 {print "Y" } ' | grep -q Y || return 1
    return 0
}

echo "\033[0;31m Attention --->  Please Enter Contrl C to Quit this Program ....\033[0m \n"
echo "\033[0;32m This script will automatically deploy the iRules required for Tetration \033[0m \n"
while :
do
echo "\033[1mPlease enter BIG-IP Management IP : \033[0m \c"
read BIGIP_MGMT_IP
while ! is_valid "$BIGIP_MGMT_IP"
do
    read -p "Not an IP. Re-enter: " BIGIP_MGMT_IP
done

echo "\033[1mPlease enter BIG-IP ADMIN USER : \033[0m \c"
read BIGIP_ADMIN
echo "\033[1mPlease enter BIG-IP PASSWORD : \033[0m \c"
read BIGIP_PASS

#Check if Irules Exists locally on your computer

if [  \( -e Tetration_TCP_L4_ipfix.json \) -o \( -e Tetration_UDP_L4_ipfix.json \) ]
then 
	echo "\033[1mIrule Exists locally on your machine \033[0m .. hit enter...to proceed \c"
	read 
	sleep 2
else
	echo "\033[1mIrule missing ... locally will fetch from Github ...\033[0m \c"
	curl https://raw.githubusercontent.com/f5devcentral/f5-tetration/master/irules/Tetration_TCP_L4_ipfix.json -o Tetration_TCP_L4_ipfix
	curl https://raw.githubusercontent.com/f5devcentral/f5-tetration/master/irules/Tetration_UDP_L4_ipfix.json -o Tetration_UDP_L4_ipfix
	
     if [  \( -e Tetration_TCP_L4_ipfix.json \) -o \( -e Tetration_UDP_L4_ipfix.json \) ]
     	then
     	echo "\033[1mNow Irule Exists locally on your machine \033[0m .. hit enter...to proceed \c"
     else
	echo "Please visit https://github.com/f5devcentral/f5-tetration for additional information "
	sleep 120
	exit
    fi

fi


## Check if iRule exists in BIG-IP
echo "\033[1mChecking if irule Exists on BIG-IP ...... \033[0m \c "
sleep 2

response=$(curl --write-out %{http_code} --silent --output /dev/null -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_UDP_L4_ipfix)
if [ "$response" == 200 ] 
  then 
  #Update Irule Prime, make sure user clone the new repo
  curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH -d @Tetration_UDP_L4_ipfix.json https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_UDP_L4_ipfix | python -m json.tool
  echo "\033[1m UDP Irule exists on BIG-IP already \033[0m \c"
else
  sleep 2
  curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X POST -d @Tetration_UDP_L4_ipfix.json https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule | python -m json.tool
fi
tcpresponse=$(curl --write-out %{http_code} --silent --output /dev/null -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_TCP_L4_ipfix)
if [ "$tcpresponse" == 200 ]
  then
  #Update Irule Prime, make sure user has Prime irule locally by cloning
  echo "\033[1m TCP Irule exists on BIG-IP already \033[0m \c"
  curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH -d @Tetration_TCP_L4_ipfix.json https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_TCP_L4_ipfix | python -m json.tool
else
  sleep 2
curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X POST -d @Tetration_TCP_L4_ipfix.json https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule | python -m json.tool
fi


#Check if the IPFIX Pool exists on BIG-IP
# vng
echo "\033[1m Cisco Tetration requires 3 F5 IPFIX sensor per BIG-IP \033[0m "
echo "\033[1m Checking if IPX Pool exists  on BIG-IP for Tetration Collector ....\033[0m "
sleep 2

curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool  | python -m json.tool >> pool.txt
awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="name"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' pool.txt  >> allpool.txt # look for ipfix pools name in the only_name file
#clean up blank spaces for the pool file
sed 's/"//g' allpool.txt >> betterpool.txt
# Load file into array.
let i=0
# Read file betterpool.txt line by line and put the details in array 
while IFS=$'\n' read -r line_data; do
    poolarray[i]="${line_data}"
    ((++i))
done < betterpool.txt
    let i=0
    temp=${poolarray[i++]}

if [ "$temp" = "TetrationIPFIXPool" ]
      then
      echo " \033[0;32mIPFIX Pool exists on your BIGIP :---> $temp \033[0m"
      sleep 2
      # Add new Sensors or pool members for IPFIX
      curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members  | python -m json.tool >> members.txt
      awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="address"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' members.txt  >> allmembers.txt
      sed 's/"//g' allmembers.txt >> bettermembers.txt
      let i=0
      # Read file betterpool.txt line by line and put the details in array 
      while IFS=$'\n' read -r line_data; do
      membersarray[i]="${line_data}"
      ((++i))
      done < bettermembers.txt
                        let i=0
      					while (( ${#membersarray[@]} > i )); do
                        printf "\033[0;32m You have following IPFIX  Members :-->  ${membersarray[i++]}\033[0m \n"
                        done
      rm *.txt
      
      echo " \033[1m Do you want to Replace Sensor or Pool Member .. ? Say y or n \033[0m  \c "
      read  type_of_reply
      let i=0
       while [ "$type_of_reply" = "y" ]; do
       			echo " \033[1m Enter Pool Member or Sensor Address to Replace from above IPFIX Pool \033[0m \c"
       			read exist_address
       			echo " \033[1m Enter Destination Pool Member or Sensor Address to Replace With \033[0m \c"
                read dest_address
       					while (( ${#membersarray[@]} > i )); do
       					comp=${membersarray[i]}
       					if  [ "$comp" == "$exist_address" ]
       			 		then
       			 		curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X DELETE https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/TetrationIPFIXPool/members/${membersarray[i]}:4739  | python -m json.tool
                 		curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members -d '{"name":"'${dest_address}':4739", "address":"'$dest_address'"}' | python -m json.tool  
      			        fi
      			        let i++
      			        done
      			let i=0        
      			curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members  | python -m json.tool >> members.txt
      			awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="address"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' members.txt  >> allmembers.txt
      			sed 's/"//g' allmembers.txt >> bettermembers.txt
      			# Read file betterpool.txt line by line and put the details in array 
      			while IFS=$'\n' read -r line_data; do
      			membersarray[i]="${line_data}"
      			((++i))
      			done < bettermembers.txt
                        let i=0
      					while (( ${#membersarray[@]} > i )); do
                        printf "\033[0;32m You have following IPFIX  Members :-->  ${membersarray[i++]}\033[0m \n"
                        done
                rm *.txt
                 echo " \033[1m Do you want to Replace Sensor or Pool Member .. ? Say y or n \033[0, \c "
      			read  type_of_reply
                let i=0
        done        



  else
          echo "\033[1m IPFIX Pool is not configured on your BIG-IP \033[0m ..... "
  	      sleep 1
  	      echo "\033[1m Enter 1st F5 IPFIX Sensor Address \033[0m \c "
  	      read FirstAddress
  	      echo "\033[1m Enter 2nd F5 IPFIX Sensor Address \033[0m \c "
  	      read member_address1
  	      echo "\033[1m Enter 3rd F5 IPFIX Sensor Address \033[0m \c "
  	      read member_address2
          sleep 2
          ### Create IPXPool required for the tetration collector, this is dedicated Pool
          echo "\033[1m Creating IPXPool on BIG-IP required for Tetration Collector .......\033[0m \c"
          sleep 2  
          curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool -d '{"name": "TetrationIPFIXPool", "monitor": "gateway_icmp ", "members": [{"name":"'${FirstAddress}':4739", "address":"'$FirstAddress'"}]}' | python -m json.tool
          curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool  | python -m json.tool >> pool.txt
		  awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="name"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' pool.txt  >> allpool.txt # look for ipfix pools name in the only_name file
		  #clean up blank spaces for the pool file
		  sed 's/"//g' allpool.txt >> betterpool.txt
		  # Load file into array.
		  let i=0
		  # Read file betterpool.txt line by line and put the details in array 
		  while IFS=$'\n' read -r line_data; do
          if [ "${line_data}" = "TetrationIPFIXPool" ]
            then 
    	  poolarray[i]="${line_data}"
          ((++i))
        fi
          done < betterpool.txt
          let i=0
          temp=${poolarray[i]}
          curl -s -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members -d '{"name":"'${member_address1}':4739", "address":"'$member_address1'"}'  | python -m json.tool 
          curl -s -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members -d '{"name":"'${member_address2}':4739", "address":"'$member_address2'"}'  | python -m json.tool
          curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/~Common~$temp/members  | python -m json.tool >> members.txt
          awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="address"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' members.txt  >> allmembers.txt
          sed 's/"//g' allmembers.txt >> bettermembers.txt
          let i=0
          # Read file betterpool.txt line by line and put the details in array 
          while IFS=$'\n' read -r line_data; do
          membersarray[i]="${line_data}"
          ((++i))
          done < bettermembers.txt
          let i=0
          while (( ${#membersarray[@]} > i )); do
          printf "\033[0;32m You have following IPFIX  Members :-->  ${membersarray[i++]}\033[0m \n"
          done
          rm *.txt 
          sleep 0.5
          echo "curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool -d '{"name": "TetrationIPFIXPool", "monitor": "gateway_icmp ", "members": [{"name":"'${FirstAddress}':4739", "address":"'$FirstAddress'"}]}' | python -m json.tool"

          ### Creating ... publisher
          echo "Creating .... IPFIX Publisher ......"
          sleep 2  
          curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST  https://$BIGIP_MGMT_IP/mgmt/tm/sys/log-config/destination/ipfix -d '{"name":"TetrationIPFIXLog", "poolName":"TetrationIPFIXPool","protocolVersion": "ipfix"}' | python -m json.tool
          sleep 0.5
          curl -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X POST  https://$BIGIP_MGMT_IP/mgmt/tm/sys/log-config/publisher -d '{"name": "ipfix-pub-1", "destinations": [{"name": "TetrationIPFIXLog","partition": "Common"}]}' | python -m json.tool
          sleep 0.5

fi

#Go through all the virtual servers in BIG-IP

        curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual  | python -m json.tool   >> top.txt
        sleep 0.5

        #Extract and Print all the virtual servers
        awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="name"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' top.txt  >> good.txt # look for virtual server name in the only_name file
        awk -F'[, | ]' '{for(i=1;i<=NF;i++){gsub(/"|:/,"",$i);if($i=="ipProtocol"){gsub(/"|:/,"",$(i+1));print $(i+1)}}}' top.txt  >> goodp.txt # look for virtual server name in the only_name file

        sed 's/"//g' good.txt >> better.txt
        sed 's/"//g' goodp.txt >> betterp.txt
        # Load file into array.
        let i=0
        # Read file better.txt line by line and put the details in array 
        while IFS=$'\n' read -r line_data; do
          if [ "${line_data}" != "cookie" ]
            then 
          viparray[i]="${line_data}"
          ((++i))
        fi
        done < better.txt
        let j=0
        while IFS=$'\n' read -r line_data; do
            protoarray[j]="${line_data}"
            ((++j))
        done < betterp.txt


# Explicitly report array content ie the virtual server list
let i=0
### Select the Virtual Server to apply the iRule
while :
do
	printf "\033[0;32mYou have following Virtual Server  ${viparray[*]}\033[0m \n"
echo "Do you wish to apply ipfix irule to all  Virtual Server  say y or n...? "
read vs_input
if [ "$vs_input" = "y" ]
        then 
        echo " Attaching irule to all Virtual Servers ....."
        #Extract protocol for Virtual servers
   
         

        let j=0
        while (( ${#protoarray[@]} > j )); do
             if [ "${protoarray[j]}" == "tcp" ]
             then
             curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H " Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} | python -m json.tool 
             echo "Attaching tcp irule .................."
             sleep 1
             curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} -d '{"rules":["/Common/Tetration_TCP_L4_ipfix"]}'  | python -m json.tool
             fi   
            if [ "${protoarray[j]}" == "udp" ]
            then
            echo " Attaching udp irule to virtual servers ......."
            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H " Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} | python -m json.tool 
            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]}  -d '{"rules":["/Common/Tetration_UDP_L4_ipfix"]}'  | python -m json.tool
             fi  
        let "j++"
       done
       rm *.txt
       exit 
    
fi
 
let j=0
while (( ${#protoarray[@]} > j )); do
                                        
	                                                   printf "\033[0;32mDo you wish to attach iRule to the Virtual Server say y or n  ${viparray[j]}\033[0m ...? \n"
	                                                   read answer
                                                      if [ "$answer" = "y" ]
                                                      then 
                                                            if [ "${protoarray[j]}" == "tcp" ]
                                                            then
                                                            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H " Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} | python -m json.tool 
                                                            echo "Attaching tcp irule .................."
                                                            sleep 2
                                                            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} -d '{"rules":["/Common/Tetration_TCP_L4_ipfix"]}'  | python -m json.tool
                                                            fi
                                                            if [ "${protoarray[j]}" == "udp" ]
                                                            then
                                                            echo " Attaching udp irule to virtual servers ......."
                                                            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H " Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} | python -m json.tool 
                                                            curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]}  -d '{"rules":["/Common/Tetration_UDP_L4_ipfix"]}'  | python -m json.tool
                                                            fi
                                                 
                                                      fi
                                                      let j++

                                            done
                                            rm *.txt
                                            exit
                                          
rm *.txt

done 
exit                                                                                                             


done  # Done for the first While Loop 
