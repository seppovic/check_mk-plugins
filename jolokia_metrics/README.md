# jolokia_metrics
This plugin extends the original jolokia_metrics check distributed with check_mk.
It adds the functionality to include userdefined MBeans/Attributes to the 
monitoring. The MBeans are specified in the jolokia.cfg on the client. See 
jolokia.cfg in agents/cfg_examples/ folder for an example.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/jolokia_metrics/jolokia_metrics-2.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install jolokia_metrics-2.0.mkp

# Requirements
* Application server with [jolokia](http://jolokia.org/) deployed.
* mk_jolokia plugin for check_mk_agent installed on the target system.

# TODO

# Known issues

# History
* 2.0   Added funktionality for string checking; Converted to Dictionary based parameters
* 1.2.1 Fixed minor Bug in rate mode with 1 value
* 1.2   Added WATO plugin and checkman
* 1.1   Added pnp-template
* 1.0.1 Bugfix in inventory definition
* 1.0   first release
