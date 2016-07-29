# netapp_cpoints
This plugin is a rewrite of my plain nagios check script. It queries 
a NetApp via snmp to get the Consistency Points statistics. All thresholds are
fully configurable in WATO. See checkman for further explanation of each 
Consistency Point type.

![sample pnp-Graph](https://github.com/seppovic/check_mk-plugins/blob/master/netapp_cpoints/pnp-templates/sample.png)

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/netapp_cpoints/netapp_cpoints-1.2.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install netapp_cpoints-1.2.0.mkp

# Requirements
* A NetApp.

# Known issues
* None so far.

# History
* 1.2.0 Added Metrics Graph.
* 1.1.2 Fixed Bug in WATO, not using named Parameters anymore, makes this plugin usable with check_mk pre 1.2.7
* 1.1.1 Fixed Bug in WATO configuration and default levels form None to -1 as default.
* 1.1 Use check_mk's new get_rate function.
* 1.0 First release.
