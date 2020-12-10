register_check_parameters(
    subgroup_applications,
    "slapd_stats_operations",
    _("slapd Operations"),
    Dictionary(
        elements = [
            ( "Bind",
                Tuple(
                    title = _("Bind"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Delete",
                Tuple(
                    title = _("Delete"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Add",
                Tuple(
                    title = _("Add"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Abandon",
                Tuple(
                    title = _("Abandon"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Extended",
                Tuple(
                    title = _("Extended"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Search",
                Tuple(
                    title = _("Search"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Modify",
                Tuple(
                    title = _("Modify"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Unbind",
                Tuple(
                    title = _("Unbind"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Modrdn",
                Tuple(
                    title = _("Modrdn"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "Compare",
                Tuple(
                    title = _("Compare"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
                    ]
                )
            ),
            ( "deviance",
                Tuple(
                    title = _("Max. Deviance"),
                    elements = [
                        Integer(title = _("Warning: "), default_value = 0 ),
                        Integer(title = _("Critical: "), default_value = 0 ),
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
