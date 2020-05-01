# F5 BIG-IP and Cisco Tetration Analytics
This repo provides information on how to configure BIG-IP devices in Cisco Tetration Solution. BIG-IP sends the flow information to the Tetration Sensors in IPFIX format this makes flows visible in Tetration Analytics software.

### Repo Details
Repo has two directories [irules](https://github.com/f5devcentral/f5-tetration/tree/master/irules/) and [scripts](https://github.com/f5devcentral/f5-tetration/tree/master/scripts). irules directory has  F5 BIG-IP irules for IPFIX. The irules facilitate sending the flow information to the Tetration Sensors. The scripts directory has the irule JSON payload and install and clean scripts. More information on IPFIX and F5 please refer to [IPFIX F5](https://support.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-12-0-0/13.html)

### Disclaimer : 
1. Integration is tested with v12.0 and above
2. Script is tested with MAC OS terminal only. To run use ./f5tetv1 from MAc OS terminal
3. Added Script which runs on linux (Ubuntu 18.04.4 LTS) file name is f5tetlx


### How to use this Repo  

- If you are using MAC OS just download the executable script https://github.com/f5devcentral/f5-tetration/raw/master/f5tetv1
and to run the script just issue ./f5tetv1  from MAC OS terminal
- If you are using Linux (Ubuntu 18.04.4 LTS) just download executable script https://github.com/f5devcentral/f5-tetration/raw/master/f5tetlx
and to run do chmod 777 f5tetlx and issue ./f5tetlx from linux terminal
- If you are using Windows (Windows server 2019) just download executable script https://github.com/scshitole/ipfixGo/raw/master/f5tet.exe
and to run f5tet from command prompt





```
Enter your BIG-IP Management IP: x.x.x.x
Enter your Username: admin
Enter your Password: xxxx
Attempting to Connect...

Please make your selection 1: IPFIX Configuration
                           2: Remove IPFIX Configuration
                           3: Remove IPFIX iRules from Virtual Server
                           4: Remove iRules from BIG-IP
                           5: Exit

Enter Your Choice : 1
Checking TCP iRules  exists on your local machine

TCP iRules  exists on your local machine

Checking UDP iRules exists on your local machine

UDP iRules exists on your local machine

Checking TCP iRules exists on BIG-IP ......

Uploading TCP iRules to BIG-IP .........

Checking UDP iRules exists on BIG-IP ......

Uploading UDP iRules to BIG-IP .........

Checking IPFIX Pool exists on BIG-IP ......

IPFIX Pool Does not Exists on BIG-IP Creating .....

Enter first IPFIX Sensor : 1.1.1.1
Enter Second IPFIX Sensor : 1.1.1.2
Enter Third IPFIX Sensor : 1.1.1.3
Created .... IPFIX Pool and Members added 


Creating IPFIX Log Destination ......
Creating Log Publisher  ......
Name: TetrationIPFIXPool
Sensors list : 1.1.1.1:4739 
Sensors list : 1.1.1.2:4739 
Sensors list : 1.1.1.3:4739 
Above Showing you IPFIX Pool on BIG-IP 

Do you want to use the above shown IPFIX Pool say Y/N? y
Appy iRules on all Virtual Server Y/N ? : n
Please select which Virtual Server need iRules 



Displaying all the Virtual Servers and iRules  ......
 
 
Please make your selection 1: IPFIX Configuration
                           2: Remove IPFIX Configuration
                           3: Remove IPFIX iRules from Virtual Server
                           4: Remove iRules from BIG-IP
                           5: Exit

Enter Your Choice : 2
Removing Publisher Configuration ........
Removing IPFIX log Configuration ........
Removing IPFIX Pool Configuration ........
Please make your selection 1: IPFIX Configuration
                           2: Remove IPFIX Configuration
                           3: Remove IPFIX iRules from Virtual Server
                           4: Remove iRules from BIG-IP
                           5: Exit

Enter Your Choice : 4
Removing iRules /Common/Tetration_TCP_L4_ipfix from BIG-IP ......

Removing iRules /Common/Tetration_UDP_L4_ipfix from BIG-IP ......

Please make your selection 1: IPFIX Configuration
                           2: Remove IPFIX Configuration
                           3: Remove IPFIX iRules from Virtual Server
                           4: Remove iRules from BIG-IP
                           5: Exit

Enter Your Choice : 5


```


