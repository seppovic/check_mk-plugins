#!/usr/bin/python
# -*- encoding: utf-8; py-indent-offset: 4 -*-

register_notification_parameters("xmpp.pl",
    Dictionary(
        optional_keys = ["url_prefix", "resource", "chatroom", "security", "timeout", "debug"],
        elements = [
            ( "xmppserver",
              TextAscii(
                title = _("XMPP-Server"),
                help = _("IP or Hostname of the XMPP Server")
              ),
            ),
            ( "user",
              TextAscii(
                title = _("Username/JID"),
                help = _("Username/JID used to connect to the XMPP Server")
              ),
            ),
            ( "password",
              TextAscii(
                title = _("Password"),
                help = _("Password used to connect to the XMPP Server"),
                default_value = ""
              ),
            ),
            ( "host_message",
              TextAreaUnicode(
                  title = _("Message for notifications regarding a host"),
                  help = _("Here you are allowed to use all macros that are defined in the "
                           "notification context."),
                  rows = 9,
                  cols = 58,
                  monospaced = True,
                  default_value = """
HOST: $HOSTNAME$ - $HOSTSTATE$
Plugin Output: $HOSTOUTPUT$
Link: $HOSTURL$
""",
              ),
            ),
            ( "service_message",
              TextAreaUnicode(
                  title = _("Message for notifications regarding a service"),
                  help = _("Here you are allowed to use all macros that are defined in the "
                           "notification context."),
                  rows = 9,
                  cols = 58,
                  monospaced = True,
                  default_value = """
SERVICE: $HOSTNAME$/$SERVICEDESC$ - $SERVICESTATE$
Plugin Output: $SERVICEOUTPUT$
Link: $SERVICEURL$
""",
              ),
            ),
            ( "url_prefix",
              TextAscii(
                  title = _("URL prefix for links to Check_MK"),
                  help = _("If you specify an URL prefix here, then $HOSTNAME$ and $SERVICEDESC$ are "
                           "armed with hyperlinks to your Check_MK GUI, so "
                           "that the recipient Event can directly visit the host or "
                           "service in Check_MK. Specify an absolute URL"),
                  regex = "^(http|https)://.*$",
                  regex_error = _("The URL must begin with <tt>http</tt> or "
                                  "<tt>https</tt>"),
                  size = 64,
                  default_value = "http://" + socket.gethostname() + "/" + (
                          defaults.omd_site and defaults.omd_site or "xmpp-resource"),
              ),
            ),
            ( "security",
                DropdownChoice(
                    choices = [
                        ('TLS', _('TLS')),
                        ('SSL', _('SSL')),
                    ],
                    help = _("Encrypt the client connection and choose which mechanism should be used. Port is automatically adjusted to 5222 or 5223"),
                    title = _("Dont't use cleartext communication to the xmpp Server"),
                    default = "TLS"
                ),
             ),
            ( "resource",
              TextAscii(
                  title = _("XMPP Resource"),
                  help = _("You can specify a resource which is used. This might be useful if you use or don't use not notification forwarding."),
                  size = 64,
                  default_value = defaults.omd_site and defaults.omd_site or "",
              ),
            ),
            ( "chatroom",
              FixedValue(
                True,
                title = _("Reciepient is a chatroom"),
                totext = _("If activated, notifications are posted in a chatroom. Make sure that you don't generate multiple Notifications per Alarm."),
              ),
            ),
            ( "timeout",
              Integer(
                  title = _("Timeout"),
                  help = _("Timeout in seconds"),
                  default_value = 3
              ),
            ),
            ( "debug", FixedValue(
                True,
                title = _("debug"),
                totext = _("debug messages are printed to ~/var/log/notify.log"),
              )
            ),
        ])
    )
