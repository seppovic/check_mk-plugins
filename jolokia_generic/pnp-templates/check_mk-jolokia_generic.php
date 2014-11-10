<?php

$_WARNRULE = '#FFFF00';
$_CRITRULE = '#FF0000';
$_AREA     = '#256aef';
$_LINE     = '#3152A5';
$_MAXRULE  = '#000000';
$colors = array("#FF0000","#336600", "#6600FF","#FF3300", "#339900", "#6633FF", "#FF6600", "#6600FF", "#6666FF", "#FF9900", "#33FF00", "#6699FF", "#FFCC00", "#33FF33", "#66CCFF", "#FFFF00", "#66CC00", "#66FFFF");


$j=0;
$opt[1] = '--slope-mode -l0 --title "' . $this->MACRO['DISP_HOSTNAME'] . ' / ' . $this->MACRO['DISP_SERVICEDESC'] . '"';
$def[1] = '';
# Debugging Code
# throw new Kohana_exception(print_r($this->DS,true));
foreach ($this->DS as $KEY=>$VAL) {

	$def[1] .= rrd::def     ("var$KEY", $this->DS[$KEY]['RRDFILE'], $this->DS[$KEY]['DS'], "AVERAGE");
        $def[1] .= rrd::area    ("var$KEY", $colors[$j]."70", rrd::cut($this->DS[$KEY]["NAME"],40));
        $def[1] .= rrd::line1   ("var$KEY", "#000");
        $def[1] .= rrd::gprint  ("var$KEY", array("AVERAGE", "MAX", "LAST"), "%5.0lf");
	$j++;
}
?>
