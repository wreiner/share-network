# share-network

Share a network connection through Wifi.

## Usage

1. Set SSID and WPA PSK in hostapd.conf
1. Run share-network.sh

## Unmanage device by NetworkManager

Add the device to /etc/NetworkManager/conf.d/unmanaged.conf:

```
[keyfile]
unmanaged-devices=interface-name:wlp3s0
```

Reload NetworkManager:

```
systemctl reload NetworkManager
```

Device should now be unmanaged:

```
# nmcli d
DEVICE             TYPE      STATE         CONNECTION
...
wlp3s0             wifi      unmanaged     --
```

*Note:*

I'm using an Edimax nano USB Wifi Adapter as the second interface:

```
[ 2038.989621] usb 2-2: Product: 802.11n WLAN Adapter
[ 2038.989625] usb 2-2: Manufacturer: Realtek
```

I cannot get hostapd to work with this interface so I usually use the Wifi
interface of my notebook as the sharing interface.

## DKMS Driver (not sure if it works)

For the USB devices it could be mandatory to use a non standard driver - rtl88xxau-aircrack-dkms-git instead of rtl8192cu.

Disable rtl8192cu by editing /etc/modprobe.d/blacklist-usbwifi.conf:

```
blacklist rtl8192cu
```

Unplug device and remove module:

```
modprobe -r rtl8192cu
```

Install rtl88xxau-aircrack-dkms-git:

```
yay -S rtl88xxau-aircrack-dkms-git
```

Further information [here](https://bogeskov.dk/UsbAccessPoint.html).

