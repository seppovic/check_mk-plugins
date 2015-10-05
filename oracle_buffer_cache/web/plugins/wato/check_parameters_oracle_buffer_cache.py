checkgroups = []
subgroup_applications = _("Applications, Processes & Services")

register_check_parameters(
    subgroup_applications,
    "oracle_buffer_cache",
    _("Oracle buffer Cache"),
    Dictionary(
        help = _("The first time an Oracle Database user process requires a "
                 "particular piece of data, it searches for the data in the "
                 "database buffer cache. If the process finds the data already "
                 "in the cache (a cache hit), it can read the data directly "
                 "from memory. If the process cannot find the data in the cache "
                 "(a cache miss), it must copy the data block from a datafile "
                 "on disk into a buffer in the cache before accessing the data."
                 "Accessing data through a cache hit is faster than data access "
                 "through a cache miss."),
        elements = [
            ( "levels",
                Tuple(
                title = _("Minimum cache hit ratio needed, in percent"),
                elements = [
                    Percentage(title = _("Warning at"), default_value = 0.0, unit = _("% left")),
                    Percentage(title = _("Critical at"), default_value = 0.0, unit = _("% left")),
                ]
                )
            ),
        ],
    ),
    TextAscii(
        title = _("Instance Name"),
        help = _("Name of the Service description without the ORA prefix and the Buffer Cache suffix")
    ),
    match_type = "dict",
)

