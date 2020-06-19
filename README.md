# pimatic-broadlink
Plugin for using Broadlink products in Pimatic

Installation of the plugin
----

Before installation of this plugin the python library broadlink needs to be installed.

Use:
```
sudu pip3 install broadlink
```
The next step is the installation of the plugin pimatic-broadlink. It can be installed via the gui or adding it to the config.json.

This plugin contains a discovery function for broadlink devices and a RemoteDevice for remote controlling TV's, etc, via a broadlink device.  

Adding the RemoteDevice
----
The RemoteDevice is added via the discovery function. This is needed to get the ip and mac address and the device code.
After adding the RemoteDevice to the gui, buttons can be added.
Per button a remote control function can be defined.
configuration per button:
- id: the pimatic id of the button
- text: the text used on the button in the gui
- commandFile: the name of the commandFile (no directory path!)

Per command a commandfile is used. This commandfile contains the codestring send to the device (TV, etc)
The commandfile is automatically created when adding a new button and the file does not exsist.
After adding a new button and saving the device config, the learning mode is started and you need to push button on your remote to learn the command.
