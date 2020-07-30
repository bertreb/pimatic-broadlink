# pimatic-broadlink
Plugin for using Broadlink products in Pimatic. The plugin is based on the python-broadlink library from [mjg59](https://github.com/mjg59/python-broadlink)

The following devices are currently supported:
- RM Pro (referred to as RM2 in the codebase)
- A1 sensor platform devices
- RM3 mini IR blaster
- RM4 and RM4C mini blasters


Installation
----
- Python3 needs to be installed.
- Install the python library broadlink.

In commandline mode:
```
pip3 install broadlink
```
- Install the plugin
The plugin can be installed via the gui or adding it to the config.json.

- Configure the wifi of the broadlink device via the Broadlink app (easy but you will need to connect to the broadlink cloud) or use the following steps:
1. Put the broadlink device into AP Mode = Long press (>10 secs) the reset button until the blue LED is blinking quickly.
2. Long press again until blue LED is blinking slowly.
3. Manually connect to the WiFi SSID named BroadlinkProv (or Broadlink_WIFI_device).
4. In commandline mode go to /pimatic-app/node_modules/pimatic-broadlink and run
```
python3 broadlink_cli.py --joinwifi SSID PASSPHRASE
```
No quotes around SSID and PASSPHRASE and your wifi security needs to be WPA.
The broadlink device should now connect to the configured wifi. You can reconnect to the normal network.


If you don't want to change your pimatic system wifi settings, you can use another system to configure the broadlink wifi. These are the steps:
1. You need to have python3 and broadlink installed.
2. Copy from the plugin directory the python script **broadlink_cli.py** to the directory you want to use for executing the script.
3. Follow the steps above, but run the command (sudo python3 broadlink_cli.py...) from your chosen directory.
The broadlink device should now connect to the configured wifi. You can reconnect to the normal network.

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

The commandfiles are saved in the directory \<pimatic home directory\>/learned-codes. Commandfiles can also be added manually. They need to contain the commandString (used by the python-broadlink lib). There is 1 commandFile per command. For the filename you can use something like 'TV.onoff'. The directory is automatically created (if not exsist) and on upgrading or reinstalling of the plugin, the directory will be kept.

You can add 1 new -to be learned- button at a time.

Sensor attributeValues
----
The RM device can also provides sensor data like temperature or humidity. In the device config you can add sensors. The value name should be available in the RM. When configured sensor data is received it will be displayed in the gui.
The sensors are read via polling, you can set the polling interval via pollingTime in the config.


Rules
----
You can control the buttons via rules. The syntax is:
```
remote press <broadlink rm button name>
```

---
The minimum requirement for node is 10.

You could backup Pimatic before you are using this plugin!
