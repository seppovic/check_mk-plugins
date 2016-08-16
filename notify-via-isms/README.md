# notify-via-isms
This is a notificationscript for check_mk monitoring software
    it sends notifications via sms

    All parameters necessary to make this notification handler work
    are given via Environment Variables prefixed with
    /^NOTIFY_.*/ (Notification Context Parameters from cmc),
    /^NOTIFY_CONTACT_.*/ (Contact Context, e.g. CustomAttribut) and
    /^NOTIFY_PARAMETER_.*/ (User supplied Parameters via WATO). A WATO File
    for configuration is present so you don't have to care about the parameters below.

	PARAMETER_ISMSSERVER       IP Address or Name of the isms Server
	PARAMETER_USER             Username used to connect to the isms Server
    PARAMETER_PASSWORD         Password used to connect to the isms Server
    PARAMETER_HOST_MESSAGE     Longtext used in Message if a Hostnotification is raised.
    PARAMETER_SERVICE_MESSAGE  Longtext used in Message if a Servicenotificationis raised.
    PARAMETER_SPLITMAX         Max. Messages to send for one Notification if Text is longer than 160 characters.
    PARAMETER_TIMEOUT          <Timeout> in s; default: 10s
    PARAMETER_DEBUG            prints additional debug messages on STDERR which gets redirected to
                               ~/var/log/notify.log

# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/notify-via-isms/notify-via-isms-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install notify-via-xmpp-1.0.mkp

# Requirements
* A MultiTech multimodem-isms
* Pager Number set for the desired Contacts

# Known issues

# History
* 1.0   First release.
