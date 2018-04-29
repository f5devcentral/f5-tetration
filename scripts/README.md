# scripts
This directory has two scripts install and clean. install.sh you can use to configure the BIG-IP for IPFIX configuration and attaching IPFIX irule to the virtual servers. You can attach IPFIX irule to all the Virtual serverat once or you can also attach irule selectively to virtual servers.

clean.sh script does the following
1. Once BIG-IP management IP, user name and password is provided
2. It removes the IPFIX publisher configuration
3. It dettaches irule from all the Virtual servers
4. It deletes all the irule from BIG-IP
