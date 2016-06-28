# notify-via-xmpp
This is a notificationscript for check_mk monitoring software
    it sends notifications via xmpp

    All parameters necessary to make this notification handler work
    are given via Environment Variables prefixed with 
    /^NOTIFY_.*/ (Notification Context Parameters from cmc), 
    /^NOTIFY_CONTACT_.*/ (Contact Context, e.g. CustomAttribut) and 
    /^NOTIFY_PARAMETER_.*/ (User supplied Parameters via WATO). A WATO File
    for configuration is present so you don't have to care about the parameters below.
    
    CONTACT_XMPP               The Custom Attribute XMPP is used as recipients jid.
    
    PARAMETER_XMPPSERVER       IP Address or Name of the XMPP Server
    PARAMETER_USER             Username used to connect to the SOI Server via FTP
    PARAMETER_PASSWORD         Password used to connect to the SOI Server via FTP
    PARAMETER_RESOURCE         You can specify a resource which is used. This might be useful if 
                               you use or don't use not notification forwarding.
    PARAMETER_SECURITY         Encrypt the client connection and choose which mechanism should be used. 
                               Port is automatically adjusted to 5222 or 5223
    PARAMETER_HOST_MESSAGE     Longtext used in Message if a Hostnotification is raised.
    PARAMETER_SERVICE_MESSAGE  Longtext used in Message if a Servicenotificationis raised.
    PARAMETER_URL_PREFIX       to link to the main site if you use distributed Monitoring.
    PARAMETER_CHATROOM         If activated, notifications are posted in a chatroom. Make sure that you 
                               don't generate multiple Notifications per Alarm.                      
    PARAMETER_TIMEOUT          <Timeout> in s; default: 3s
    PARAMETER_DEBUG            prints additional debug messages on STDERR which gets redirected to
                               ~/var/log/notify.log
                               
# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/notify-via-xmpp/notify-via-xmpp-1.0.mkp'
* OMD[SITENAME]:~$ check_mk -P install notify-via-xmpp-1.0.mkp

# Requirements
* xmpp Server
* perl-Net-XMPP (SLE packagename)
* Custom User Attribute containing the users jid/xmpp address. Name: 'XMPP', Set: 'Add as custom macro', Topic: 'Notifications'  

# Known issues
* TLS/SSL not working.

# History
* 1.1   Added html output in Message and removed max_len Parameter.
* 1.0   First release.
