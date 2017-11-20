# layer2_neighbors
extension to Maximilian Thoma's "cisco_inv_cdp" plugin from **http://www.lanbugs.de/howtos/monitoring-check_mk/inventory/check_mk-inventory-cisco-cdp-neighbors-extension/** which makes it hopefully more general for Linux Hosts too.
# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/layer2_neighbors/layer2_neighbors-1.0.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install layer2_neighbors-1.0.1.mkp

# Requirements
* If you want cdp or lldp Data for linux Hosts, you need lldpd(http://vincentbernat.github.io/lldpd/) deamon installed and running.

# TODO
* extract Agentplugin from mk_inventory.sh as used in our environment **lldpcli -f keyvalue show neighbors 2>/dev/null**
* Agent bakery plugin.

# Known issues

# History
* 1.0.1 Fixed Bug in inventory plugin.
* 1.0.0 initial Release.

