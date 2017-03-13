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

iconPicker = () ->
  iconPicker.instance = new iconpickerSelection
    el: createModalContainer('modal-container')

    data:

  iconPicker.instance

iconpicker = Vue.extend

selection = Vue.extend

colorpicker = Vue.extend

swiper = Vue.extend

iconpickerSelection = Vue.extend

window.iconpicker = iconPicker
