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
    <div slot="swiperSlide">
      icon-list
    </div>
  """

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
      @$emit('submit')
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
        @$emit('colorChanged', @selectedColor)

swiper = Vue.extend
  template: """
    <div>
      <div>swiper</div>
      <slot name="swiperSlide"></slot>
    </div>
  """

iconpickerSelection = Vue.extend
  template: """
    <selection v-on:submit="submitIcon">
      <div class="fontIconPicker" slot="content">
        <colorpicker :selectedColor=iconColor
                     v-on:colorChanged="updateIconColor">
        </colorpicker>
        <swiper>
          <iconpicker slot="swiperSlide"></iconpicker>
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
