# F5 BIG-IP and Cisco Tetration Analytics
This repo provides information on how to configure BIG-IP devices in Cisco Tetration Solution. BIG-IP sends the flow information to the Tetration Sensors in IPFIX format this makes flows visible in Tetration Analytics software.

### Repo Details
Repo has two directories [irules](https://github.com/f5devcentral/f5-tetration/tree/master/irules/) and [scripts](https://github.com/f5devcentral/f5-tetration/tree/master/scripts). irules directory has  F5 BIG-IP irules for IPFIX. The irules facilitate sending the flow information to the Tetration Sensors. The scripts directory has the irule JSON payload and install and clean scripts.

### How to use this Repo
1. Clone the repo to your local machine
` git clone https://github.com/f5devcentral/f5-tetration.git`
2. Change directory to scripts
`cd f5-tetration/scripts/`
3. Run install script
` sh install.sh
 Attention --->  Please Enter Contrl C to Quit this Program ....

 This script will automatically deploy the iRules required for Tetration  

Please enter BIG-IP Management IP :  
`
