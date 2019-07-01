register_check_parameters(
    subgroup_applications,
    "slapd_syncrepl",
    _("slapd Syncrepl status"),
    Dictionary(
        elements = [
            ( "levels",
                Tuple(
                    title = _("deltatime between Consumer and Provider"),
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
    ), #instance
    "dict",
)
