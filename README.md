## Repo for the paper "USB Devices phoning home"

####*WARNING:* Some Files are still missing. This will be fixed ASAP (few days at most).

### Setup

General information about our armory setup

#### Misc

* add _sudo_ group
* uncomment _sudo_ group line (visudo)
* add users with groups, add users to _sudo_ group

#### Network

* Default config in `/etc/systemd/network/gadget-deadbeef.network`
* Changed default IP to `10.1.1.1` and gateway to `10.1.1.2`
* Host-Script to NAT network traffic for the armory:

    ```bash
    #!/bin/bash
    /sbin/ip l s usb0 up
    /sbin/ip addr add 10.1.1.2/24 dev usb0
    /sbin/iptables -t nat -A POSTROUTING -s 10.1.1.1/32 -o wlan0 -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```

#### Installed Packages

* dnsmasq
* inotify-tools
* vim 
* base-devel
* screen
* tmux
* wget
* go:

    ```console
    # cd /opt
    # git clone https://go.googlesource.com/go
    # cd go
    # git checkout go1.4.2
    # cd src
    # ./all.bash
    ```
    
    * The file `file_test.go` had to be deleted from `src/net` as the test failed (see [source](https://github.com/golang/go/issues/10730))
    * Add Go env settings to `/etc/profile`

        ```console
        GOROOT=/opt/go
        export GOROOT
        GOPATH=$HOME/go
        export GOPATH

        PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:$GOROOT/bin"
        export PATH
        ```

#### USB Gadget

Switched from g_cdc to g_multi because it includes g_mass_storage.
Using the PID and VID of a SAMSUNG N7000 to make Windows 8 load the necessary drivers.

```console
# cd /etc/modprobe.d/
# echo 'options g_multi dev_addr=de:ad:be:ef:00:01 iManufacturer="Android" idVendor=0x04e8 idProduct=0x6864 file="/root/pendrive.img"' > gadget-deadbeef_multi.conf
# dd if=/dev/zero bs=1M count=128 of=/root/pendrive.img
# use fdisk to create one partition in pendrive.img
# and use mkfs.vat -F 32 to give it a FAT32 filesystem
# cd /etc/modules-load.d/
# mv gadget-deadbeef.conf gadget-deadbeef.off
# echo 'g_multi' > gadget-deadbeef_multi.conf
```

Rebuild g_multi without ecm cdc support for better windows compatibility:

```console
svn co https://github.com/archlinuxarm/PKGBUILDs/trunk/core/linux-armv7
make oldconfig && make prepare
make scripts
make menuconfig # enable usb gadget drivers and enable only rndis for g_multi
make -C /full/path/linux-armv7/src/linux-4.1/ M=/full/path/linux-armv7/src/linux-4.1/drivers/usb/gadget/legacy/
cp linux-armv7/src/linux-4.1/drivers/usb/gadget/legacy/g_multi.ko /lib/modules/$(uname -r)/kernel/drivers/usb/gadget/
sudo depmod -a
```

#### Services

* Copy [imgwatch.sh and filecp.sh](https://gitlab.sva.tuhh.de/svars/usb-armory/tree/master) to /opt
* Copy [godns](https://gitlab.sva.tuhh.de/safs1103/usb-paper-godns/tree/master) to /opt/godns/
* Copy [webchan](https://gitlab.sva.tuhh.de/safs1103/webchan/tree/master) to /opt/webchan/
* Deploy the [systemd.service files](https://gitlab.sva.tuhh.de/svars/usb-armory/tree/master/systemd_services) in `/etc/systemd/system/multi-user.target.wants`

Enable them by running:
```console
# systemctl daemon-reload
```

* Copy the [dnsmasq config](https://gitlab.sva.tuhh.de/svars/usb-armory/blob/master/config_files/dnsmasq.conf) to /etc/dnsmasq.conf
