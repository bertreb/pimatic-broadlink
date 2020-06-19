module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  fs = require 'fs'
  path = require 'path'
  ps = require 'python-shell'

  _ = require('lodash')

  class RemotePlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>

      pluginConfigDef = require './pimatic-broadlink-config-schema'
      @configProperties = pluginConfigDef.properties

      deviceConfigDef =  require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass('RemoteDevice', {
        configDef: deviceConfigDef.RemoteDevice,
        createCallback: (config, lastState) => new RemoteDevice(config, lastState, @framework, @)
      })

      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-broadlink', 'Searching for new devices'
        wrappy.discover()
        .then((devs)=>
          devices =_.flatten(devs)
          for _device,i in devices
            _newId = _device.type + "_" + _device.mac.split(":").join("")
            if _.find(@framework.deviceManager.devicesConfig,(d) => d.id.indexOf(_newId)>=0)
              env.logger.info "Device '" + _newId + "' already in config"
            else
              env.logger.info "Device: " + JSON.stringify(_device,null,2)
              config =
                id: _newId
                name: _newId
                class: "RemoteDevice"
                host: _device.host
                mac: _device.mac
                deviceCode: _device.devtype
                deviceType: _device.type
              @framework.deviceManager.discoveredDevice("Broadlink", config.id, config)
        )
      )


  class RemoteDevice extends env.devices.ButtonsDevice

    constructor: (@config, lastState, @framework, @plugin) ->
      #@config = config
      super(@config)
      #@id = @config.id
      #@name = @config.name

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


      #super()
      for b in @config.buttons
        unless fs.existsSync(path.join(@directory,b.commandString))
          env.logger.info "Command unknown, going into learnmode, please press key '#{b.commandString}' on remote..."
          @learn(b.commandString)
          .then(()=>
            env.logger.info "New command '#{b.commandString}' learned and saved"
          ).catch((err)=>
            env.logger.info "Command '#{b.commandString}' unknown, please learn other way " + err
          )

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
          commandFile = path.join("@"+@directory,b.commandString)
          env.logger.info "commandFile: " + commandFile
          sendOptions =
            mode: 'text'
            pythonPath: 'python3'
            scriptPath: __dirname
            args: ['--device',@_device,'--send',commandFile]
          
          if not @_destroyed
            return ps.PythonShell.run('broadlink_cli.py', sendOptions, (err) =>
              if err
                env.logger.debug "Error sending command: " + err
                Promise.reject err
              env.logger.debug "Command sent"
            )
          else
            return Promise.resolve()
      throw new Error("No button with the id #{buttonId} found")

    destroy:() =>
      @_destroyed = true
      super()


  plugin = new RemotePlugin
  return plugin
