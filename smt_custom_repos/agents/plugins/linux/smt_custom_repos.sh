#!/bin/bash

#set -x
SMTCONF="/etc/smt.conf"

cfg_parser ()
{
    ini="$(<$1)"                # read the file
    ini="${ini//[/\[}"          # escape [
    ini="${ini//]/\]}"          # escape ]
    IFS=$'\n' && ini=( ${ini} ) # convert to line-array
    ini=( ${ini[*]//;*/} )      # remove comments with ;
    ini=( ${ini[*]/\    =/=} )  # remove tabs before =
    ini=( ${ini[*]/=\   /=} )   # remove tabs be =
    ini=( ${ini[*]/\ =\ /=} )   # remove anything with a space around =
    ini=( ${ini[*]/#\\[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%\\]/ \(} )    # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )    # convert item to array
    ini=( ${ini[*]/%/ \)} )     # close array parenthesis
    ini=( ${ini[*]/%\\ \)/ \\} ) # the multiline trick
    ini=( ${ini[*]/%\( \)/\(\) \{} ) # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} ) # remove extra parenthesis
    ini[0]="" # remove first element
    ini[${#ini[*]} + 1]='}'    # add the last brace
    eval "$(echo "${ini[*]}")" # eval the result
}

if [ -f $SMTCONF ]; then
  cfg_parser "$SMTCONF"
  cfg.section.DB # initializes all variables in Section DB (user, pass, config)
  db=${config/dbi\:mysql\:database=/}
  db=${db/;host=localhost/} # we asume the smt DB is on the localhost

  echo "<<<smt_custom_repos:sep(124)>>>"
  echo "[Catalogs]"
  echo "Select CONCAT_WS('|', ID, Name) from Catalogs;" |mysql --skip-column-names -u $user -p$pass $db
  echo "[ProductCatalogs]"
  echo "SELECT CONCAT_WS('|', PRODUCTID, CATALOGID) FROM ProductCatalogs;" |mysql --skip-column-names -u $user -p$pass $db 
  echo "[Products]"
  echo "SELECT CONCAT_WS('|', ID, PRODUCT, VERSION, ARCH) FROM Products" | mysql --skip-column-names -u $user -p$pass $db 
fi
