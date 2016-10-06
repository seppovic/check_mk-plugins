# zypper
This plugin extends the zypper check shipped with check_mk. It lets you configure thresholds for
updates (<=SLES11.4 recommended and security; >=SLES12.1 important and critical), the maximum
duration security updates can be available until a warning or critical state is raised and the
status a packagelock should raise.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/zypper/zypper-1.2.mkp'
* OMD[SITENAME]:~$ check_mk -P install zypper-1.2.mkp

# Requirements
* mk_zypper plugin for check_mk_agent installed on the target system.

# TODO

# Known issues

# History
* 1.2   Use new Severity over Category if present. Thanks to Sven Knauer.
* 1.1.1 Fixed Bug in WATO, not using named Parameters anymore, makes this plugin usable with check_mk pre 1.2.7
* 1.1   Updated to 1.2.7i3 api (Note: incompatible with prior check_mk Versions)
* 1.0   First release (use with check_mk 1.2.7i2 and earlier)
