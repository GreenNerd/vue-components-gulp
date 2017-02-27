createTimepickerContainer = (TimepickerId) ->
  if document.getElementById(TimepickerId)
    timepickerContainer = document.getElementById(TimepickerId)
    timepickerContainer.innerHTML = ''
  else
    timepickerContainer = document.createElement('div')
    timepickerContainer.id = TimepickerId
    document.body.appendChild(timepickerContainer)
  timepickerContainer

dateTimepicker = (date, type) ->
  datepicker = document.createElement('div')
  createTimepickerContainer('date-container').appendChild(datepicker)
  dateTimepicker.instance = new DatePickerComponent
    el: datepicker
    data:
      currDate: date
      type: type
  dateTimepicker.instance

DatePickerComponent = Vue.extend
  template:"""
    <div class="datepicker">
      <div class='form-control'>
        <span>关闭</span>
        <span>确认</span>
      </div>
      <div class='datepicker-ctrl'>
        <span>&lt;</span>
        <span>{{ year }}年{{ month }}月</span>
        <span>&gt;</span>
      </div>
      <div class="datepicker-inner">
        <div class="datepicker-weekRange">
          <span v-for="w in daysOfWeek">{{ w }}</span>
        </div>
        <div class="datepicker-dateRange">
        </div>
      </div>
    </div>
  """

  mounted: ->

  data: ->
    year: ''
    month: ''
    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    dateRange: []

  methods: ->

window.dateTimepicker = dateTimepicker
