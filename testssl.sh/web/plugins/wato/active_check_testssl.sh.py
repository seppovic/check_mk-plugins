#!/usr/bin/python
# -*- encoding: utf-8; py-indent-offset: 4 -*-


register_rulegroup("activechecks",
    _("Active checks (HTTP, TCP, etc.)"),
    _("Configure active networking checks like HTTP and TCP"))
group = "activechecks"

def sslyze_option_to_state():
    return CascadingDropdown(
        orientation = "horizontal",
        choices = [
            ("set", _("if set"), MonitoringState( default_value = 2 ) ),
            ("unset", _("if not set"), MonitoringState( default_value = 2 ) ),
        ]
    )

def transform_cert_days(cert_days):
    if type(cert_days) != tuple:
        return (cert_days, 0)
    else:
        return cert_days

register_rule(group,
  "active_checks:testssl",
  Tuple(
    title = _("check ssl Configuration using testssl.sh"),
    help = _("This active check utilzes **testssl.sh** to check ssl/tls configuration of a given service against a couple "
             "of predefined tests. It is usefull if you want to monitor internal services which are not accessable "
             "by other more comprehensive testtools like [qualys ssltest](https://www.ssllabs.com/ssltest/). "),
    elements = [
      ( TextUnicode(title = _("Service Description"),
              help = _("The name of this active service to be displayed."),
              default_value = "Port443_ssl_analysis" ,
              allow_empty = False,
      )),
      ( Integer(title = _("Port"),
              help = _('TCP Port you want to test'),
              default_value = 443,
              allow_empty = False,
      )),
      Dictionary(
        title = _("Optional parameters"),
        optional_keys = [ "testssl_path", "timeout", "plugins", "sniName", "starttls" ],
        elements = [
          ( "testssl_path",
            TextUnicode(title = _("alternative Path to testssl.sh"),
          )),
          ( "sniName",
            TextUnicode(title = _("SNI Hostname"),
            help = _("Use Server Name Indication to specify the hostname to connect to."
            "You might want to specify the Hostname to verify the certificate. default is to only query the $HOSTIP$"),
          )),
          ( "plugins",
            ListChoice(
              title = _("Which SSL Tests to perform:"),
              toggle_all = True,
              default_value = [ "each-cipher", "ciphers", "protocols", "server-defaults", "server-preference", "headers", "heartbleed", "ccs", "renegotiation", "crime", "breach", "poodle", "tls-fallback", "freak", "beast", "logjam", "drown", "pfs", "rc4", ],
              choices = [
                     ( "protocols", _("checks TLS/SSL protocols") ),
                     ( "ciphers", _("checks common cipher suites") ),
                     ( "server-defaults", _("displays the server's default picks and certificate info") ),
                     ( "headers", _("tests HSTS, HPKP, server/app banner, security headers, cookie, reverse proxy, IPv4 address") ),
                     ( "heartbleed", _("tests for heartbleed vulnerability") ),
                     ( "ccs", _("tests for Openssl CCS injection vulnerability") ),
                     ( "renegotiation", _("tests for renegotiation vulnerabilities") ),
                     ( "crime", _("tests for CRIME vulnerability") ),
                     ( "breach", _("tests for BREACH vulnerability") ),
                     ( "poodle", _("tests for POODLE (SSL) vulnerability") ),
                     ( "tls-fallback", _("checks TLS_FALLBACK_SCSV mitigation") ),
                     ( "freak", _("tests for FREAK vulnerability") ),
                     ( "drown", _("tests for DROWN vulnerability") ),
                     ( "logjam", _("tests for LOGJAM vulnerability") ),
                     ( "beast", _("tests for BEAST vulnerability") ),
                     ( "pfs", _("checks (perfect) forward secrecy settings") ),
                     ( "rc4", _("which RC4 ciphers are being offered?") ),
               ]
            ),
          ),
          ( "starttls",
            DropdownChoice(
              title = _("Protocoll (which startTLS method to use)"),
              help = _("Type is automatically chosen from port if nothing or auto is selected"),
              default_value = "auto",
              choices = [
                ("auto",      _("auto")),
                ("xmpp",      _("XMPP")),
                ("ldap",    _("LDAP")),
                ("smtp",    _("SMTP")),
                ("imap",    _("IMAP")),
                ("pop3",   _("POP3")),
                ("ftp",      _("FTP")),
              ],
            ),
          ),
        ]
      ),
      Dictionary(
        title = _("Thresholds and alarm overrides:"),
        elements = [
          ( "protocols",
            Tuple(
              title = _("Protocol support"),
              elements = [
                MonitoringState(title = _("SSLv2 enabled"), default_value = 2 ),
                MonitoringState(title = _("SSLv3enabled"), default_value = 2 ),
                MonitoringState(title = _("TLSv1 enabled"), default_value = 0 ),
                MonitoringState(title = _("TLSv1.1 enabled"), default_value = 0 ),
                MonitoringState(title = _("TLSv1.2 enabled"), default_value = 0 ),
              ]
            )
          ),
          ( "ciphers",
            Tuple(
              title = _("~standard cipher lists"),
              elements = [
                MonitoringState(title = _("Null Ciphers offered"), default_value = 2 ),
                MonitoringState(title = _("Anonymous NULL Ciphers offered"), default_value = 2 ),
                MonitoringState(title = _("Anonymous DH Ciphers offered"), default_value = 2 ),
                MonitoringState(title = _("40 Bit encryption offered"), default_value = 2 ),
                MonitoringState(title = _("56 Bit encryption offered"), default_value = 2 ),
                MonitoringState(title = _("Export Ciphers (general) offered"), default_value = 2 ),
                MonitoringState(title = _("Low (<=64 Bit) offered"), default_value = 2 ),
                MonitoringState(title = _("DES Ciphers offered"), default_value = 2 ),
                MonitoringState(title = _("\"Medium\" grade encryption offered"), default_value = 1 ),
                MonitoringState(title = _("Triple DES Ciphers offered"), default_value = 1 ),
                MonitoringState(title = _("\"High grade\" encryption offered"), default_value = 0 ),
              ]
            ),
          ),
          ( "server-defaults",
            Tuple(
              title = _("Certificate info Alarm settings"),
              elements = [
                MonitoringState(title = _("Received Chain Order is not OK"), default_value = 1 ),
                MonitoringState(title = _("Hostname Validation is not OK"), default_value = 2 ),
                MonitoringState(title = _("Not trusted in custom (ca_file, if specified) or Mozilla (fallback) CA Store"), default_value = 2 ),
                Transform(
                  Tuple(
                    title = _("Age"),
                    help = _("Minimum number of days a certificate has to be valid. "),
                    elements = [
                      Integer(title = _("Warning at or below"), minvalue = 0, unit = _("days"), default_value = 60),
                      Integer(title = _("Critical at or below"), minvalue = 0, unit = _("days"), default_value = 0),
                    ],
                  ),
                  forth = transform_cert_days,
                ),
                MonitoringState(title = _("No OCSP Stapling support"), default_value = 0 ),
              ]
            ),
          ),
          ( "headers",
            ListOf(CascadingDropdown(
                orientation = "horizontal",
                choices = [
                  ( "hsts", _("HSTS"), sslyze_option_to_state() ),
                  ( "hpkp", _("HPKP"), sslyze_option_to_state() ),
                ],
              ),
              title = _('HPKP/HSTS header settings'),
              help = _("It's the default to ignore the presence of headers in Alarm computation.")
            ),
          ),
          ( "heartbleed",
            MonitoringState(
              title = _("Heartbleed [CVE-2014-0160] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "ccs",
            MonitoringState(
              title = _("OpenSSL CSS [CVE-2014-0224] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "reneg",
            Tuple(
              title = _("Renegotiation support Alarm settings"),
              elements = [
                MonitoringState(title = _("No Secure Renegotiation supported [CVE-2009-3555]"), default_value = 2 ),
                MonitoringState(title = _("No Secure Client-initiated Renegotiation accepted"), default_value = 2 ),
              ]
            ),
          ),
          ( "crime",
            MonitoringState(
              title = _("CRIME [CVE-2012-4929] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "breach",
            MonitoringState(
              title = _("BREACH [CVE-2013-3587] vulnerable (Compression enabled)"),
              default_value = 2,
            ),
          ),
          ( "poodle",
            MonitoringState(
              title = _("POODLE, SSL [CVE-2014-3566] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "tls-fallback",
            MonitoringState(
              title = _("No TLS_FALLBACK_SCSV support? (downgrade vulnerable)"),
              default_value = 2,
            ),
          ),
          ( "freak",
            MonitoringState(
              title = _("FREAK [CVE-2015-0204] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "drown",
            MonitoringState(
              title = _("DROWN [CVE-2016-0703] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "logjam",
            MonitoringState(
              title = _("LOGJAM [CVE-2015-4000] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "beast",
            MonitoringState(
              title = _("BEAST [CVE-2011-3389] vulnerable"),
              default_value = 2,
            ),
          ),
          ( "pfs",
            Tuple(
              title = _("Forward secrecy"),
              elements = [
                MonitoringState(title = _("No robust (perfect) forward secrecy available"), default_value = 2 )
              ] 
            ),
          ),
          ( "rc4",
            MonitoringState(
              title = _("RC4 [CVE-2013-2566, CVE-2015-2808] ciphers used"),
              default_value = 2,
            ),
          ),
        ]
      ),
    ]),
    match = 'all',
)
