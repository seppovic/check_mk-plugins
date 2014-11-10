# jolokia_generic
This plugin extends the original jolokia_metrics check distributed with check_mk.
It adds the functionality to include userdefined MBeans/Attributes to the 
monitoring. The MBeans are specified in the jolokia.cfg on the client. See 
jolokia.cfg in agents/cfg_examples/ folder for an example.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/jolokia_generic/jolokia_generic-2.1.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install jolokia_generic-2.1.1.mkp

# Requirements
* Application server with [jolokia](http://jolokia.org/) deployed.
* mk_jolokia plugin for check_mk_agent installed on the target system.

# TODO
* update pnp-template to keep highest values in the background.
# Known issues

# History
* 2.1.1 Fixed Case where we don't get an application field back from the agent (e.g. Alfresco starts its own MBean Server)
* 2.1   Added funktionality for string checking; Converted to Dictionary based parameters
* 2.0   Plugin Renamed from jolokia_metrics to jolokia_generic and use original jolokia_metrics as includefile
* 1.2.1 Fixed minor Bug in rate mode with 1 value
* 1.2   Added WATO plugin and checkman
* 1.1   Added pnp-template
* 1.0.1 Fixed Bug in inventory definition
* 1.0   first release
