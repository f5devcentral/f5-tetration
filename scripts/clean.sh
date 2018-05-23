#!/bin/sh

echo " Please Enter contrl C to Quit \n"
echo " This script will automatically delete and clean up iRule & IPFIX configuration \n"
while :
do
  echo " \033[0;31mThis Script is Used to  *** Remove  configuration from BIG-IP  *** \033[0m \n"
  echo " \033[1mPlease enter BIG-IP Management IP to Clean IPFIX configuration : \033[0m \c "
  read BIGIP_MGMT_IP
  echo "\033[1mPlease enter BIG-IP ADMIN USER : \033[0m \c"
read BIGIP_ADMIN
echo "\033[1mPlease enter BIG-IP PASSWORD : \033[0m \c"
read BIGIP_PASS

curl -s -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X DELETE https://$BIGIP_MGMT_IP/mgmt/tm/sys/log-config/publisher/ipfix-pub-1  > /dev/null
echo " Removed ipfix-pub-1 log-config"
curl -s -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X DELETE https://$BIGIP_MGMT_IP/mgmt/tm/sys/log-config/destination/ipfix/TetrationIPFIXLog > /dev/null
echo " Removing TetrationIPFIXLog  "
curl -s -sku $BIGIP_ADMIN:$BIGIP_PASS -H "Content-Type: application/json" -X DELETE  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/pool/TetrationIPFIXPool > /dev/null
echo " Removing TetrationIPFIXPool "

 


#Dettach irule from Virtual Servers
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
          viparray[i]="${line_data}"
          ((++i))
        done < better.txt
      let j=0
      while IFS=$'\n' read -r line_data; do
            protoarray[j]="${line_data}"
            ((++j))
      done < betterp.txt
      
                    j=0
                 while (( ${#viparray[@]} > j )); do

                 	rm file.txt
					curl -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X GET  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} | python -m json.tool >> file.txt
					value=$( grep -ic "Tetration" file.txt )
					if [ $value -eq 2 ]
					then
 
					echo " Removing irule from Virtual Server "
					curl -s -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X PATCH  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/virtual/${viparray[j]} -d '{"rules":[""]}' > /dev/null
					fi
                    let j++
                done
rm *.txt > /dev/null
#Remove irules from the BIG-IP
echo "Remove irules from the BIG-IP"
curl -s -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X DELETE  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_TCP_L4_ipfix > /dev/null
curl -s -k --user $BIGIP_ADMIN:$BIGIP_PASS -H "Accept: application/json" -H "Content-Type:application/json" -X DELETE  https://$BIGIP_MGMT_IP/mgmt/tm/ltm/rule/Tetration_UDP_L4_ipfix > /dev/null


done 

 
