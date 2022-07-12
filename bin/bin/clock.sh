#!/bin/bash

clear
while : ; do
    echo -e "\033[2H\n"

    # tput setaf 6 && tput setab 5
    # date +%T | figlet -ctW -f mono12 | toilet -t -f term
    # tput op

    date +%T | figlet -ctW -f mono12 | toilet -t -f term -F metal

    # date +%T | figlet -ctW -f mono12 | toilet -t -f term -F metal
    # date +%T | figlet -ctW -f ascii12 | toilet -t -f term --metal
    sleep 1
done
