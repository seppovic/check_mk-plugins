checkgroups = []
group = "checkparams"
subgroup_applications = _("Applications, Processes & Services")

register_check_parameters(
    subgroup_applications,
    "smt_custom_repos",
    _("SUSE SMT repository to product assignment"),
    ListOf(
       Tuple(
         show_titles = True,
         title = _("Mappings between repository and products"),
         orientation = "vertical",
         elements = [
           TextAscii(
             title = _("Name of repository/catalog"),
           ),
           ListOfStrings(
             title = _("Products (in the form <tt>productname/version/arch</tt>)"),
             show_titles = True,
             orientation = "horizontal",
           ),
         ],
       ),
       add_label = _("Add new mapping"),
       help = _("You can define assignments between products and repository/catalog in SUSE SMT which this check monitors for its presence."),
    ),
    None,
    "first",
)
