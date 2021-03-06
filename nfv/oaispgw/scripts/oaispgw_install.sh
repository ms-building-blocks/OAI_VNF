#!/bin/bash

if [ -f "$SCRIPTS_PATH/func.sh" ]; then
        source $SCRIPTS_PATH/func.sh
else
        >&2 echo "$SERVICE: Could not find functions file $SCRIPTS_PATH/func.sh!"
        exit 1
fi

source_defaults_file 

if [ ! -d $OPENAIRCN_DIR ]; then
  # install the kernel mods and reboot the box
  if [ ! -f /opt/.rebooted ]; then
    upgrade_kernel >> $LOGFILE 2>&1

    touch /opt/.rebooted
    reboot
  fi
  echo "downloading and installing oai software" >> $LOGFILE 2>&1
  download_and_build_oai  >> $LOGFILE 2>&1
else
  echo "using pre-installed image" >> $LOGFILE 2>&1
fi



echo "127.0.1.1       $hostname.openair4G.eur $hostname" >> /etc/hosts

MGMT_INTERFACE=$(getInterfaceName 1)
SIGNAL_INTERFACE=$(getInterfaceName 1)
SIGNAL_IP=$mgmt_oa

#create_interface_config_file "$SIGNAL_INTERFACE" >> $LOGFILE 2>&1

source_generic_service_file "oaispgw" "install" "$SIGNAL_INTERFACE" "$MGMT_INTERFACE" "$SIGNAL_IP" >> $LOGFILE 2>&1
update_config_file "SGW_INTERFACE_NAME_FOR_S11              = \"lo\"; " "SGW_INTERFACE_NAME_FOR_S11              = \"$SIGNAL_INTERFACE\"; " $ETC_TARGET/spgw.conf   >> $LOGFILE 2>&1
update_config_file "SGW_IPV4_ADDRESS_FOR_S11                = \"127.0.11.2\/8\";" "SGW_IPV4_ADDRESS_FOR_S11                = \"$SIGNAL_IP\/8\";" $ETC_TARGET/spgw.conf   >> $LOGFILE 2>&1


echo "finished install script"
echo "finished install script" >> $LOGFILE 2>&1


