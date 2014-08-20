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
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromTimerOps",
                Tuple(
                    title = _("From Timer"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromSyncOps",
                Tuple(
                    title = _("From Sync"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromSnapshotOps",
                Tuple(
                    title = _("From Snapshot"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromLogFullOps",
                Tuple(
                    title = _("From Log Full"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromHighWaterOps",
                Tuple(
                    title = _("From High Water"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromFlushOps",
                Tuple(
                    title = _("From Flush"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromLowWaterOps",
                Tuple(
                    title = _("From Low Water"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromLowVbufOps",
                Tuple(
                    title = _("From Low Vbuf"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
                    ]
                )
             ),
              ( "cpFromLowDatavecsOps",
                Tuple(
                    title = _("From Low Datavecs"),
                    elements = [
                        Integer(title = _("Warning if more than"), unit = _("CP"), default_value = None),
			Integer(title = _("Critical if more than"), unit = _("CP"), default_value = None)
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
    None, None
)
