#!/usr/bin/python
# -*- encoding: utf-8; py-indent-offset: 4 -*-

register_notification_parameters("notify-via-soi.pl",
    Dictionary(
        optional_keys = ["timeout", "debug", "keepxml"],
        elements = [
            ("soiserver",
             IPv4Address(
                title = _("SOI Server IP"),
                help = _("IP Address of the SOI Server receiving the XML via FTP")
             ),
            ),
            ("ftpuser",
             TextAscii(
                title = _("Username"),
                help = _("Username used to connect to the SOI Server via FTP")
             )),
            ("ftppassword",
             TextAscii(
                title = _("Password"),
                help = _("Password used to connect to the SOI Server via FTP"),
                default_value = ""
             ),
            ),
            ("ftppath",
             TextAscii(
                title = _("Path"),
                help = _("Path where we put the XML on the FTP Server")
             ),
            ),
            ( "hostheadline",
              TextUnicode(
                  title = _("Headline for host notifications"),
                  help = _("Here you are allowed to use all macros that are defined in the "
                           "notification context."),
                  default_value = "$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) - $HOSTSTATE$",
                  size = 64,
               )
            ),
            ( "serviceheadline",
              TextUnicode(
                  title = _("Headline for service notifications"),
                  help = _("Here you are allowed to use all macros that are defined in the "
                           "notification context."),
                  default_value = "$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) / $SERVICEDESC$ - $SERVICESTATE$",
                  size = 64,
               )
            ),
            ( "hostbody",
              TextAreaUnicode(
                  title = _("Alerttext for host notifications"),
                  rows = 9,
                  cols = 58,
                  monospaced = True,
                  default_value = """Output:   $HOSTOUTPUT$
Perfdata: $HOSTPERFDATA$
$LONGHOSTOUTPUT$
""",
              )
            ),
            ( "servicebody",
              TextAreaUnicode(
                  title = _("Alerttext for service notifications"),
                  rows = 11,
                  cols = 58,
                  monospaced = True,
                  default_value = """Service:  $SERVICEDESC$
Output:   $SERVICEOUTPUT$
Perfdata: $SERVICEPERFDATA$
$LONGSERVICEOUTPUT$
""",
            )
            ),

            ( "url_prefix",
              TextAscii(
                  title = _("URL prefix for links to Check_MK"),
                  help = _("If you specify an URL prefix here, then several parts of the "
                           "Alerttext body are armed with hyperlinks to your Check_MK GUI, so "
                           "that the recipient of the SOI Event can directly visit the host or "
                           "service in question in Check_MK. Specify an absolute URL"),
                  regex = "^(http|https)://.*$",
                  regex_error = _("The URL must begin with <tt>http</tt> or "
                                  "<tt>https</tt>"),
                  size = 64,
                  default_value = "http://" + socket.gethostname() + "/" + (
                          defaults.omd_site and defaults.omd_site or ""),
              )
            ),
            ( "timeout",
              Integer(
                  title = _("Timeout"),
                  help = _("Timeout in seconds"),
                  default_value = 3
              )
            ),
            ( "debug", FixedValue(
                True,
                title = _("debug"),
                totext = _("debug messages are printed to ~/var/log/notify.log"),
            )),
            ( "keepxml", FixedValue(
                True,
                title = _("Store xml"),
                totext = _("A copy of the uploaded XML File is stored in /tmp/. Be aware that this could get huge!!!"),
            )),
        ])
    )
