# jolokia_metrics
This plugin extends the original jolokia_metrics check distributed with check_mk.
It adds the functionality to include userdefined MBeans/Attributes to the 
monitoring. The MBeans are specified in the jolokia.cfg on the client. See 
jolokia.cfg for examples.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/blob/master/jolokia_metrics/jolokia_metrics-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install jolokia_metrics-1.0.mkp

# Requirements
* Application server with [jolokia](http://jolokia.org/) deployed.

# TODO
* include pnp-template
* make thresholds configurable via WATO
* testing special cases (division by zero?)

# Known issues
* None so far.

# History
* 1.0 first release
