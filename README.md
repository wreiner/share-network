# share-network

Share a network connection through Wifi.

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

