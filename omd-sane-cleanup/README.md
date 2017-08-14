# omd-sane-cleanup
This Plugin is actually a script to cleanup the omd inventory archive. But it is tightly integrated into check_mk so it is realized as plugin for the Agent.
The cleanup follows these rules:
1. statisfy the files per day constraint (e.g. keep last Report per day)
2. statisfy the days per month constraint (e.g. keep all Reports left from 1. for the last 3 Months)
3. statisfy the months per year constraint (e.g. keep all Reports left from 1. and 2. for 1 Year)
4. statisfy the max year constraint (e.g. delete all reports older than 1 year)
5. statisfy the max size constraint (e.g. delete all reports, starting with the oldest until we are below 400 MB per folder)

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/omd-sane-cleanup/omd-sane-cleanup-1.0.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install omd-sane-cleanup-1.0.1.mkp

# Requirements
* omd/check_mk with inventory turned on.

# TODO
* Step 5, cleanup on disk usage constraint

# Known issues

# History
* 1.0.1 checkman and agent file tidy'ed.
* 1.0.0 First release.
