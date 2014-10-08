checkgroups = []
subgroup_applications = _("Applications, Processes &amp; Services")

register_check_parameters(
     subgroup_applications,
    "jvm_generic",
    _("JVM MBean levels"),
    Tuple(
        help = _("This rule sets the warn and crit levels for the user defined MBeans."
                 " There is no unit to specify, because it depends on the plugin output."),
        elements = [
            Float(
                title = _("Warning if below"),
                unit = _("rate/gauge value"),
                default_value = -1.0,
            ),
            Float(
                title = _("Critical if below"),
                unit = _("rate/gauge value"),
                default_value = -1.0,
            ),
            Float(
                title = _("Warning if above"),
                unit = _("rate/gauge value"),
                default_value = 0.0,
            ),
            Float(
                title = _("Critical if above"),
                unit = _("rate/gauge value"),
                default_value = 0.0,
            ),
        ]
    ),
    TextAscii(
        title = _("MBean/Attribute"),
        allow_empty = False
    ),
    "first"
)
