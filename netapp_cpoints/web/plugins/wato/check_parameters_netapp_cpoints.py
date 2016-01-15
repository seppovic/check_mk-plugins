checkgroups = []
subgroup_storage = _("Storage, Filesystems and Files")

register_check_parameters(
     subgroup_storage,
    "netapp_cpoints",
    _("Netapp Consitency Points"),
    Dictionary(
          help = _("Here you can override the default levels for the Netapp Consistency Points check. The levels "
                   "are applied on the number of Consistency Points made since last checktime."),
          elements = [
              ( "cpTotalOps",
                Tuple(
                    title = _("Total"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromTimerOps",
                Tuple(
                    title = _("From Timer"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromSyncOps",
                Tuple(
                    title = _("From Sync"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromSnapshotOps",
                Tuple(
                    title = _("From Snapshot"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromLogFullOps",
                Tuple(
                    title = _("From Log Full"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromHighWaterOps",
                Tuple(
                    title = _("From High Water"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromFlushOps",
                Tuple(
                    title = _("From Flush"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromLowWaterOps",
                Tuple(
                    title = _("From Low Water"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromLowVbufOps",
                Tuple(
                    title = _("From Low Vbuf"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromLowDatavecsOps",
                Tuple(
                    title = _("From Low Datavecs"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = -1),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = -1)
                    ]
                )
             ),
              ( "cpFromCpOps",
                Tuple(
                    title = _("Back to Back"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = 30),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = 50)
                    ]
                )
             ),
              ( "cpFromCpDeferredOps",
                Tuple(
                    title = _("Deferred Back to Back"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = 30),
            Integer(title = _("Critical if more than"), unit = _("CP"), default_value = 50)
                    ]
                )
             ),
          ],
    ),
    None,
    "dict",
)
