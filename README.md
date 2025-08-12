# RapptorVPN

## VPN + Remote Apps

RapptorVPN is free software that lets you run a VPN with Remote Apps on generic hosting providers

### Requirements:

- VPS instance running Debian 11 or later
- 1GB RAM
- 15 GB Storage

### Installation

1. Choose a VPS provider from [rapptorvpn.com/providers](https://rapptorvpn.com/providers/)
2. In the text field labeled 'root password', enter a password and remember it for use later
3. In the dropdown 'operating system' choose Debian 12 (or Debian 11 or higher)
4. Purchase the hosting
5. Once the VPS has been created, find the server's IP address. Depending on the provider you purchased it from it may be in the confirmation email that they send you or displayed in their control panel
6. Open a Command Prompt (on Windows) or Terminal (on Mac and Linux) and run the following command (replacing `<ip>` with the IP address):

```
read -p "Enter server IP: " IP && ssh -o "StrictHostKeyChecking accept-new" root@$IP "curl -s https://gitlab.93m.org/api/v4/projects/37/repository/files/bin%2Finstall%2Fdebian%2Finstall/raw | bash"
```

7. When prompted, enter the server's IP address
8. When prompted for your password, enter the root password you chose on step 2
9. Follow the link that is outputted when the command completes
10. Choose a domain and create a username and password that you will use to log into Rapptor. If you are not presented with a form to set up the domain and username please wait a few seconds and refresh. It may take 60 seconds before they are available
