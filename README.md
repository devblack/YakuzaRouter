# YakuzaRouter
 A simple bash script to automate the process of running openvpn.

![](https://i.imgur.com/IPqz3hO.png)

# Requirements
  * OpenVPN

# Before run
  * Edit your .ovpn file to login automatically
    ```
    # After "remote ....." line
    remote us1.freeopenvpn.org 10558 udp
    auth-user-pass /EXAMPLE_DIR/pass
    # you can see a pass example in EXAMPLE_DIR
    ```
  * Edit your .ovpn file to prevent dns leak
    ```
    #At the end of everything, paste this:
    script-security 2
    up /etc/openvpn/update-systemd-resolved
    down /etc/openvpn/update-systemd-resolved
    dhcp-option DOMAIN-ROUTE .
    # you can see a example in EXAMPLE_DIR
    ```
# Suggestion
  When you use the command dir, always enter the full patch of your dir, example: /home/myuser/Desktop/configs/

# Installation

### Install source from GitHub
To install the source code:

    $ git clone https://github.com/devblack/YakuzaRouter.git

### Install source from zip/tarball
Alternatively, you can fetch a [tarball][] or [zipball][]:

    $ curl -L https://github.com/devblack/YakuzaRouter/tarball/master | tar xzv
    (or)
    $ wget https://github.com/devblack/YakuzaRouter/tarball/master -O - | tar xzv

[tarball]: https://github.com/devblack/YakuzaRouter/tarball/master
[zipball]: https://github.com/devblack/YakuzaRouter/zipball/master

# Usage
```
sudo ./Yakuza.sh
```