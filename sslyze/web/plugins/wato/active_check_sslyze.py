#!/usr/bin/python
# -*- encoding: utf-8; py-indent-offset: 4 -*-


register_rulegroup("activechecks",
    _("Active checks (HTTP, TCP, etc.)"),
    _("Configure active networking checks like HTTP and TCP"))
group = "activechecks"

# These elements are also used in check_parameters.py
def sslyze_option_to_state():
    return CascadingDropdown(
        orientation = "horizontal",
        choices = [
            ("set", _("if set"), MonitoringState( default_value = 2 ) ),
            ("unset", _("if not set"), MonitoringState( default_value = 2 ) ),
        ]
    )


register_rule(group,
  "active_checks:sslyze",
  Tuple(
    title = _("check ssl Configuration using SSLyze"),
    help = _("This active check utilzes **sslyze** to check ssl/tls configuration of a given service against a couple"
                 "of predefined tests like: "
                 "* Heartbleed vulnerability"
                 "* Http Headers (HSTS, HPKP)"
                 "* Compression (BEAST, CRIME) vulnerabilities"
                 "* supported OpenSSL cipher suites (SSLv2, SSLv3, TLSv1, TLS1.1, TLSv1.2)"
                 "* validity of the server(s) certificate(s) against various trust stores"
                 "* support for the TLS_FALLBACK_SCSV cipher suite to prevent downgrade attacks"
                 "It is usefull if you want to monitor internal services which are not accessable by other more comprehensive testtools like [qualys ssltest](https://www.ssllabs.com/ssltest/). **sslyze** is expected to be in the search path."),
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
        optional_keys = [ "timeout", "plugins", "sniName", "startTLS" ],
        elements = [
          ( "sniName",
            TextUnicode(title = _("SNI Hostname"),
            help = _("Use Server Name Indication to specify the hostname to connect to."
            "You might want to specify the Hostname to verify the certificate. default is to only query the $HOSTIP$"),
          )),
          ( "plugins",
            ListChoice(
              title = _("SSL Tests to perform:"),
              toggle_all = True,
              default_value = [ 'regular' ],
              choices = [
                      ( 'regular', _("regular - shortcut for, sslv2, sslv3, tlsv1, tlsv1_1, tlsv1_2, reneg, certinfo_basic, compression, heartbleed, openssl_ccs, fallback") ),
                      ( 'sslv2', _("sslv2 - Scans the server(s) for supported OpenSSL cipher suites for SSLv2") ),
                      ( 'sslv3', _("sslv3 - Scans the server(s) for supported OpenSSL cipher suites for SSLv3") ),
                      ( 'tlsv1', _("tlsv1 - Scans the server(s) for supported OpenSSL cipher suites for TLSv1") ),
                      ( 'tlsv1_1', _("tlsv1_1 - Scans the server(s) for supported OpenSSL cipher suites for TLSv1.1") ),
                      ( 'tlsv1_2', _("tlsv1_2 - Scans the server(s) for supported OpenSSL cipher suites for TLSv1.2") ),
                      ( 'compression', _("compression - Tests the server(s) for Zlib compression support") ),
                      ( 'http_headers', _("http_headers - Checks for the HTTP Strict Transport Security (HSTS) and HTTP Public Key Pinning (HPKP)") ),
                      ( 'heartbleed', _("heartbleed - Tests the server(s) for the OpenSSL Heartbleed vulnerability (experimental)") ),
                      ( 'reneg', _("reneg - Tests the server(s) for client-initiated renegotiation and secure renegotiation support") ),
                      ( 'openssl_ccs', _("openssl_ccs - Tests the server(s) for the OpenSSL CCS injection vulnerability (experimental)") ),
                      ( 'fallback', _("fallback - Checks support for the TLS_FALLBACK_SCSV cipher suite to prevent downgrade attacks") ),
                      ( 'certinfo_basic', _("certinfo_basic - Verifies the validity of the server certificate Chain Order, Hostname Validation") ),
               ]
            ),
          ),
          ( "startTLS",
            DropdownChoice(
              title = _("Type of the startTLS method"),
              help = _("Type is automatically chosen from port if nothing or auto is selected"),
              default_value = "auto",
              choices = [
                ("auto",      _("auto")),
                ("xmpp",      _("XMPP")),
                ("xmpp_server",      _("XMPP Server")),
                ("ldap",    _("LDAP")),
                ("rdp", _("RDP")),
                ("smtp",    _("SMTP")),
                ("imap",    _("IMAP")),
                ("pop3",   _("POP3")),
                ("ftp",      _("FTP")),
                ("postgres",      _("POSTGRES")),
              ],
            ),
          ),
        ]
      ),
      Dictionary(
        title = _("Thresholds and alarm overrides:"),
        elements = [
          ( "sslv2",
            MonitoringState(
              title = _("SSLv2 enabled"),
              default_value = 2,
            )
          ),
          ( "sslv3",
            MonitoringState(
              title = _("SSLv3 enabled"),
              default_value = 2,
            ),
          ),
          ( "tlsv1",
            MonitoringState(
              title = _("TLSv1 enabled"),
              default_value = 1,
            ),
          ),
          ( "tlsv1_1",
            MonitoringState(
              title = _("TLSv1.1 enabled"),
              default_value = 1,
            ),
          ),
          ( "tlsv1_2",
            MonitoringState(
              title = _("TLSv1.2 enabled"),
              default_value = 0,
            ),
          ),
          ( "compression",
            MonitoringState(
              title = _("Compression enabled"),
              default_value = 2,
            ),
          ),
          ( "http_headers",
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
              title = _("Heartbleed vulnerable"),
              default_value = 2,
            ),
          ),
          ( "reneg",
            Tuple(
              title = _("Renegotiation support settings"),
              elements = [
                MonitoringState(title = _("Client-initiated Renegotiation accepted"), help = _("This is considered an unsafe setting if true"), default_value = 2 ),
                MonitoringState(title = _("Secure Renegotiation supported"), help = _("This is considered a safe setting if true"), default_value = 0 ),
              ]
            ),
          ),
#          ( "openssl_ccs",
#          ),
#          ( "fallback",
#          ),
#          ( "certinfo_basic",
#          ),
        ]
      ),
    ]),
    match = 'all',
)
