module.exports = {
  title: "pimatic-broadlink device config schemas"
  BroadlinkRemote: {
    title: "BroadlinkRemote config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      host:
        description: "the ip address of the broadlink rm"
        type: "string"
      mac:
        description: "the mac address of the broadlink rm"
        type: "string"
      buttons:
        description: "Button for remote control"
        format: "table"
        type: "array"
        default: []
        items:
          type: "object"
          properties:
            id:
              description: "The id of the button"
              type: "string"
            text:
              description: "The friendly name on the button"
              type: "string"
            commandFile:
              description: "The filename of the commandfile"
              type: "string"
      pollingTime:
        description: "time in ms between polling of temperature/humidity sensor (default 5 min)"
        type: "number"
        default: 300000
      deviceType:
        description: "The broadlink device type"
        type: "string"        
      deviceCode:
        description: "The broadlink device type code"
        type: "string"
      port:
        description: "the port number of the broadlink rm"
        type: "number"
        default: 80
      timeout:
        description: "the timeout for the broadlink rm"
        type: "number"
        default: 30
  }
  BroadlinkAmbiant: {
    title: "BroadlinkAmbiant config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      host:
        description: "the ip address of the broadlink rm"
        type: "string"
      mac:
        description: "the mac address of the broadlink rm"
        type: "string"
      sensors:
        description: "Broadlink RM sensors to be added to the gui"
        format: "table"
        type: "array"
        default: []
        items:
          type: "object"
          properties:
            id:
              description: "The name of the sensor as know in Broadlink RM"
              type: "string"
              enum: ["temperature","humidity","illuminance","soundlevel"]
      deviceType:
        description: "The broadlink device type"
        type: "string"        
      deviceCode:
        description: "The broadlink device type code"
        type: "string"
      port:
        description: "the port number of the broadlink rm"
        type: "number"
        default: 80
      timeout:
        description: "the timeout for the broadlink rm"
        type: "number"
        default: 30
  }
}
