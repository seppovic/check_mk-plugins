#!/usr/bin/python
# -*- encoding: utf-8; py-indent-offset: 4 -*-

register_notification_parameters("isms.pl",
    Dictionary(
        optional_keys = ["splitmax", "timeout", "debug"],
        elements = [
            ( "ismsserver",
              TextAscii(
                title = _("isms-Server"),
                help = _("IP or Hostname of the isms Server")
              ),
            ),
            ( "user",
              TextAscii(
                title = _("Username"),
                help = _("Username used to connect to the isms Server")
              ),
            ),
            ( "password",
              TextAscii(
                title = _("Password"),
                help = _("Password used to connect to the isms Server"),
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
$NOTIFICATIONTYPE$ $HOSTNAME$> is $HOSTSTATE$ /$SHORTDATETIME$/ $HOSTOUTPUT$
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
Nagios Alert Type: $NOTIFICATIONTYPE$
Host: $HOSTNAME$
Service: $SERVICEDESC$
Info: $SERVICEOUTPUT$
""",
              ),
            ),
            ( "timeout",
              Integer(
                  title = _("Timeout"),
                  help = _("Timeout in seconds"),
                  default_value = 10
              ),
            ),
            ( "splitmax",
              Integer(
                  title = _("Max. Messages to send for one Notification."),
                  help = _("Split message into 160 character pieces up to X msgs, 0 means no limitation."),
                  default_value = 1
              ),
            ),
            ( "debug",
              FixedValue(
                True,
                title = _("debug"),
                totext = _("debug messages are printed to ~/var/log/notify.log"),
              )
            ),
        ])
    )
