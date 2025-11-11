<div align="right">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/93million_logo-dark.svg" height="36" />
    <img src="docs/images/93million_logo-light.svg" alt="93 Million Ltd. logo" height="36" />
  </picture>
</div>
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/rapptor-logo-3-dark.svg" height="270" />
    <img src="docs/images/rapptor-logo-3-light.svg" alt="Rapptor logo" height="270" />
  </picture>
</div><br />

# RapptorVPN

## VPN + Remote Apps

Rapptor is a platform that provides a VPN service + apps. It can be installed through a single command onto DMCA ignored virtual private servers (VPS) in offshore locations

It comes with the following apps:

- WireGuard Easy - a WireGuard based VPN server
- Transmission - a BitTorrent server
- Plex - a video streaming server
- Jellyfin - an open source video streaming server
- OwnCloud - a Dropbox alternative
- Nextcloud - an open source Dropbox alternative

Apps are configured to work together without requiring additional configuration

It is tested against several VPS providers who offer DMCA ignored services in countries such as Switzerland, Netherlands and Moldova

### Requirements:

- VPS instance running Debian 11 or later
- 1GB RAM
- 15 GB Storage (about 5GB storage space is required for Rapptor + Debian)

### Installation

1. Choose a VPS (virtual private server) provider from [rapptorvpn.com/get](https://rapptorvpn.com/get/)
2. Make sure the operating system selected is Debian 12 (Debian 11 or later is supported)
3. If asked to provide a domain name when you purchase your hosting, enter any random value as it is not important at this point
4. Purchase the hosting (payment via crypto is accepted in most cases)
5. Once the VPS has been created, find the server's IP address. Depending on the provider you purchased it from it may be in the confirmation email that they send you or displayed in their control panel
6. Run the following command (depending on your operating system) to install Rapptor on your VPS:

Windows Command Prompt:

- Press the Windows key + R - Enter the text ‘cmd’ and press enter to open the command line
- Enter the following command:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh -o ^"StrictHostKeyChecking accept-new^" root@!IP! curl -s https://raw.githubusercontent.com/93million/rapptor/refs/heads/master/bin/install/debian/install ^| bash"
```

Mac/Linux Terminal:

- Open the ‘Terminal’ app
- Enter the following command:

```
read -p "Enter server IP: " IP && ssh -o "StrictHostKeyChecking accept-new" root@$IP "curl -s https://raw.githubusercontent.com/93million/rapptor/refs/heads/master/bin/install/debian/install | bash"
```

7. When prompted, enter the server's IP address (from the confirmation email after purchasing, or the hosting service control panel)
8. When prompted, enter the root password (from the confirmation email or control panel)
9. Follow the link that is outputted when the command completes
10. Choose a domain and create a username and password that you will use to log into Rapptor. If you are not presented with a form to set up the domain and username please wait a few seconds and refresh. It may take 60 seconds before it is available

Follow the link to log in using the user and password you created

VPN functionality is included through the app 'WireGuard Easy VPN' which is installed by default. Use the App Store to install other apps that you may wish to use

### Reset password

If you forgot your Rapptor password you can set Rapptor up again by running the following command and following the setup link:

Windows Command Prompt:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh root@!IP! rapptor setuplink"
```

Mac/Linux Terminal:


```
read -p "Enter server IP: " IP && ssh root@$IP "rapptor setuplink"
```

### Find Rapptor URL

If you forgot the domain you chose to access Rapptor you can find it by running the following command:

Windows Command Prompt:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh root@!IP! rapptor geturl"
```

Mac/Linux Terminal:


```
read -p "Enter server IP: " IP && ssh root@$IP "rapptor geturl"
```

### Restart Rapptor

You can restart Rapptor by running the following command:

Windows Command Prompt:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh root@!IP! rapptor restart"
```

Mac/Linux Terminal:


```
read -p "Enter server IP: " IP && ssh root@$IP "rapptor restart"
```

### Reboot server

You can restart your server by running the following command:

Windows Command Prompt:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh root@!IP! reboot"
```

Mac/Linux Terminal:


```
read -p "Enter server IP: " IP && ssh root@$IP reboot
```


*Copyright 93 Million. All rights reserved*

<br />
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/93million_logo-dark.svg" height="48" />
    <img src="docs/images/93million_logo-light.svg" alt="93 Million Ltd. logo" height="48" />
  </picture>
</p>
