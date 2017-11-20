#!/usr/bin/python

inventory_displayhints.update({
    ".networking.neighbors:"        : { "title"    : _("Neighbors"),
                                        "render"   : render_inv_dicttable,
                                        "view"     : "neighbors_of_host",
                                        "keyorder" : ["l_if_name", "r_device", "r_if_name", "r_if_mac", "r_if_desc"] },
    ".networking.neighbors:*.l_if_name"   : { "title" : _("Local Interface") },
    ".networking.neighbors:*.r_device"    : { "title" : _("Remote Device Name") },
    ".networking.neighbors:*.r_if_name"      : { "title" : _("Remote Interface") },
    ".networking.neighbors:*.r_if_mac"      : { "title" : _("Remote MAC") },
    ".networking.neighbors:*.r_if_desc"      : { "title" : _("Remote Description") },
})

declare_invtable_view("invNeighbors", ".networking.neighbors:", _("Neighbor Interface"), _("Neighbor Interfaces"))
