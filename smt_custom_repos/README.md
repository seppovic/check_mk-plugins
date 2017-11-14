# smt_custom_repos
You can define assignments between products and repository/catalog in SUSE SMT which this check monitors for its presence.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/smt_custom_repos/smt_custom_repos-1.1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install smt_custom_repos-1.1.0.mkp

# Requirements
* SUSE SMT and custom repositories/catalogs defined

# TODO
* Agent bakery skript.

# Known issues
* None so far.

# History
* 1.1.0 Added ids to output and saving previous working ids.
* 1.0.0 First release.
