# pimatic-broadlink
Plugin for using Broadlink products in Pimatic. The plugin is based on the python-broadlink library from [mjg59](https://github.com/mjg59/python-broadlink)


Installation of the plugin
----

Before installation of this plugin the python library broadlink needs to be installed.

Use:
```
sudu pip3 install broadlink
```
The next step is the installation of the plugin pimatic-broadlink. It can be installed via the gui or adding it to the config.json.

This plugin contains a discovery function for broadlink devices and a RemoteDevice for remote controlling TV's, etc, via a broadlink device.  

Adding the BroadlinkRemote device
----
The BroadlinkRemote device is added via the discovery function. This is needed to get the ip and mac address and the device code.
After adding the BroadlinkRemote to the gui, buttons can be added.
Per button a remote control function can be defined.
Configuration per button:
- id: the pimatic id of the button
- text: the text used on the button in the gui
- commandFile: the filename of the commandFile (no directory path!)

Per command a commandfile is used. This commandfile contains the codestring send to the device (TV, etc)
The commandfile is automatically created when adding a new button and the file does not exsist.
After adding a new button and saving the device config, the learning mode is started and you need to push button on your remote to learn the command.

The commandfiles are saved in the directory \<pimatic home directory\>/learned-codes. Commandfiles can be added manually. They need to contain the commandString (used by the python-broadlink lib). There is 1 commandFile per command. For the filename you can use something like 'TV.onoff'. The directory is automatically created (if not exsist) and on upgrading or reinstalling of the plugin, the directory will be kept.

You can add 1 new -to be learned- button at a time.

---
The minimum requirement for node is 10.

You could backup Pimatic before you are using this plugin!
