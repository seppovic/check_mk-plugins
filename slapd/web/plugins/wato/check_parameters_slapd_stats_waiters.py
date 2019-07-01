register_check_parameters(
    subgroup_applications,
    "slapd_stats_waiters",
    _("slapd Waiters"),
    Dictionary(
        elements = [
            ( "Read",
                Tuple(
                    title = _("Read Waiters"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
             ( "Write",
                Tuple(
                    title = _("Write Waiters"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
       ]
    ),
    TextAscii(
        title = _("Instance Name"),
        help = _("Only needed if you have multiple SLAPD Instances on one server"),
    ),
    "dict",
)
