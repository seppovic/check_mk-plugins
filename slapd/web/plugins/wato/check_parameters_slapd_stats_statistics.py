register_check_parameters(
    subgroup_applications,
    "slapd_stats_statistics",
    _("slapd Network Statistics"),
    Dictionary(
        elements = [
            ( "Entries",
                Tuple(
                    title = _("Entries rate"),
                    elements = [
                        Float(title = _("Warning: "), default_value = 0.0 ),
                        Float(title = _("Critical: "), default_value = 0.0 ),
                    ]
                )
            ),
            ( "Referarals",
                Tuple(
                    title = _("Referarals rate"),
                    elements = [
                        Float(title = _("Warning: "), default_value = 0.0 ),
                        Float(title = _("Critical: "), default_value = 0.0 ),
                    ]
                )
            ),
            ( "PDU",
                Tuple(
                    title = _("PDUs rate"),
                    elements = [
                        Float(title = _("Warning: "), default_value = 0.0 ),
                        Float(title = _("Critical: "), default_value = 0.0 ),
                    ]
                )
            ),
             ( "Bytes",
                Tuple(
                    title = _("Bytes rate"),
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
