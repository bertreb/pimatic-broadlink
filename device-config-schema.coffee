module.exports = {
  title: "pimatic-broadlink device config schemas"
  RemoteDevice: {
    title: "Broadlink config options"
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
            commandString:
              description: "The commandstring"
              type: "string"
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
