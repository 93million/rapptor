<div align="right"><img src="docs/images/93million_logo.svg" alt="93 Million Ltd. logo" height="36" /></div>
<div align="center"><img src="docs/images/rapptor-logo-3.svg" alt="Rapptor logo" height="270" /></div><br />

# RapptorVPN

## VPN + Remote Apps

RapptorVPN is free software that lets you run a VPN with Remote Apps on generic hosting providers

### Requirements:

- VPS instance running Debian 11 or later
- 1GB RAM
- 15 GB Storage (about 5GB storage space is required for Rapptor + Debian)

### Installation

1. Choose a VPS provider from [rapptorvpn.com/providers](https://rapptorvpn.com/providers/)
2. Make sure the operating system selected is Debian 12 (Debian 11 or later is supported)
3. If asked to provide a domain name when you purchase your hosting, enter any random value as it is not important at this point
4. Purchase the hosting
5. Once the VPS has been created, find the server's IP address. Depending on the provider you purchased it from it may be in the confirmation email that they send you or displayed in their control panel
6. Open a Command Prompt (on Windows) or Terminal (on Mac and Linux) and run the following command:

Windows Command Prompt:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh -o ^"StrictHostKeyChecking accept-new^" root@!IP! curl -s https://raw.githubusercontent.com/93million/rapptor/refs/heads/master/bin/install/debian/install ^| bash"
```

Mac/Linux Terminal:

```
read -p "Enter server IP: " IP && ssh -o "StrictHostKeyChecking accept-new" root@$IP "curl -s https://raw.githubusercontent.com/93million/rapptor/refs/heads/master/bin/install/debian/install | bash"
```

7. When prompted, enter the server's IP address
8. When prompted for your password, enter the root password from the confirmation email or hosting service control panel
9. Follow the link that is outputted when the command completes
10. Choose a domain and create a username and password that you will use to log into Rapptor. If you are not presented with a form to set up the domain and username please wait a few seconds and refresh. It may take 60 seconds before they are available

Follow the link to log in using the user and password you created

VPN functionality is included through the app 'WireGuard Easy VPN' which is installed by default. Use the App Store to install other apps that you may wish to use

### Reset password

If you forgot your password you can set things up again by SSHing into your server using your credentials and running the following command to recreate a setup link so you can reset your password:

```
rapptor setuplink
```

*Copyright 93 Million. All rights reserved*

<br /><div align="center"><img src="docs/images/93million_logo.svg" alt="93 Million Ltd. logo" height="48" /></div>
