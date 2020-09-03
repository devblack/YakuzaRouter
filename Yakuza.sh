#!/bin/bash

DIR=''
FULLDIRS=()
CONFIGS=()
O_RUN=0
COUNTRY=''
STATUS=0
BLUE='\e[1;94m'
GREEN='\e[1;92m'
RED='\e[1;91m'
END='\e[1;00m'

function Response {
    if [[ "$1" == "ASK" ]]; then
        echo -n -e "${GREEN}[?] $2${END}"
    elif [[ "$1" == "RESP" ]]; then
        echo -e "${BLUE}[=] $2${END}"
    else
        echo -e "${RED}[X] $2${END}"
    fi
}

function GetIP {
    ip=$(curl -s "https://api.myip.com/" | awk -F'"' '{ print $4 }')
}

function Banner {
    cat << EOF
    

            ██    ██  █████  ██   ██ ██    ██ ███████  █████      ██████   ██████  ██    ██ ████████ ███████ ██████  
             ██  ██  ██   ██ ██  ██  ██    ██    ███  ██   ██     ██   ██ ██    ██ ██    ██    ██    ██      ██   ██ 
              ████   ███████ █████   ██    ██   ███   ███████     ██████  ██    ██ ██    ██    ██    █████   ██████  
               ██    ██   ██ ██  ██  ██    ██  ███    ██   ██     ██   ██ ██    ██ ██    ██    ██    ██      ██   ██ 
               ██    ██   ██ ██   ██  ██████  ███████ ██   ██     ██   ██  ██████   ██████     ██    ███████ ██   ██ 
    
                                                                                        C0d3d by B4SH^[THL]
EOF
	sleep 1
}

function FixDir {
    #prevent over writing
    DIR=''
    if [[ "${tmp::-1}" != "/" ]]; then
        DIR="$tmp/"
    else
        DIR=$tmp
    fi
}

function StartRouter {
    if [[ -z "$DIR" ]]; then
        Response "ERROR" "Please set the OpenVPN directory, use: dir"
    elif ! [[ ${#FULLDIRS[@]} -gt 0 ]]; then
        Response "ERROR" "Check your OpenVPN directory, i think it's empty :("
    elif [[ -z ${O_RUN} ]]; then
        Response "ERROR" "Please set a country connect, use: help"
    elif [[ $STATUS == 1 ]]; then
        Response "ERROR" "YakuzaRouter is already up!"
    else
        Response "RESP" "Disabling IPV6 protocol..."
        sleep 2
        {
            sudo /sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo /sbin/sysctl -w net.ipv6.conf.default.disable_ipv6=1
        } &> /dev/null
        Response "RESP" "IPV6 protocol was disabled!"
        Response "RESP" "Starting OpenVPN in the country $COUNTRY...."
        sleep 2
        sudo -b openvpn --auth-nocache --config ${FULLDIRS[$O_RUN]} &> /dev/null
        sleep 5
        GetIP
        Response "RESP" "OpenVPN is up and your current ip is: $ip"
        STATUS=1
    fi
}

function StopRouter {
    Response "RESP" "Killing OpenVPN...."
    pkill openvpn
    sleep 1
    Response "RESP" "OpenVPN was killed successfull."
    STATUS=0
}

function Console {
    while true; do
        Response "ASK" "Yakuza: "
        read
        case "${REPLY}"
        in
            start)
                StartRouter
            ;;
            stop)
                StopRouter
            ;;
            dir)
                Response "ASK" "Patch: "
                read tmp
                if ! [[ -d "$tmp" ]]; then
                    Response "ERROR" "The assigned directory is invalid!"
                else
                    FixDir $tmp
                    #prevent over writing
                    FULLDIRS=()
                    CONFIGS=() 
                    for file in "$DIR"*.ovpn; do
                        if [[ -f $file ]]; then
                            FULLDIRS+=($file)
                            CONFIGS+=(${file/$DIR/})
                        else
                            Response "ERROR" "No valid files found!"
                            break
                        fi
                    done
                fi
            ;;
            countries)
                if [[ -z "$DIR" ]]; then
                    Response "ERROR" "Please set the ovpn directory, use: dir"
                elif ! [[ ${#FULLDIRS[@]} -gt 0 ]]; then
                    Response "ERROR" "Check your OpenVPN directory, i think it's empty :("
                else
                    for ((i = 0 ; i < ${#CONFIGS[@]}; i++)); do
                        printf "%-8s\n" "[$i] => ${CONFIGS[$i]/.ovpn/}"
                    done | column
                fi
            ;;
            set)
                if [[ -z "$DIR" ]]; then
                    Response "ERROR" "Please set the ovpn directory, use: dir"
                else
                    Response "ASK" "Country ($O_RUN): "
                    read cn
                    if ! [[ $cn =~ ^[0-9]+$ ]] || [[ -z ${CONFIGS[$cn]} ]]; then
                        Response "ERROR" "Please enter a valid country!"
                    else
                        O_RUN=$cn
                        COUNTRY=${CONFIGS[$cn]/.ovpn/}
                        Response "RESP" "The country $COUNTRY was selected correctly."
                    fi
                fi  
            ;;
            clear)
                test
                clear
            ;;
            help)
                echo -n -e "${BLUE}[/]  ~  YakuzaRouter (v.1) Commands  ~  [/]$END\n$RED [-] start     { Start the tunnel router. }$END\n$RED [-] stop      { Stop the tunnel router. }$END\n$RED [-] dir       { Set the current ovpn directory [file type: .ovpn]. }$END\n$RED [-] countries { Displays the list of the countries avaliable. }$END\n$RED [-] set       { Set the country number connect. }$END\n$RED [-] clear     { Clear the current terminal. }$END\n$RED [-] quit      { Exit from the script. }$END\n$RED [-] help      { Usage information. }$END\n"
            ;;
            q | quit | exit)
                Response "RESP" "Bye bye!"
                exit 1
            ;;
            *)
                Response "ERROR" "Whops, use: help"
            ;;
        esac
    done
}

if [ $(id -u) -ne 0 ]; then
	Response "ERROR" "This script must be run as root!"
	exit 1
fi
Banner
Console