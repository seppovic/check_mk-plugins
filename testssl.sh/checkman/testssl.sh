title: testssl.sh
agents: active
catalog: agentless
distribution: seppovic
license: GPL
description:
 This plugin utilzes **testssl.sh** to check ssl/tls configuration of a given service against a couple
 of predefined tests like:
 * Heartbleed vulnerability
 * Http Headers (HSTS, HPKP)
 * Compression (BEAST, CRIME) vulnerabilities
 * supported OpenSSL cipher suites (SSLv2, SSLv3, TLSv1, TLS1.1, TLSv1.2)
 * validity of the server(s) certificate(s) against various trust stores
 * support for the TLS_FALLBACK_SCSV cipher suite to prevent downgrade attacks
 It is usefull if you want to monitor internal services which are not accessable by other more comprehensive testtools like [qualys ssltest](https://www.ssllabs.com/ssltest/).

perfdata:
 none
