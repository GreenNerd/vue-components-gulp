msgQueue = []
createAlertContainer = (AlertifyId) ->
  if document.getElementById(AlertifyId)
    alertContainer = document.getElementById(AlertifyId)
    alertContainer.innerHTML = ''
  else
    alertContainer = document.createElement('div')
    alertContainer.id = AlertifyId
    document.body.appendChild(alertContainer)
  alertContainer

Alertify = (options) ->
  if Alertify.instance
    Alertify.instance.update(options)
  else
    msgQueue.push(options)
    alertContainer = createAlertContainer('alert-container')
    alert_box = document.createElement('div')
    alertContainer.appendChild(alert_box)
    Alertify.instance = new AlertComponent
      el: alert_box

  Alertify.instance

AlertComponent = Vue.extend
  template:"""
    <div class='alert-box'
         :class='[{ "alert-open": isShow }, typeClass]'
         v-on:animationend="playEnd">
        {{ content }}
    </div>
  """

  data: ->
    content: '提示'
    type: 'success'
    isShow: false
    autoTime: 5000
    showTime: 1500
    playing: false

  mounted: ->
    @beforeAnimation()

  computed:
    typeClass: ->
      'alert-' + @type

  watch:
    isShow: ->
      @playing = true

  methods:
    beforeAnimation: ->
      @isShow = true
      @_setTime()
      @display()

    playEnd: ->
      @playing = false
      if !@isShow
        Alertify.instance = null
        if msgQueue.length > 0
          window.Alertify(msgQueue.shift())

    display: ->
      message = msgQueue.shift() or {}
      @content = message.content or '提示'
      @type = message.type or 'success'

    _setTime: ->
      @start_time = new Date()
      @show_timer = setTimeout =>
                      @check()
                    , @showTime
      clearTimeout(@autoClose_timer)
      @autoClose_timer = setTimeout =>
                          @close()
                        , @autoTime
    check: ->
      if msgQueue.length > 0
        @_setTime()
        @display()

    update: (options = {}) ->
      msgQueue.push(options)
      if @isShow
        if new Date() - @start_time > @showTime
          @_setTime()
          @display()

    close: ->
      @isShow = false

    forcedClose: () ->
      clearTimeout(@show_timer)
      clearTimeout(@autoClose_timer)
      @close()

document.body.addEventListener('click', (event)->
  if Alertify.instance && Alertify.instance.playing
    event.stopPropagation()
, false)

document.body.addEventListener('click', ->
  if Alertify.instance && !Alertify.instance.playing
    Alertify.instance.forcedClose();
, true)

window.Alertify = Alertify;
