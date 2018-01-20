   #!/bin/bash
   selectst=""
   for i in ESPEasy*bin
   do
           selectst="$i $i off $selectst"
   done
   
   # esptool installieren
   git clone https://github.com/espressif/esptool.git
   
   # check for esptool
   esptoolbin=$(which esptool)
   if [ ! -x "$esptoolbin" ] ; then
           if [ -x "./esptool" ] ; then
                   esptoolbin="./esptool"
           else
                   eardu=$(find $HOME/.arduino15/packages/esp8266/tools/esptool/* -name esptool|sort|tail -1)
                   if [ -x "$eardu" ] ; then
                           echo "found esptool: $eardu"
                           esptoolbin="$eardu"
                   fi
           fi
   fi
   if [ ! -x "$esptoolbin" ] ; then
           echo "esptool not found, you can link it here or put in \$PATH"
           exit 2
   else
           echo "using esptool $esptoolbin"
   fi
   
   lsusb
   
   read -e -p "serial device, (USB2serial devices: $(ls /dev/ttyUSB*)):" -i "/dev/ttyUSB0" serdev
   if [ ! -r "$serdev" ] ; then
           echo "device '$serdev' does not exist"
           exit 2
   fi
   if [ -n "$(which dialog)" ] ; then
           cmd=(dialog --radiolist "Select firmware" 22 76 16)
           choice=$("${cmd[@]}" ${selectst} 2>&1 >/dev/tty)
   else
           # bash only, do it with an array
           fa=(ESPEasy_*.bin)
           cnt=0
           nfa=${#fa[*]}
           while [ $cnt -lt $nfa ]
           do
                   echo $cnt ${fa[$cnt]}
                   ((cnt++))
           done
           read -p "choose number of firmware file to flash [0-$((nfa-1))]: " nsel
           choice=${fa[$nsel]}
           if [ ! -f "$choice" ] ; then 
                   echo "cannot find file \"$choice\", exiting"
                   exit 2
           fi
   fi
   echo "----"
   read -p "flash $choice? [Y/n]" yn
   if [ "$yn" != "n" ] ; then
       "$esptoolbin" -vv -cd nodemcu -cb 115200 -cp "$serdev" -ca 0x00000 -cf "$choice"
   fi
