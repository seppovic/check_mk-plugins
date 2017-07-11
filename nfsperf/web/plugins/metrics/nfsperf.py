metric_info["readrx"] = {
    "title" : _("NFS read RX"),
    "unit"  : "bytes/s",
    "color" : "#90D4A9",
}
metric_info["readtx"] = {
    "title" : _("NFS read TX"),
    "unit"  : "bytes/s",
    "color" : "#FC2D80",
}
metric_info["writetx"] = {
    "title" : _("NFS write TX"),
    "unit"  : "bytes/s",
    "color" : "#90D4A9",
}
metric_info["writerx"] = {
    "title" : _("NFS write RX"),
    "unit"  : "bytes/s",
    "color" : "#FC2D80",
}
metric_info["rtime"] = {
    "title" : _("NFS read request time"),
    "unit"  : "bytes/s",
    "color" : "#3A9AD6",
}
metric_info["wtime"] = {
    "title" : _("NFS write request time"),
    "unit"  : "bytes/s",
    "color" : "#3A9AD6",
}




perfometer_info.append({
    "type"      : "linear",
    "segments"  : [ "readrx", "readtx" ],
})
perfometer_info.append({
    "type"      : "linear",
    "segments"  : [ "writetx", "writerx" ],
})
perfometer_info.append({
    "type"      : "linear",
    "segments"  : [ "rtime" ],
})
perfometer_info.append({
    "type"      : "linear",
    "segments"  : [ "wtime" ],
})




graph_info.append({
    "title"   : _("NFS read"),
    "metrics" : [
        ( "readrx", "area" ),
        ( "readtx", "stack" ),
    ],
})
graph_info.append({
    "title"   : _("NFS write"),
    "metrics" : [
        ( "writetx", "area" ),
        ( "writerx", "stack" ),
    ],
})
graph_info.append({
    "title"   : _("NFS read request time"),
    "metrics" : [
        ( "rtime", "area" ),
    ],
})
graph_info.append({
    "title"   : _("NFS write request time"),
    "metrics" : [
        ( "wtime", "area" ),
    ],
})
