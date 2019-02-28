# F5 BIG-IP and Cisco Tetration Analytics
This repo provides information on how to configure BIG-IP devices in Cisco Tetration Solution. BIG-IP sends the flow information to the Tetration Sensors in IPFIX format this makes flows visible in Tetration Analytics software.

### Repo Details
Repo has two directories [irules](https://github.com/f5devcentral/f5-tetration/tree/master/irules/) and [scripts](https://github.com/f5devcentral/f5-tetration/tree/master/scripts). irules directory has  F5 BIG-IP irules for IPFIX. The irules facilitate sending the flow information to the Tetration Sensors. The scripts directory has the irule JSON payload and install and clean scripts. More information on IPFIX and F5 please refer to [IPFIX F5](https://support.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-12-0-0/13.html)

### Disclaimer : 
1. Integration is tested with v12.0 and above
2. Script removes existing irules on Virtual Server.
3. Script is tested with MAC OS terminal only. For ubuntu use ./install.sh after changing chmode 777


### How to use this Repo  

If you are using MAC OS just download the executable script https://github.com/f5devcentral/f5-tetration/raw/master/f5tetv1
and to run the script just issue ./f5tetv1  from MAC OS terminal

OR


1. Clone the repo to your local machine
` git clone https://github.com/f5devcentral/f5-tetration.git`
2. Change directory to scripts
`cd f5-tetration/scripts/`
3. Run install script
```
sh install.sh

Attention --->  Please Enter Contrl C to Quit this Program ....

This script will automatically deploy the iRules required for Tetration  

Please enter BIG-IP Management IP :  x.x.x.x
Please enter BIG-IP ADMIN USER :  admin
Please enter BIG-IP PASSWORD :  xxxx
Irule Exists locally on your machine  .. hit enter...to proceed
Checking if irule Exists on BIG-IP ......
Checking if IPX Pool exists  on BIG-IP for Tetration Collector ....
IPFIX Pool is not configured on your BIG-IP  .....
Enter Pool Member or Sensor Address 100.1.1.1
Enter Pool Member or Sensor Address  100.1.1.2
Enter Pool Member or Sensor Address  100.1.1.3
Creating IPXPool on BIG-IP required for Tetration Collector ....... {
    "allowNat": "yes",
```
4. Attach irule to All Virtual Servers
```
You have following Virtual Server  t1 t2 t3 t5_dup
Do you wish to apply ipfix irule to all  Virtual Server  say y or n...?
y
Attaching irule to all Virtual Servers .....
```
5. IF you want to Select only specific Virtual Server then say 'n' on 4th step & proceed as follows
```You have following Virtual Server  t1 t2 t3 t5_dup
Do you wish to apply ipfix irule to all  Virtual Server  say y or n...?
n
Do you wish to attach iRule to the Virtual Server say y or n  t1 ...?
n
Do you wish to attach iRule to the Virtual Server say y or n  t2 ...?
y
```
6. If you like to change the IPFIX Pool Member or Sensor address
```
sh install.sh

Attention --->  Please Enter Contrl C to Quit this Program ....

This script will automatically deploy the iRules required for Tetration  

Please enter BIG-IP Management IP :  10.192.74.68
Please enter BIG-IP ADMIN USER :  admin
Please enter BIG-IP PASSWORD :  admin
Irule Exists locally on your machine  .. hit enter...to proceed
Checking if irule Exists on BIG-IP ......
Checking if IPX Pool exists  on BIG-IP for Tetration Collector ....
IPFIX Pool exists on your BIGIP :---> IPFIXPool
You have following IPFIX  Members :-->  100.1.1.1
You have following IPFIX  Members :-->  100.1.1.2
You have following IPFIX  Members :-->  100.1.1.3
Do you want to Replace Sensor or Pool Member .. ? Say y or n   
Enter Pool Member or Sensor Address to Replace from above IPFIX Pool  100.1.1.1
Enter Destination Pool Member or Sensor Address to Replace With  200.1.1.1
No JSON object could be decoded
You have following IPFIX  Members :-->  100.1.1.2
You have following IPFIX  Members :-->  100.1.1.3
You have following IPFIX  Members :-->  200.1.1.1
```
7. To Remove the configuration and clean everything
```
sh clean.sh
Please Enter contrl C to Quit

This script will automatically delete and clean up iRule & IPFIX configuration

This Script is Used to  *** Remove  configuration from BIG-IP  ***  

Please enter BIG-IP Management IP to Clean IPFIX configuration :  10.192.74.68
Please enter BIG-IP ADMIN USER :  admin
Please enter BIG-IP PASSWORD :  xxxx
Remove irules from the BIG-IP
This Script is Used to  *** Remove  configuration from BIG-IP  ***  

Please enter BIG-IP Management IP to Clean IPFIX configuration :  

```
