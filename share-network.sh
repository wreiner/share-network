#!/bin/sh

# pacman -S linux-headers
# yay -S rtl88xxau-aircrack-dkms-git
# pacman -S dnsmasq hostapd

usage()
{
    echo "$0 <upstream interface> <shared interface>"
    echo
    echo "Available interfaces:"
    ip a | grep -P '^\d+'
    echo
    exit 1
}

upstreamif=$1
if [ -z "${upstreamif}" ];
then
    usage
    exit 1
fi

sharingif=$2
if [ -z "${sharingif}" ];
then
    usage
    exit 1
fi

# let networkmanager forget the interface
#nmcli dev set ${sharingif} managed no

# set ip on sharing wifi interface
echo "set ip address on sharing interface .."
ip address add 192.168.9.1/24 dev "${sharingif}"

# enable dhcp with dnsmasq
echo "starting dnsmasq .."
cp -f /root/share-network/dnsmasq.conf /etc/dnsmasq.conf
sed -i "s/SHAREIF/${sharingif}/" /etc/dnsmasq.conf
dnsmasq -a 192.168.9.1 -C /etc/dnsmasq.conf

# enable access point
echo "starting hostapd .."
cp -f /root/share-network/hostapd.conf /etc/hostapd/hostapd.conf
sed -i "s/SHAREIF/${sharingif}/" /etc/hostapd/hostapd.conf
hostapd -B /etc/hostapd/hostapd.conf

echo "enable ip forwarding .."
iptables -A FORWARD -o "${upstreamif}" -i "${sharingif}" -s 192.168.9.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o "${upstreamif}" -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
