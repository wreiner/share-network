#!/bin/sh

# pacman -S linux-headers
# yay -S rtl88xxau-aircrack-dkms-git
# pacman -S dnsmasq hostapd

usage()
{
    echo "$0 -u <upstream interface> -s <shared interface> -d <dnsmasq.conf> -a <hostapd.conf>"
    echo
    echo "Available interfaces:"
    ip a | grep -P '^\d+'
    echo
    exit 1
}

preflight()
{
    sharingif=$1

    # let networkmanager forget the interface
    #nmcli dev set ${sharingif} managed no

    # set ip on sharing wifi interface
    echo "set ip address on sharing interface .."
    ip address add 192.168.9.1/24 dev "${sharingif}"
}

start_dnsmasq()
{
    sharingif=$1
    dnsmasq_conf=$2

    # enable dhcp with dnsmasq
    echo "starting dnsmasq .."

    if [ -f /etc/dnsmasq.conf ];
    then
        echo "making backup of existing dnsmasq conf .."
        mv /etc/dnsmasq.conf /etc/dnsmasq.conf.$(date "+%Y%m%d%H%M")
    fi

    cp -f "${dnsmasq_conf}" /etc/dnsmasq.conf
    sed -i "s/SHAREIF/${sharingif}/" /etc/dnsmasq.conf

    dnsmasq -a 192.168.9.1 -C /etc/dnsmasq.conf
}

start_accesspoint()
{
    sharingif=$1
    hostapd_conf=$2

    # enable access point
    echo "starting hostapd .."

    if [ -f /etc/hostapd/hostapd.conf ];
    then
        echo "making backup of existing hostapd conf .."
        mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.$(date "+%Y%m%d%H%M")
    fi

    cp -f "${hostapd_conf}" /etc/hostapd/hostapd.conf
    sed -i "s/SHAREIF/${sharingif}/" /etc/hostapd/hostapd.conf

    hostapd -B /etc/hostapd/hostapd.conf
}

enable_ipforwarding()
{
    sharingif=$1
    upstreamif=$2

    echo "enable ip forwarding .."

    iptables -A FORWARD -o "${upstreamif}" -i "${sharingif}" -s 192.168.9.0/24 -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -t nat -A POSTROUTING -o "${upstreamif}" -j MASQUERADE

    sysctl -w net.ipv4.ip_forward=1
}

while getopts s:u:d:a:h flag
do
    case "${flag}" in
        h)
            usage
            ;;
        a)
            hostapd_conf=${OPTARG}
            ;;
        d)
            dnsmasq_conf=${OPTARG}
            ;;
        s)
            sharingif=${OPTARG}
            ;;
        u)
            upstreamif=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${hostapd_conf}" ] || [ -z "${dnsmasq_conf}" ] || [ -z "${sharingif}" ] || [ -z "${upstreamif}" ];
then
    usage
    exit 1
fi

preflight "${sharingif}"

start_dnsmasq "${sharingif}" "${dnsmasq_conf}"
start_accesspoint "${sharingif}" "${hostapd_conf}"
enable_ipforwarding "${sharingif}" "${upstreamif}"
