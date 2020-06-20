module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  fs = require 'fs'
  path = require 'path'
  ps = require 'python-shell'

  _ = require('lodash')

  class BroadlinkPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>

      oldClassName = "RemoteDevice"
      newClassName = "BroadlinkRemote"
      for device,i in @framework.config.devices
        className = device.class
        #convert RemoteDevice to BroadlinkRemote
        if className == oldClassName
          @framework.config.devices[i].class = newClassName
          env.logger.debug "Class '#{oldClassName}' of device '#{device.id}' migrated to #{newClassName}"

      pluginConfigDef = require './pimatic-broadlink-config-schema'
      @configProperties = pluginConfigDef.properties

      deviceConfigDef =  require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass('BroadlinkRemote', {
        configDef: deviceConfigDef.BroadlinkRemote,
        createCallback: (config, lastState) => new BroadlinkRemote(config, lastState, @framework, @)
      })

      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-broadlink', 'Searching for new devices'
        discoverOptions =
          mode: 'json'
          pythonPath: 'python3'
          pythonOptions: ['-u']
          scriptPath: __dirname
          args: []
        ps.PythonShell.run('broadlink_discovery.py', discoverOptions, (err, results) =>
          if err
            env.logger.debug("Device discovery error, PythonShell: " + err)
            return
          devices =_.flatten(results)
          env.logger.debug "Discovered devices: "+ JSON.stringify(devices,null,2)
          for _device,i in devices
            unless _device.error?
              _newId = _device.type + "_" + _device.mac.split(":").join("")
              if _.find(@framework.deviceManager.devicesConfig,(d) => d.id.indexOf(_newId)>=0)
                env.logger.info "Device '" + _newId + "' already in config"
              else
                config =
                  id: _newId
                  name: _newId
                  class: "BroadlinkRemote"
                  host: _device.host
                  mac: _device.mac
                  deviceCode: _device.devtype
                  deviceType: _device.type
                @framework.deviceManager.discoveredDevice("Broadlink", config.id, config)
            else
              env.logger.debug "Device discovery error"
        )
      )


  class BroadlinkRemote extends env.devices.ButtonsDevice

    constructor: (@config, lastState, @framework, @plugin) ->
      #@config = config
      super(@config)
      @id = @config.id
      @name = @config.name

      @root = path.resolve @framework.maindir, '../..'
      @directory = path.join(@root,"learned-codes")
      unless fs.existsSync(@directory)
        fs.mkdir(@directory, (err)=>
          if err
            env.logger.debug "Error creating learned-codes directory"
            return
        )
      @host = @config.host
      @mac = (@config.mac).split(":").join("")
      @deviceType = @config.deviceType
      @deviceCode = @config.deviceCode
      @_device = @deviceCode + " " + @host + " " + @mac

      @_destroyed = false

      newFound = 0
      newButton = {}
      for b in @config.buttons
        unless fs.existsSync(path.join(@directory,b.commandFile))
          newButton = b
          newFound +=1
      if newFound is 1
        env.logger.info "Command unknown, going into learnmode, please press key '#{newButton.commandFile}' on remote..."
        @learn(newButton.commandFile)
        .then(()=>
          env.logger.info "New command '#{newButton.commandFile}' learned and saved"
        ).catch((err)=>
          env.logger.info "Command '#{newButton.commandFile}' unknown, please learn other way " + err
        )
      if newFound > 1
        throw new Error("Detected #{newFound} new buttons, only 1 new button at a time can be added!")

    learn:(_name)=>
      return new Promise((resolve,reject) =>
        sendOptions =
          mode: 'text',
          pythonPath: 'python3'
          pythonOptions: ['-u'] # get print results in real-time
          scriptPath: __dirname
          args: ['--device',@_device,'--learnfile',path.join(@directory,_name)]
        pyshell = new ps.PythonShell('broadlink_cli.py', sendOptions)
        pyshell.on 'message', (message) =>
          env.logger.debug "Message: " + message
        pyshell.end((err,code,signal) =>
          if err
            env.logger.debug "Error handled: " + err
            reject(err)
          resolve();
        )
      )


    getButton: -> Promise.resolve(@_lastPressedButton)

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          command = b.onPress
          commandFile = path.join("@"+@directory,b.commandFile)
          sendOptions =
            mode: 'text'
            pythonPath: 'python3'
            scriptPath: __dirname
            args: ['--device',@_device,'--send',commandFile]

          if not @_destroyed
            return ps.PythonShell.run('broadlink_cli.py', sendOptions, (err) =>
              if err
                env.logger.debug "Error sending command: " + err
                #Promise.reject err
                return
              env.logger.debug "Command sent"
            )
          else
            return Promise.resolve()
      throw new Error("No button with the id #{buttonId} found")

    destroy:() =>
      @_destroyed = true
      super()


  plugin = new BroadlinkPlugin
  return plugin
