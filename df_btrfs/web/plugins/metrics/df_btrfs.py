metric_info["btrfs_metadata"] = {
    "title" : _("BTRFS Metadata used"),
    "unit"  : "bytes",
    "color" : "31/a",
}

check_metrics["check_mk-df_btrfs"]  = {
    "~(?!inodes_used|fs_size|growth|trend|fs_provisioning|"
      "uncommitted|overprovisioned|btrfs).*$"   : { "name"  : "fs_used", "scale" : MB },
    "fs_size" : { "scale" : MB },
    "growth"  : { "name"  : "fs_growth", "scale" : MB / 86400.0 },
    "trend"   : { "name"  : "fs_trend", "scale" : MB / 86400.0 },
    "btrfs_metadata" : { "name"  : "btrfs_metadata", "scale" : MB },
}
