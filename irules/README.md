# irules
These are three irules [Tetration_TCP_L4_ipfix.tcl](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_TCP_L4_ipfix.tcl),  [Tetration_UDP_L4_ipfix](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_UDP_L4_ipfix.tcl) and [Tetration_HTTP_L7_ipfix.tcl](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_HTTP_L7_ipfix.tcl) TCP irule is always attached to TCP Virtual Servers and UDP irule is always attached to UDP Virtual Servers. HTTP irules is also attached to the TCP Virtual Servers and it looks for the HTTP Event like HTTP_REQUEST and will look at ```user name``` in the HTTP header, will extract ```user name``` for that flow and send as a IPFIX template to Tetration Sensor. These irules when attached to the virtual servers will look at the TCP and UDP traffic flows in the Data plane will send the flows to tetration sensors in IPFIX format.

### ** Steps to use the iRules **
#### First import irules in BIG-IP
- Click on LTM
- Click iRules - > Create - > Give Name - > Cut and paste the irule from [Tetration_TCP_L4_ipfix.tcl](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_TCP_L4_ipfix.tcl)
- Repeat the same for the UDP & HTTP iRule as well if required.

#### Attach iRule to Virtual Server
- Click on LTM
- Click on Virtual Servers
- Click on the Virtual Server to which iRule needs to be attached
- Click on Resources under iRules click on Manage
- Select iRule from Available to Enabled in Resource Management
- Click finished.
