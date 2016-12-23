# sslyze
This active check utilzes **sslyze** to check ssl/tls configuration of a given service against a couple
of predefined tests like:
* Heartbleed vulnerability
* Http Headers (HSTS, HPKP)
* Compression (BEAST, CRIME) vulnerabilities
* supported OpenSSL cipher suites (SSLv2, SSLv3, TLSv1, TLS1.1, TLSv1.2)
* validity of the server(s) certificate(s) against various trust stores
* support for the TLS_FALLBACK_SCSV cipher suite to prevent downgrade attacks
It is usefull if you want to monitor internal services which are not accessable by other more comprehensive testtools like [qualys ssltest](https://www.ssllabs.com/ssltest/). **sslyze** is expected to be in the search path.

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/sslyze/sslyze-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install sslyze-1.0.mkp

# Requirements
* [sslyze](https://github.com/nabla-c0d3/sslyze) installed, preferable via your distros Packagemanagement System

# TODO

# Known issues

# History
* 1.0     First release
