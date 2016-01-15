checkgroups = []
subgroup_networking = _("Networking")

register_check_parameters(
     subgroup_networking,
    "cisco_ras_sessions",
    _("Cisco Remote Access Sessions"),
    Dictionary(
        elements = [
            (   "IPSec",
        Tuple(
            title = _("IPSec Tunnel"),
            elements = [
                Integer(title = _("Warning if more Sessions than: "), default_value = None),
                Integer(title = _("Critical if more Sessions than: "), default_value = None)
            ]
        )
            ),
            (   "L2L",
        Tuple(
            title = _("Site to Site VPN"),
            elements = [
                Integer(title = _("Warning if more Sessions than: "), default_value = None),
                Integer(title = _("Critical if more Sessions than: "), default_value = None)
            ]
        )
            ),
            (   "LB",
        Tuple(
            title = _("VPN load-balancing"),
            elements = [
                Integer(title = _("Warning if more Sessions than: "), default_value = None),
                Integer(title = _("Critical if more Sessions than: "), default_value = None)
            ]
        )
            ),
            (   "SVC",
        Tuple(
            title = _("SSL VPN Client"),
            elements = [
                Integer(title = _("Warning if more Sessions than: "), default_value = None),
                Integer(title = _("Critical if more Sessions than: "), default_value = None)
            ]
        )
            ),
            (   "WebVPN",
        Tuple(
            title = _("Clientless SSL VPN"),
            elements = [
                Integer(title = _("Warning if more Sessions than: "), default_value = None),
                Integer(title = _("Critical if more Sessions than: "), default_value = None)
            ]
        )
            ),
        ],
    ),
    None,
    "dict",
)
