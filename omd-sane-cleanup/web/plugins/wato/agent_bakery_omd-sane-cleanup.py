#!/usr/bin/python

import agent_bakery
import cmk.paths


group = "agents/" + _("Agent Plugins")

register_rule(group,
    "agent_config:omd-sane-cleanup",
    Transform(
        Alternative(
            title = _("omd-sane-cleanup agent plugin (Linux)"),
            help = _("This will deploy the <tt>omd-sane-cleanup agent plugin</tt>, a script to cleanup the omd inventory archive."
                     "It is tightly integrated into check_mk so it is realized as plugin for the Agent."),
            style = "dropdown",
            elements = [
                Dictionary(
                    title = _("Deploy the plugin with following configuration"),
                    elements = [
                         ( "archivePaths",
                           ListOfStrings(
                               title = _("you might want to add more than one site"),
                               size = 64,
                         )),

                         ( "filesPerDay",
                            Integer(
                                title = _("Files to keep per day"),
				default_value = 1,
				minvalue = 1,
				maxvalue = 65535,
                         )),
                         ( "daysPerMonth",
                            Integer(
                                title = _("days to keep per month"),
				default_value = 30,
				minvalue = 1,
				maxvalue = 65535,
                         )),
                         ( "MonthsPerYear",
                            Integer(
                                title = _("months to keep per year"),
				default_value = 12,
				minvalue = 1,
				maxvalue = 65535,
                         )),
                         ( "maxYears",
                            Integer(
                                title = _("max years to keep inventory data"),
				default_value = 1,
				minvalue = 1,
				maxvalue = 65535,
                         )),
                         ( "maxSize",
                            Integer(
                                title = _("maximal size (MB) a Host can keep"),
				default_value = 400,
				minvalue = 1,
				maxvalue = 65535,
                         )),
                    ],
                ),
                FixedValue(None, title = _("Do not deploy the plugin"), totext = _("(disabled)") ),
            ],
            default_value = {
		"archivePaths"  : ['%s/var/check_mk/inventory_archive/' % cmk.paths.omd_root ],
		"filesPerDay"   : 1,
		"daysPerMonth"  : 30,
		"MonthsPerYear" : 12,
		"maxYears"      : 1,
		"maxSize"	: 400,
            },
        ),
    ),
)
