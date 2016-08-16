unit_info["1/m"] = {
    "title" : _("per minute"),
    "description" : _("Frequency (displayed in Consistencypoints/minute)"),
    "symbol" : _("/m"),
    "render" : lambda v: "%s%s" % (drop_dotzero(v), _("/m")),
}


metric_info["cpTotalOps"] = {
  "title" : _("cpTotalOps"),
  "unit"  : "1/m",
  "color" : "#222",
}
metric_info["cpFromTimerOps"] = {
  "title" : _("cpFromTimerOps"),
  "unit"  : "1/m",
  "color" : "#00ff00",
}
metric_info["cpFromSyncOps"] = {
  "title" : _("cpFromSyncOps"),
  "unit"  : "1/m",
  "color" : "#008a6d",
}
metric_info["cpFromSnapshotOps"] = {
  "title" : _("cpFromSnapshotOps"),
  "unit"  : "1/m",
  "color" : "#0000ff",
}
metric_info["cpFromLogFullOps"] = {
  "title" : _("cpFromLogFullOps"),
  "unit"  : "1/m",
  "color" : "#00ffff",
}
metric_info["cpFromHighWaterOps"] = {
  "title" : _("cpFromHighWaterOps"),
  "unit"  : "1/m",
  "color" : "#9999ff",
}
metric_info["cpFromFlushOps"] = {
  "title" : _("cpFromFlushOps"),
  "unit"  : "1/m",
  "color" : "#4c0099",
}
metric_info["cpFromLowWaterOps"] = {
  "title" : _("cpFromLowWaterOps"),
  "unit"  : "1/m",
  "color" : "#7f00ff",
}
metric_info["cpFromLowVbufOps"] = {
  "title" : _("cpFromLowVbufOps"),
  "unit"  : "1/m",
  "color" : "#b266ff",
}
metric_info["cpFromLowDatavecsOps"] = {
  "title" : _("cpFromLowDatavecsOps"),
  "unit"  : "1/m",
  "color" : "#CC99ff",
}
metric_info["cpFromCpOps"] = {
  "title" : _("cpFromCpOps"),
  "unit"  : "1/m",
  "color" : "#f51d30",
}

metric_info["cpFromCpDeferredOps"] = {
  "title" : _("cpFromCpDeferredOps"),
  "unit"  : "1/m",
  "color" : "#ff0000",
}

check_metrics["check_mk-netapp_cpoints"] = {
  "cpTotalOps" : { "name" : "cpTotalOps",          "auto_graph" : False },
  "cpFromTimerOps" : { "name" : "cpFromTimerOps",          "auto_graph" : False },
  "cpFromSyncOps" : { "name" : "cpFromSyncOps",          "auto_graph" : False },
  "cpFromSnapshotOps" : { "name" : "cpFromSnapshotOps",          "auto_graph" : False },
  "cpFromLogFullOps" : { "name" : "cpFromLogFullOps",          "auto_graph" : False },
  "cpFromHighWaterOps" : { "name" : "cpFromHighWaterOps",          "auto_graph" : False },
  "cpFromFlushOps" : { "name" : "cpFromFlushOps",          "auto_graph" : False },
  "cpFromLowWaterOps" : { "name" : "cpFromLowWaterOps",          "auto_graph" : False },
  "cpFromLowVbufOps" : { "name" : "cpFromLowVbufOps",          "auto_graph" : False },
  "cpFromLowDatavecsOps" : { "name" : "cpFromLowDatavecsOps",          "auto_graph" : False },
  "cpFromCpOps" : { "name" : "cpFromCpOps",          "auto_graph" : False },
  "cpFromCpDeferredOps" : { "name" : "cpFromCpDeferredOps",          "auto_graph" : False },
}

graph_info.append({
  "title" : _("Netapp Consistency Points / Min"),
  "metrics" : [
    ("cpTotalOps", "area"),
    ("cpFromTimerOps", "area"),
    ("cpFromSyncOps", "stack"),
    ("cpFromSnapshotOps", "stack"),
    ("cpFromLogFullOps", "stack"),
    ("cpFromHighWaterOps", "stack"),
    ("cpFromFlushOps", "stack"),
    ("cpFromLowWaterOps", "stack"),
    ("cpFromLowVbufOps", "stack"),
    ("cpFromLowDatavecsOps", "stack"),
    ("cpFromCpOps", "stack"),
    ("cpFromCpDeferredOps", "stack"),
    ],
})

