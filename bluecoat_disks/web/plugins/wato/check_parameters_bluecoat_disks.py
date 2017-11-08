checkgroups = []
subgroup_networking = _("Networking")

register_check_parameters(
     subgroup_networking,
    "bluecoat_disks",
    _("BlueCoat physical disks"),
    Dictionary(
        title = _("Evaluation of Disk States"),
        elements = [
            (   "present",
                MonitoringState(
                    title = _("State for <i>present</i>"),
                    default_value = 0,
            )),
            (   "initializing",
                MonitoringState(
                    title = _("State for <i>initializing</i>"),
                    default_value = 1,
            )),
            (   "inserted",
                MonitoringState(
                    title = _("State for <i>inserted</i>"),
                    default_value = 0,
            )),
            (   "offline",
                MonitoringState(
                    title = _("State for <i>offline</i>"),
                    default_value = 2,
            )),
            (   "removed",
                MonitoringState(
                    title = _("State for <i>removed</i>"),
                    default_value = 2,
            )),
            (   "not-present",
                MonitoringState(
                    title = _("State for <i>not-present</i>"),
                    default_value = 2,
            )),
            (   "empty",
                MonitoringState(
                    title = _("State for <i>empty</i>"),
                    default_value = 0,
            )),
            (   "bad",
                MonitoringState(
                    title = _("State for <i>bad</i>"),
                    default_value = 2,
            )),
            (   "unknown",
                MonitoringState(
                    title = _("State for <i>unknown</i>"),
                    default_value = 3,
            )),
        ],
    ),
    TextAscii(
        title = _("Physical Disk Index"),
        allow_empty = False,
    ),
    "dict",
)
