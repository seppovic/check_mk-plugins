# oracle_buffer_cache
This check monitors the buffer cache hit ratio in an ORACLE database instance.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/oracle_buffer_cache/oracle_buffer_cache-1.0.2.mkp'
* OMD[SITENAME]:~$ check_mk -P install oracle_buffer_cache-1.0.2.mkp

# Requirements
* mk_oracle plugin installed, configured and patched with this patch:
 https://github.com/seppovic/check_mk-plugins/raw/master/oracle_buffer_cache/agents/plugins/mk_oracle.patch
* An Oracle Database

# TODO

# Known issues

# History
* 1.0.2 Fixed Bug in WATO, not using named Parameters anymore, makes this plugin usable with check_mk pre 1.2.7
* 1.0.1 Fixed WATO file.
* 1.0   First release.

