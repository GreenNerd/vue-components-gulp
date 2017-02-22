Alertify = (options) ->
  if Alertify.instance
    Alertify.instance.update(options)
  else
    alert_box = document.createElement('div')
    document.body.appendChild(alert_box)
    Alertify.instance = new AlertComponent
      el: alert_box
      data: options
  Alertify.instance

AlertComponent = Vue.extend
  template:"""
    <div class="alert-container" v-if='isShow'>
      <div transition="fade"
           class='alert-box'
           :class='typeClass'>
        {{ content }}
      </div>
    </div>
  """
  data: ->
    content: '提示'
    type: 'success'
    isShow: false
    autoTime: 5000
    showTime: 1500
  created: ->
    @display()
  computed:
    typeClass: () ->
      'alert-' + @type
  methods:
    display: () ->
      @isShow = true
      @setTime()
    setTime: () ->
      @autoClose_timer = setTimeout =>
                          @close()
                        , @autoTime
      @start_time = new Date()
    update: (options) ->
      now_time = new Date()
      play_time = now_time - @start_time
      if play_time < @showTime
        left_time = @showTime - play_time
        setTimeout =>
          @refresh(options)
        , left_time
      else
        @refresh(options)
    refresh: (options = {}) ->
      @content = options.content or '提示'
      @type = options.type or 'success'
      clearTimeout(@autoClose_timer)
      @setTime()
    close: () ->
      @isShow = false
      Alertify.instance = null
    overlay: () ->
      clearTimeout(@autoClose_timer)
      @close()

document.addEventListener('click', () ->
  if Alertify.instance
    Alertify.instance.overlay();
, true)

window.Alertify = Alertify;
