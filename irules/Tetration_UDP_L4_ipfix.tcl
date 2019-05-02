when RULE_INIT {
  set static::http_rule1_dest ""
  set static::http_rule1_tmplt ""
}

# CLIENT_ACCEPTED event to initiate IPFIX destination and template
when CLIENT_ACCEPTED {
  set start [clock clicks -milliseconds]
  if { $static::http_rule1_dest == ""} {
    # open the logging destination if it has not been opened yet
    set static::http_rule1_dest [IPFIX::destination open -publisher /Common/tetrationpub]
  }
  if { $static::http_rule1_tmplt == ""} {
    # if the template has not been created yet, create the template
    set static::http_rule1_tmplt [IPFIX::template create "flowStartMilliseconds \
                                                          sourceIPv4Address \
                                                          sourceIPv6Address  \
                                                          destinationIPv4Address \
                                                          destinationIPv6Address  \
                                                          sourceTransportPort \
                                                          destinationTransportPort \
                                                          protocolIdentifier \
                                                          octetTotalCount \
                                                          packetTotalCount \
                                                          octetDeltaCount \
                                                          packetDeltaCount \
                                                          postNATSourceIPv4Address \
                                                          postNATSourceIPv6Address  \
                                                          postNATDestinationIPv4Address \
                                                          postNATDestinationIPv6Address  \
                                                          postNAPTSourceTransportPort \
                                                          postNAPTDestinationTransportPort \
                                                          postOctetTotalCount \
                                                          postPacketTotalCount \
                                                          postOctetDeltaCount \
                                                          postPacketDeltaCount \
                                                          flowEndMilliseconds"]
  }
}

# SERVER_CONNECTED event to initiate flow data to Tetration and populate 5 tuples
when SERVER_CONNECTED {
  set rule1_msg1 [IPFIX::msg create $static::http_rule1_tmplt]
  set client_closed_flag 0
  set server_closed_flag 0
  IPFIX::msg set $rule1_msg1 flowStartMilliseconds $start
  IPFIX::msg set $rule1_msg1 protocolIdentifier [IP::protocol]
  
  # Clientside
  if { [clientside {IP::version}] equals "4" } {
    # Client IPv4 address
    IPFIX::msg set $rule1_msg1 sourceIPv4Address [IP::client_addr]
    # BIG-IP IPv4 VIP address
    IPFIX::msg set $rule1_msg1 destinationIPv4Address [clientside {IP::local_addr}]
  } else {
    # Client IPv6 address
    IPFIX::msg set $rule1_msg1 sourceIPv6Address [IP::client_addr]
    # BIG-IP IPv6 VIP address
    IPFIX::msg set $rule1_msg1 destinationIPv6Address [clientside {IP::local_addr}]
  }
  # Client port
  IPFIX::msg set $rule1_msg1 sourceTransportPort [UDP::client_port]
  # BIG-IP VIP port
  IPFIX::msg set $rule1_msg1 destinationTransportPort [clientside {UDP::local_port}]

  # Serverside
  if { [serverside {IP::version}] equals "4" } {
    # BIG-IP IPv4 self IP address
    IPFIX::msg set $rule1_msg1 postNATSourceIPv4Address [IP::local_addr]
    # Server IPv4 IP address
    IPFIX::msg set $rule1_msg1 postNATDestinationIPv4Address [IP::server_addr]
  } else {
    # BIG-IP IPv6 self IP address
    IPFIX::msg set $rule1_msg1 postNATSourceIPv6Address [IP::local_addr]
    # Server IPv6 IP address
    IPFIX::msg set $rule1_msg1 postNATDestinationIPv6Address [IP::server_addr]
  }
  # BIG-IP self IP port
  IPFIX::msg set $rule1_msg1 postNAPTSourceTransportPort [UDP::local_port]
  # Server port
  IPFIX::msg set $rule1_msg1 postNAPTDestinationTransportPort [UDP::server_port]
}
 
# SERVER_CLOSED event to collect IP pkts and bytes count on serverside
when SERVER_CLOSED {
  set server_closed_flag 1
  # when flow is completed, BIG-IP to server REQUEST pkts and bytes count
  IPFIX::msg set $rule1_msg1 octetTotalCount [IP::stats bytes out]
  IPFIX::msg set $rule1_msg1 packetTotalCount [IP::stats pkts out]
  # when flow is completed, server to BIG-IP RESPONSE pkts and bytes count 
  IPFIX::msg set $rule1_msg1 octetDeltaCount [IP::stats bytes in]
  IPFIX::msg set $rule1_msg1 packetDeltaCount [IP::stats pkts in]
  if { $client_closed_flag == 1} {
    # send the IPFIX log
    IPFIX::destination send $static::http_rule1_dest $rule1_msg1
  }
}

# CLIENT_CLOSED event to collect IP pkts and bytes count on clientside
when CLIENT_CLOSED {
  set client_closed_flag 1
  # when flow is completed, client to BIG-IP REQUEST pkts and bytes count
  IPFIX::msg set $rule1_msg1 postOctetTotalCount [IP::stats bytes in]
  IPFIX::msg set $rule1_msg1 postPacketTotalCount [IP::stats pkts in]
  # when flow is completed, BIG-IP to client RESPONSE pkts and bytes count
  IPFIX::msg set $rule1_msg1 postOctetDeltaCount [IP::stats bytes out]
  IPFIX::msg set $rule1_msg1 postPacketDeltaCount [IP::stats pkts out]
  # record the client closed time in ms
  IPFIX::msg set $rule1_msg1 flowEndMilliseconds [clock click -milliseconds]
  if { $server_closed_flag == 1} {
    # send the IPFIX log
    IPFIX::destination send $static::http_rule1_dest $rule1_msg1
  }
}
