# notify-via-soi
Notification script to forward notifications to CA-SOI.
    This is a notification script for check_mk monitoring software
    it puts an XML File via FTP into CA-SOIs spool directory.
    The script supports the generation and acknowledgement of alerts.

    The Rulebased Notification Rule should honor the following settings to work properly:

    - You must not use Bulking
    - Make sure you don't generate multiple Notifications for a single Alert.
      e.g. add a single useraccount and select only this user in 'Contact Selection'
      tab.
    - 'Match host event type' and 'Match service event type':
      - must not contain 'start or stop flapping' notification
      - must not contain 'start or stop scheduled downtime' notification
      - must contain 'Acknowledgement of service/host problem'
      - state changes as you prefer.

    configure your notification settings accordingly if you don't use RBN.


# Installation
* $ su - SITENAME
* OMD[SITENAME]:~$ wget 'https://github.com/seppovic/check_mk-plugins/raw/master/notify-via-soi/notify-via-soi-1.1.1.mkp'
* OMD[SITENAME]:~$ check_mk -P install notify-via-soi-1.1.1.mkp

# Requirements
* CA-SOI (obviously)
* SOI Spooldirectory published via ftp

# Known issues

# History
* 1.1.1 updated to check_mk 1.4.0 compatibility.
* 1.1   added WATO file, fixed several Bugs.
* 1.0   First release.
