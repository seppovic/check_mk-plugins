register_check_parameters(
    subgroup_applications,
    "slapd_stats_connections",
    _("slapd Connections"),
    Dictionary(
        elements = [
            ( "Current",
                Tuple(
                    title = _("Current Connections"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
             ( "Total",
                Tuple(
                    title = _("Total Connections"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "rate",
                Tuple(
                    title = _("Connection rate"),
                    elements = [
                        Float(title = _("Warning: "), default_value = 0.0 ),
                        Float(title = _("Critical: "), default_value = 0.0 ),
                    ]
                )
            ),
       ]
    ),
    TextAscii(
        title = _("Instance"),
        help = _("Only needed if you have multiple SLAPD Instances on one server"),
    ), #instance
    "dict",
)
