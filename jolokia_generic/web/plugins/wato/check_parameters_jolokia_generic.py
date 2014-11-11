checkgroups = []
subgroup_applications = _("Applications, Processes &amp; Services")

register_check_parameters(
     subgroup_applications,
    "jvm_generic",
    _("JVM MBean levels"),
    Dictionary(
        elements = [
            (   "levels",
                ListOf(


                    Tuple(
                        title = _("bla"),
                        elements = [
                            Float( title = _("Warning if below"), default_value = -1.0 ),
                            Float( title = _("Critical if below"), default_value = -1.0 ),
                            Float( title = _("Warning if above"), default_value = 0.0 ),
                            Float( title = _("Critical if below"), default_value = 0.0 ),
                            TextAscii( 
                                   title = _("Name of the MBean/Attribute (optional)"), 
                                   help = _("This might be helpful if you group some values together and want the Threshold only on a particular value.") 
                            ),
                        ],
                    ),
                    title = _("Thresholds for Nummeric values"),
                    help = _("set the warn and crit levels for gauge or rate values."),
                    movable = False,
                ),
            ),
            (   "expectedStrings",
                ListOfStrings(
                    title = _("Expected strings"),
                    help = _("specifiy all values which you expect to be ok. (regexes are supported, negating strings can also be done using regex)")
                )
                
            ),
        ],
        optional_keys = ["levels", "expectedStrings"]
    ),
    TextAscii(
        title = _("Item Name"),
        help = _("Name of the Service description without the JVM prefix")
    ),
    "first"
)
