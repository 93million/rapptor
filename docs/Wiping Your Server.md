# Wiping your server

There are several ways to wipe everything. You can wipe your hosting instance through your hosting provider's control panel, or you can delete everything on your server through the command line. There is a wipe script for this purpose.

## Wipe script

The wipe script will do the following:

- Shutdown Rapptor on your server
- Delete Docker volumes used to store Rapptor data
- Remove all Docker volumes that are not used by at least one container
- Delete the Rapptor codebase

Packages installed to support Rapptor (Docker, etc.) will not be removed.

You can run the script to wipe Rapptor from your server by running the following command (depending on your operating system):

Windows Command Prompt:

- Press the Windows key + R - Enter the text ‘cmd’ and press enter to open the command line
- Enter the following command:

```
cmd /V:ON /C "set /p IP=Enter server IP: & ssh root@!IP! /var/docker/rapptor/bin/wipe"
```

Mac/Linux Terminal:

- Open the ‘Terminal’ app
- Enter the following command:

```
read -p "Enter server IP: " IP && ssh root@$IP "/var/docker/rapptor/bin/wipe"
```

Rapptor can be reinstalled by running the [install command](../README.md#installation).

## Wipe through your hosting provider

You can wipe your instance by logging into your hosting provider and reinstalling Debian. To do this log into your hosting provider with the username and password you created when you signed up and look for the option to reinstall the OS. Choose Debian 11 or later if you want to use it with Rapptor at a later date.
