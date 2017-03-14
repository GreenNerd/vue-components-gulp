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
      <div class="icon-list" v-for="iconList in icon_list">
        <div v-for="(iconItem, index) in iconList"
             class="icon-cell"
             @click="iconSelect(index)">
          <i class="fa"
             :class="'fa-' + iconItem.icon"
             ></i>
        </div>
      </div>
    </div>
  """

  props:
    activeColor:
      type: String
      default: '#fd3f76'

    ICON_LIST:
      default: ['address-book', 'address-book-o', 'address-card', 'address-card-o', 'bandcamp', 'bath', 'eercast', 'envelope-open', 'etsy', 'free-code-camp', 'grav', 'handshake-o', 'id-card', 'etsy', 'free-code-camp', 'grav', 'handshake-o', 'id-card','free-code-camp', 'grav', 'handshake-o', 'id-card']

  computed:
    allpages: ->
      Math.ceil(@ICON_LIST.length / @per_page)

    widthPercent: ->
      @allpages * 100 + '%'

  created: ->
    @getIconRange()

  data: ->
    selectedIcon: 'address-book'
    per_page: '15'
    icon_list: []

  methods:
    iconSelect: (index) ->
      @selectedIcon = @ICON_LIST[index]

    getIconRange: ->
      #获取页数
      #总的渲染list
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
         @click="toggleDisplay(event)">
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

    toggleDisplay: (e) ->
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
        @$emit 'colorChanged', @selectedColor
      else
        @selectedColor = ''

swiper = Vue.extend
  template: """
    <div class="swiper"
         @touchstart="onTouchStart"
         @touchmove="onTouchMove"
         @touchend="onTouchEnd">
      <div class="swiper-wrap"
           ref="swiperWrap"
           :style="{ 'transform': 'translate3d(' + delta + 'px, 0, 0)' }">
        <slot></slot>
      </div>
      <div class="swiper-pagination">
        <span class="swiper-pagination-bullet"
              v-for="(slide, index) in slideEls"
              :class="{ 'active': index + 1 == currpage }"
              ></span>
      </div>
    </div>
  """

  mounted: ->
    @slideEls = @$refs.swiperWrap.children[0].children
    # console.log @$refs.swiperWrap.children[0].children
    # console.log @slideEls

  data: ->
    startPosition: null
    slideEls: []
    translateX: '3'
    delta: 0
    currpage: 1
    startTranslate: 0

  methods:
    onTouchStart: (e) ->
      @startPosition = e.changedTouches[0].pageX

    onTouchMove: (e) ->
      @delta = e.changedTouches[0].pageX - @startPosition

    onTouchEnd: ->

iconpickerSelection = Vue.extend
  template: """
    <selection v-on:submit="submitIcon">
      <div class="fontIconPicker" slot="content">
        <colorpicker :selectedColor=iconColor
                     v-on:colorChanged="updateIconColor">
        </colorpicker>
        <swiper>
          <iconpicker :activeColor=iconColor></iconpicker>
        </swiper>
      </div>
    </selection>
  """

  components:
    'selection': selection
    'colorpicker': colorpicker
    'swiper': swiper
    'iconpicker': iconpicker

  methods:
    updateIconColor: (newColor) ->
      @iconColor = newColor

    submitIcon: ->
      console.log @iconColor


iconPicker = (icon = 'bath', color) ->
  iconPicker.instance = new iconpickerSelection
    el: createModalContainer('modal-container')

    data:
      fontIcon: icon
      iconColor: color

  iconPicker.instance

window.iconpicker = iconPicker
