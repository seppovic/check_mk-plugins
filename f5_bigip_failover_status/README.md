# f5_bigip_failover

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/f5_bigip_failover/f5_bigip_failover_status-1.0.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install f5_bigip_failover_status-1.0.1.mkp

# Requirements
* f5 BigIP Loadbalancer configured for snmp access.

# TODO

# Known issues

# History
* 1.0.1   Formated the status output and changed default Severity of Failoverstate.
* 1.0     First release
