# slapd
Monitor openldap's slapd Operation and Network statistics via monitoring DB and replication status.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/slapd/slapd-1.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install slapd-1.1.mkp

# Requirements
* Openldap Server with accessible Monitoring DB.
* For replication status check, the provider has to be searchable.
* slapd.pl plugin for check_mk_agent installed on the target system.

# TODO
* specify ACL for service Accounts.
* implement Trends for statistic checks?!
* pnp templates

# Known issues

# History
* 1.1   Added functionality to monitor syncrepl status in a Multi-Master environment.
* 1.0.2 Fixed Bug in WATO, not using named Parameters anymore, makes this plugin usable with check_mk pre 1.2.7
* 1.0.1 Fixed mkp file, exchange complained about the apostrophe.
* 1.0   First release
