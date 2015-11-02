# zypper
This plugin extends the zypper check shipped with check_mk. It lets you configure thresholds for
updates (recommended and security), the maximum duration security updates can be available until a warning or
critical state is raised and the status a packagelock should raise.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/zypper/zypper-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install zypper-1.0.mkp

# Requirements
* mk_zypper plugin for check_mk_agent installed on the target system.

# TODO

# Known issues

# History
* 1.0   first release
