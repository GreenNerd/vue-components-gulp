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
    <div>
        <div class="selection-ctrl">
          <span class="cancel-select" @click="">取消</span>
          <span class="ensure-select" @click="">确认</span>
        </div>
        <slot class="selection-content" name="content"></slot>
    </div>
  """

colorpicker = Vue.extend
  template: """
    <div>color-list</div>
  """

swiper = Vue.extend
  template: """
    <div>
      <div>swiper</div>
      <slot name="swiperSlide"></slot>
    </div>
  """

iconpickerSelection = Vue.extend
  template: """
    <selection>
      <div class="iconpicker" slot="content">
        <colorpicker></colorpicker>
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


iconPicker = () ->
  iconPicker.instance = new iconpickerSelection
    el: createModalContainer('modal-container')

  iconPicker.instance

window.iconpicker = iconPicker
