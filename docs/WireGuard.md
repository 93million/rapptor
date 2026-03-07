# Setting up a WireGuard VPN

WireGuard is a VPN technology that offers clients on Windows, Mac and Linux on the desktop, iOS and Android on mobile and many other platforms including Apple’s tvOS and Google’s Android TV OS.

## Install the WireGuard app

You will need to install WireGuard on teh device you plan to connect to the VPN. Clients for many platforms can be found at https://www.wireguard.com/install/. If you have an Android TV, WireGuard may be available in the App Store.

## Create a WireGuard client

Open the ‘WireGuard Easy VPN’ app on Rapptor and find the section labelled `Clients`. Click on the button labeled `+ New` and enter a name, then click `Create`.

<SS ‘+ New’ icon>

## Connect from WireGuard

### Adding the VPN connection on Mac or Windows

Steps:

- In a web browser on your device, navigate to your Rapptor instance and open the app `WireGuard Easy VPN`
- Next to the client you created, click the download icon to download the configuration to your device.
- Open the WireGuard App. On Mac, if no windows appears then you might need to select `Manage Tunnels` from the WireGuard menu bar.
- On Mac, click the plus icon in the bottom left and select `Import Tunnel(s) from File`.
- On Windows, click the button `Add Tunnel`.
- Choose the configuration file you downloaded.

### Adding VPN connection on iOS or Android

Steps:

- In a web browser on your device, navigate to your Rapptor instance and open the app ‘WireGuard Easy VPN’.
- Next to the client you created, tap the download icon to download the configuration to your device.
- Open the WireGuard App on your device.
- Tap the plus icon.
- Select ‘Import from file or archive’ (on Android) or `Create from file or archive` (on iOS).
- Choose the configuration file you downloaded.

Now the connection is added to WireGuard, you can connect by clicking the button ‘Activate’ (in Windows/Mac) or activating the toggle in iOS/Android.

In Windows you can quickly connect to your VPN from the WireGuard icon in the system tray in the taskbar at the bottom right of the screen. In Mac you can connect using the WireGuard menu bar icon in the right of the menu bar at the top right of the screen.
