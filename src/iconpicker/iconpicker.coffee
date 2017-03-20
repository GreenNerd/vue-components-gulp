createModalContainer = (modalId) ->
  if document.getElementById(modalId)
    modalContainer = document.getElementById(modalId)
    modalContainer.innerHTML = ''
  else
    modalContainer = document.createElement('div')
    modalContainer.id = modalId
    document.body.appendChild(modalContainer)

  modalDiv = document.createElement('div')
  modalContainer.appendChild(modalDiv)
  modalDiv

iconpicker = Vue.extend
  template: """
    <div class="iconPicker" :style="{ width: widthPercent }">
      <div class="icon-list" v-for="(iconList, index) in icon_list">
        <div v-for="(iconItem, track) in iconList"
             class="icon-cell"
             @click="iconSelect(index, track)">
          <i class="fa"
             :class="'fa-' + iconItem.icon"
             :style="_setColor(iconItem)"
             ></i>
        </div>
      </div>
    </div>
  """

  props:
    activeColor:
      type: String
      default: '#fd84c3'

    selectedIcon:
      type: String
      default: 'bath'

    ICON_LIST:
      default: ['address-book', 'address-book-o', 'address-card', 'address-card-o', 'bandcamp', 'bath', 'eercast', 'envelope-open', 'etsy', 'free-code-camp', 'grav', 'handshake-o', 'id-card', 'imdb', 'linode', 'meetup', 'podcast', 'quora']

  created: ->
    @_getIconRange()

  computed:
    allpages: ->
      Math.ceil(@ICON_LIST.length / @per_page)

    widthPercent: ->
      @allpages * 100 + '%'

  data: ->
    per_page: 15
    icon_list: []

  methods:
    searchIcon: (icon) ->
      for i in [0..@ICON_LIST.length]
        if @ICON_LIST[i] is icon
          currpage = Math.ceil i / @per_page
          @$emit('initPage', currpage)

    _setColor: (item) ->
      if item.icon is @selectedIcon
        'color': @activeColor

    iconSelect: (i, j) ->
      if @selectedIcon is @ICON_LIST[i * @per_page + j]
        @selectedIcon = ''
      else
        @selectedIcon = @ICON_LIST[i * @per_page + j]
      @$emit('iconChanged', @selectedIcon)

    _getIconRange: ->
      #总的渲染list
      if @allpages is 1
        @icon_list[0] = []
        for i in [0..@ICON_LIST.length]
          @icon_list[0].push({
            icon: @ICON_LIST[i]
          })
      else
        for k in [1..@allpages]
          startIcon = 0 + (k - 1) * @per_page
          if k != @allpages
            endIcon = 14 + (k - 1) * @per_page
          else
            endIcon = 14 + @ICON_LIST.length - (k - 1) * @per_page
          @icon_list[k-1] = []
          for i in [startIcon..endIcon]
            @icon_list[k-1].push({
              icon: @ICON_LIST[i]
            })

selection = Vue.extend
  template: """
    <div class="modal modal-position-bottom"
         :class="{ 'modal-open': displayModal }"
         @click="_toggleDisplay(event)">
        <div class="modal-content">
          <div class="selection-ctrl">
            <span class="cancel-select" @click="close">取消</span>
            <span class="ensure-select" @click="submit">确认</span>
          </div>
          <slot class="selection-content" name="content"></slot>
        </div>
    </div>
  """

  data: ->
    displayModal: true

  methods:
    submit: ->
      @$emit 'submit'
      @close()

    close: ->
      @displayModal = false
      iconPicker.instance = null

    _toggleDisplay: (e) ->
      @close() if e.target.classList.contains('modal')

colorpicker = Vue.extend
  template: """
    <div class="colorPicker">
      <div class="color-list">
        <div v-for="colorItem in COLOR_LIST"
             class="color-cell"
             :class="{ 'color-active-item': colorItem == selectedColor }">
          <span :style="{ 'background-color': colorItem }"
                @click="colorSelect(colorItem)">
            <i class="fa fa-check"></i>
          </span>
        </div>
      </div>
    </div>
  """

  props:
    selectedColor:
      type: String

    COLOR_LIST:
      default: ['#fd84c3', '#fd3f76', '#eb6d7a', '#da5842', '#fb8f47', '#feb345', '#aed59c', '#2cac6f', '#2bd2c8', '#82cff3', '#3e9bd9', '#8c95f8', '#8257c3', '#8e99ca']

  methods:
    colorSelect: (color) ->
      if @selectedColor != color
        @selectedColor = color
      else
        @selectedColor = ''
      @$emit 'colorChanged', @selectedColor

swiper = Vue.extend
  template: """
    <div class="swiper"
         @touchstart="_onTouchStart"
         @touchmove="_onTouchMove"
         @touchend="_onTouchEnd">
      <div class="swiper-wrap"
           ref="swiperWrap"
           :class="{ 'duration': transition }"
           :style="{ 'transform': 'translate3d(' + translateX + 'px, 0, 0)' }">
        <slot></slot>
      </div>
      <div class="swiper-pagination">
        <span class="swiper-pagination-bullet"
              v-for="(slide, index) in slideEls"
              @click="setPage(index)"
              :class="{ 'active': index == currpage - 1 }"
              ></span>
      </div>
    </div>
  """

  props:
    minDstce:
      type: Number
      default: 100

  mounted: ->
    @slideEls = @$refs.swiperWrap.children[0].children
    @clientWidth = @$el.clientWidth

  data: ->
    startPosition: null
    slideEls: []
    clientWidth: ''
    translateX: 0
    delta: 0
    currpage: 1
    startTranslate: 0
    transition: false

  methods:
    setPage: (page) ->
      @currpage = parseInt(page) + 1
      @translateX = - ((@currpage - 1) * @clientWidth)

    _onTouchStart: (e) ->
      @startPosition = e.changedTouches[0].pageX
      @startTranslate = @translateX
      @transition = false

    _onTouchMove: (e) ->
      @delta = e.changedTouches[0].pageX - @startPosition
      @translateX = @startTranslate + @delta

      if Math.abs(@delta) > 0
        e.preventDefault()

    _onTouchEnd: ->
      @transition = true
      if @delta > 0 #右滑 page-1
        if Math.abs(@delta) > @minDstce
          if @currpage != 1
            @currpage = @currpage - 1
            @translateX = @startTranslate + @clientWidth
          else
            @translateX = @startTranslate
        else
          @translateX = @startTranslate

      else #左滑 page+1
        if Math.abs(@delta) > @minDstce
          if @currpage != @slideEls.length
            @currpage = @currpage + 1
            @translateX = @startTranslate - @clientWidth
          else
            @translateX = @startTranslate
        else
          @translateX = @startTranslate

iconpickerSelection = Vue.extend
  template: """
    <selection v-on:submit="submitIcon">
      <div class="fontIconPicker" slot="content">
        <colorpicker :selectedColor=iconColor
                     v-on:colorChanged="updateIconColor">
        </colorpicker>
        <swiper ref="swiper">
          <iconpicker ref="icon-picker"
                      :activeColor=iconColor
                      :selectedIcon=fontIcon
                      v-on:iconChanged="updateIcon"
                      v-on:initPage="setPage"></iconpicker>
        </swiper>
      </div>
    </selection>
  """

  components:
    'selection': selection
    'colorpicker': colorpicker
    'swiper': swiper
    'iconpicker': iconpicker

  mounted: ->
    @$refs["icon-picker"].searchIcon(@fontIcon)

  methods:
    updateIconColor: (newColor) ->
      @iconColor = newColor

    updateIcon: (newIcon) ->
      @fontIcon = newIcon

    setPage: (page) ->
      @$refs.swiper.setPage(page - 1)

    submitIcon: ->
      console.log @iconColor, @fontIcon

iconPicker = (icon = 'quora', color = '#fd84c3') ->
  iconPicker.instance = new iconpickerSelection
    el: createModalContainer('modal-container')

    data:
      fontIcon: icon
      iconColor: color

  iconPicker.instance

window.iconpicker = iconPicker
