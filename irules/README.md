# irules
These are two irules [Tetration_TCP_L4_ipfix.tcl](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_TCP_L4_ipfix.tcl) and [Tetration_UDP_L4Tetration_UDP_L4_ipfix](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_UDP_L4_ipfix.tcl). TCP irule is always attached to TCP Virtual Servers and UDP irule is always attached to UDP Virtual Servers. These irules when attached to the virtual servers will look at the TCP and UDP traffic flows in the Data plane will send the flows to tetration sensors in IPFIX format.

### ** Steps to use the iRules **
1. First import both irules in BIG-IP
   i.  Click on LTM
   ii. Click iRules - > Create - > Give Name - > Cut and paste the irule from [Tetration_TCP_L4_ipfix.tcl](https://github.com/f5devcentral/f5-tetration/blob/master/irules/Tetration_TCP_L4_ipfix.tcl)
   iii. Repeat the same for the UDP iRule as well.

2. Attach iRule to Virtual Server
   i.  Click on LTM
   ii. Click on Virtual Servers
   iii.Click on the Virtual Server to which iRule needs to be attached
   iv. Click on Resources under iRules click on Manage
   v.  Select iRule from Available to Enabled in Resource Management
   vi. Click finished.
