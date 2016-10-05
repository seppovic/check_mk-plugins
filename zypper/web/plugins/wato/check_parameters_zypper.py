checkgroups = []
subgroup_os =           _("Operating System Resources")

register_check_parameters(
    subgroup_os,
    "zypper",
    _("Zypper Updates"),
    Dictionary(
        elements = [
            ( "recommended",
                Tuple(
                    title = _("<=SLES11.4:recommended or >=SLES12.1:important updates"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "security",
                Tuple(
                    title = _("<=SLES11.4:security or >=SLES12.1:critical updates"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "duration",
                Tuple(
                    help = _("maximum duration in days security updates can be available until a warning or"
                        "critical state is raised."),
                    title = _("maximum duration for security updates"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0, unit = _("days")),
                        Integer(title = _("Critical: "), default_value = 0, unit = _("days")),
                    ]
                )
            ),
            ( "locks",
                MonitoringState(
                title = _("State a packagelock should raise"),
                default_value = 0,
                )
            ),
        ]
    ),
    None, #instance
    "dict",
)
