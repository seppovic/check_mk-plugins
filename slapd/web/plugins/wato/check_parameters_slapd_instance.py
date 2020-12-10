register_check_parameters(
    subgroup_applications,
    "slapd_instance",
    _("slapd Instance"),
    Dictionary(
	help = _("test"),
        elements = [
            ( "maxConnectionTime",
                Tuple(
                    title = _("Max. response time"),
                    elements = [
                        Float(title = _("Warning: "), default_value = 0.0, unit = _("seconds") ),
                        Float(title = _("Critical: "), default_value = 0.0, unit = _("seconds") ),
                    ]
                )
            ),
        ]
    ),
    TextAscii(
        title = _("Instance"),
        help = _("Only needed if you have multiple SLAPD Instances on one server"),
    ),
    "dict",
)
