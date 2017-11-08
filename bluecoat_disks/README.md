# bluecoat_disks
This check uses SNMP to monitor the status of each Disk on an Bluecoat Device which provides access to the deviceDiskMIB (.1.3.6.1.4.1.3417.2.2.1.1.1.1)

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/bluecoat_disks/bluecoat_disks-1.1.2.mkp'
* OMD[SITENAME]:~$ check_mk -P install bluecoat_disks-1.1.2.mkp

# Requirements
* A BlueCoat SG Proxy Appliance.

# Known issues
* None so far.

# History
* 1.1.2 Fixed a few Bugs and changed the status text.
* 1.1.0 Added WATO configuration.
* 1.0.0 First release.
