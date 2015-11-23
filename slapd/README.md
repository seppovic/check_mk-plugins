# slapd
Monitor openldap's slapd Operation and Network statistics and replication status via monitoring DB.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/slapd/slapd-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install slapd-1.0.mkp

# Requirements
* Openldap Server with accessible Monitoring DB.
* For replication status check, the provider has to be searchable.
* slapd.pl plugin for check_mk_agent installed on the target system.

# TODO
* specify ACL for service Accounts.
* extend agent for Multi-Master Replication check.
* implement Trends for statistic checks?!
* pnp templates

# Known issues

# History
* 1.0   first release
