# Obsolete!
You might want to use the [mk_jolokia.py](https://github.com/tribe29/checkmk/blob/master/agents/plugins/mk_jolokia.py) plugin shipped with check_mk since at least 1.6.0 as it is actively maintained.

# jolokia_generic
This plugin extends the original jolokia_metrics distributed with check_mk.
It adds the functionality to include userdefined MBeans/Attributes to the 
monitoring. The MBeans are specified in jolokia.cfg on the client. See 
jolokia.cfg in agents/cfg_examples/ folder for an example.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/jolokia_generic/jolokia_generic-2.2.5.mkp'
* OMD[SITENAME]:~$ check_mk -P install jolokia_generic-2.2.5.mkp

# Requirements
* Application server with [jolokia](http://jolokia.org/) deployed.
* mk_jolokia plugin for check_mk_agent installed on the target system.

# TODO

# Known issues

# History
* 2.2.6 Fixed whitespace handling in string mode. Thx to @M-a-x-G.
* 2.2.5 Fixed Bug which makes the check crash if gauge value is no number and merged commit to use Counterwrapps as intended. Thx to @redflo.
* 2.2.4 Fixed Bug in check plugin, using MKCounterwrapped correctly now.
* 2.2.3 Fixed Bug in WATO, not using named Parameters anymore, makes this plugin usable with check_mk pre 1.2.7
* 2.2.2 Fixed Bug in WATO configuration and brought agent in sync with git.mathias-kettner.de
* 2.2.1 Fixed Display of pnp-graph, sort Attributes by value to keep the highest in the background
* 2.2   Added functionality to specify thresholds for each value of a service
* 2.1.1 Fixed Case where we don't get an application field back from the agent (e.g. Some Applications start their own MBean Server)
* 2.1   Added funktionality for string checking; Converted to Dictionary based parameters
* 2.0   Plugin Renamed from jolokia_metrics to jolokia_generic and use original jolokia_metrics as includefile
* 1.2.1 Fixed minor Bug in rate mode with 1 value
* 1.2   Added WATO plugin and checkman
* 1.1   Added pnp-template
* 1.0.1 Fixed Bug in inventory definition
* 1.0   First release
