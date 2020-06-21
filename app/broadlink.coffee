
merge = Array.prototype.concat

$(document).on 'templateinit', (event) ->

  class BroadlinRemoteItem extends pimatic.DeviceItem

    constructor: (templData, @device) ->
      super(templData, @device)
      @buttonAttr = @getAttribute('button')
      @buttonId = ko.observable()


      if @getConfig('enableActiveButton')
        @buttonId(@buttonAttr.value())
      else
        @buttonId("null")

      @buttonAttr.value.subscribe((value) =>
        enableActiveButton = @getConfig('enableActiveButton')
        if value? and enableActiveButton
          @buttonId(value)
        else
          @buttonId("null")
      )

    getItemTemplate: => 'broadlink-remote'

    onButtonPress: (button) =>
      doIt = (
        if button.confirm then confirm __("
          Do you really want to press \"%s\"?
        ", button.text)
        else yes
      ) 
      if doIt
        @device.rest.buttonPressed({buttonId: button.id}, global: no)
          .done(ajaxShowToast)
          .fail(ajaxAlertFail)

  pimatic.templateClasses['broadlink-remote'] = BroadlinRemoteItem
