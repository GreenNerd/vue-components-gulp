msgQueue = []
Alertify = (options) ->
  if Alertify.instance
    Alertify.instance.update(options)
  else
    msgQueue.push(options)
    if document.getElementById('alert-container')
      alertContainer = document.getElementById('alert-container')
      alertContainer.innerHTML = ''
    else
      alertContainer = document.createElement('div')
      alertContainer.id = 'alert-container'
      document.body.appendChild(alertContainer)
    alert_box = document.createElement('div')
    alertContainer.appendChild(alert_box)
    Alertify.instance = new AlertComponent
      el: alert_box
  document.getElementById('alert-container').querySelector('.alert-box').addEventListener('animationend', ->
    if Alertify.instance
      Alertify.instance.playing = false
  ,false)
  Alertify.instance

AlertComponent = Vue.extend
  template:"""
    <div class='alert-box'
         :class='[{ "alert-open": isShow }, typeClass]'>
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
      document.getElementById('alert-container').querySelector('.alert-box').addEventListener('animationstart', =>
        @_setTime()
      ,false)
      @isShow = true
      @display()

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
      else
        if @playing
          document.getElementById('alert-container').querySelector('.alert-box').addEventListener('animationend', =>
            Alertify(options)
          ,false)

    close: ->
      @isShow = false
      document.getElementById('alert-container').querySelector('.alert-box').addEventListener('animationend', =>
        Alertify.instance = null
      ,false)

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
