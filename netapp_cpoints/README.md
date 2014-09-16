# netapp_cpoints
This plugin is a rewrite of my plain nagios check script. It queries 
a NetApp via snmp to get the Consistency Points statistics. All thresholds are
fully configurable in WATO. See checkman for further explanation of each 
Consistency Point type.

![sample pnp-Graph](https://github.com/seppovic/check_mk-plugins/blob/master/netapp_cpoints/pnp-templates/sample.png)

# Installation
* $ su - SITENAME
* $ wget 'https://github.com/seppovic/check_mk-plugins/blob/master/netapp_cpoints/netapp_cpoints-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install netapp_cpoints-1.0.mkp

# Requirements
* A NetApp.

# Known issues
* None so far.

# History
* 1.0 first release.
