# dell_idrac_powersupplies
This check monitors the state of power supply units via idarc mib (IDRAC-MIB-SMIv2.mib) of Dell PowerEdge Servers.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/dell_idrac_powersupplies/dell_idrac_powersupplies-1.1.3.mkp'
* OMD[SITENAME]:~$ check_mk -P install dell_idrac_powersupplies-1.1.3.mkp

# Requirements
* Dell Server with snmp access to idrac enabled.

# Known issues
* None so far.

# History
* 1.1.3 fixed Watt computation a few times for weird idrac behaviours.
* 1.1.0 Added collection of Watt perfdata.
* 1.0   First release.
