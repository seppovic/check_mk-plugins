# cisco_ras_sessions 
This check returns the number of active sessions defined in Cisco Remote Access Monitoring MIB, these are currently the following: On layer 2 (PPTP, L2TP, L2F), layer 3 (IPsec) and layer 4 (SSL) virtual private networks. A service is only created if the "PeakConcurrentSessions" Counter of the desired protocol is greater then zero.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/cisco_ras_sessions/cisco_ras_sessions-1.0.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install cisco_ras_sessions-1.0.1.mkp

# Requirements
* A Cisco ASA or similar device.

# Known issues
* None so far.

# History
* 1.0.1 Fixed Bug in WATO configuration and renamed it's parameters file.
* 1.0   first release.
