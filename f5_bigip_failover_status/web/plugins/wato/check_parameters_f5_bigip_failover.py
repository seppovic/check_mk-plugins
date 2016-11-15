checkgroups = []
subgroup_applications = _("Applications, Processes & Services")


register_check_parameters(
    subgroup_applications,
    "f5_bigip_failover",
    _("f5 BigIP Failover status"),
    Dictionary(
        help = _("State a Failover status change should raise. Beware, the initial State is always ok."),
        elements = [
            ( "0", MonitoringState(title = "State changes to UNKNOWN (snmpvalue:0)", default_value = 3)),
            ( "1", MonitoringState(title = "State changes to OFFLINE (snmpvalue:1)", default_value = 2)),
            ( "2", MonitoringState(title = "State changes to FORCED OFFLINE (snmpvalue:2)", default_value = 0)),
            ( "3", MonitoringState(title = "State changes to STANDBY (snmpvalue:3)", default_value = 1)),
            ( "4", MonitoringState(title = "State changes to ACTIVE (snmpvalue:4)", default_value = 1)),
        ]
    ),
    None, #instance
    "dict",
)
