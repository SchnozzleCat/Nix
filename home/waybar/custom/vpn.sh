#!/bin/bash

vpn=`ifconfig | grep tun`

if [[ $vpn ]] 
then
   echo "{\"class\": \"running\", \"text\": \"\", \"tooltip\": \"\"}"
   exit
fi
