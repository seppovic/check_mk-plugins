<?php

#$color = array('#222', '#00ff00', '#008a6d', '#0000ff', '#ff00ff', '#ff6044', '#fff200', '#35962b', '#69d2e7', '#bab27f', '#f51d30', '#ff0000',);
$color = array('#222', '#00ff00', '#008a6d', '#0000ff', '#00ffff', '#9999ff', '#4c0099', '#7f00ff', '#b266ff', '#CC99ff', '#f51d30', '#ff0000',);
$i = 0;
$def_1 ='';
$def_2 ='';
$opt[1] = '--slope-mode --vertical-label "CP / Min" -l0 --title "' . $this->MACRO['DISP_HOSTNAME'] . ' / ' . $this->MACRO['DISP_SERVICEDESC'] . '"';
$ds_name[1]=$this->MACRO['DISP_SERVICEDESC'];


# Debugging Code
# throw new Kohana_exception(print_r($this->DS,true));
$def[1] = '';
foreach ($this->DS as $KEY=>$VAL) {
	$def_1 .= rrd::def("var$KEY", $this->DS[$KEY]['RRDFILE'], $this->DS[$KEY]['DS'], "MAX");

# stack all CP Types except TotalCPs (put it in the background) and FromTimerCPs (use it as a basline).
# therefore it is important to keep the these 2 the first Types.
	if ($i>1){
		$def_2 .= rrd::area("var$KEY", $color[$i], str_pad($this->DS[$KEY]['NAME'],25," "), true);
	}else{
		$def_2 .= rrd::area("var$KEY", $color[$i], str_pad($this->DS[$KEY]['NAME'],25," "));
	}
	$def_2 .= rrd::gprint("var$KEY", array("LAST", "AVERAGE", "MAX"), "%6.2lf");
	$i++;
}
$def[1] .= $def_1 . $def_2;
?>
