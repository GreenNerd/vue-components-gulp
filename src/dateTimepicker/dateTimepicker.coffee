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
      <div class="datepicker-date">
        <div class='form-control'>
          <span>关闭</span>
          <span>确认</span>
        </div>
        <div class='datepicker-ctrl'>
          <span v-on:click="monthClick(-1)">&lt;</span>
          <span>{{ year }}年{{ month + 1 }}月</span>
          <span v-on:click="monthClick(1)">&gt;</span>
        </div>
        <div class="datepicker-inner">
          <div class="datepicker-weekRange">
            <span v-for="w in daysOfWeek">{{ w }}</span>
          </div>
          <div class="datepicker-dateRange">
            <span v-for="d in dateRange" class="day-cell" :class="d.class">{{ d.text }}</span>
          </div>
        </div>
      </div>
      <div class="datepicker-month">
        <div class='datepicker-ctrl'>
          <span v-on:click="yearClick(-1)">&lt;</span>
          <span>{{ year }}年</span>
          <span v-on:click="yearClick(1)">&gt;</span>
        </div>
        <div class='datepicker-inner'>
          <div class="datepicker-monthRange">
            <span v-for="(m, $index) in months"
                  :class="{'datepicker-item-active':months[month] == m }">{{ m }}</span>
          </div>
        </div>
      </div>
      </div class="datepicker-year">

      </div>
    </div>
  """

  mounted: ->
    @year = @currDate.getFullYear()
    @month = @currDate.getMonth()
    @date = @currDate.getDate()
    @getDateRange()

  data: ->
    year: ''
    month: ''
    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    months: ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
    dateRange: []

  methods:
    monthClick: (num) ->
      if num == -1
        preMonth = @getYearMonth(@year, @month - 1)
        @currDate = new Date(preMonth.year, preMonth.month, @date)
      else
        nextMonth = @getYearMonth(@year, @month + 1)
        @currDate = new Date(nextMonth.year, nextMonth.month, @date)
      @remakeCalendar()

    yearClick: (num) ->
      if num == -1
        @currDate = new Date(@year - 1, @month, @date)
      else
        @currDate = new Date(@year + 1, @month, @date)
      @year = @currDate.getFullYear()

    remakeCalendar: ->
      @year = @currDate.getFullYear()
      @month = @currDate.getMonth()
      @getDateRange()

    getYearMonth: (year, month) ->
      if month > 11
        year++
        month = 0
      else
        if month < 0
          year--
          month = 11
      { year: year, month: month }

    getDayCount: (year, month) ->
      dict = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      if month == 1
        if year % 400 == 0 || year % 4 == 0 && year % 100 != 0
          return 29
      dict[month]

    getDateRange: ->
      @dateRange = []
      currMonthFirstDay = new Date(@year, @month, 1)
      firstDayWeek = currMonthFirstDay.getDay()
      if firstDayWeek == 0
        firstDayWeek = 7
      dayCount = @getDayCount(@year, @month)
      # 上个月应显示的date
      preMonth = @getYearMonth(@year, @month - 1)
      preMonthDayCount = @getDayCount(preMonth.year, preMonth.month)
      for i in [0..firstDayWeek-1]
        date = preMonthDayCount - firstDayWeek + 1 + i
        @dateRange.push({
          text: date
          class: 'cell-gray'
        })
      # 这个月应显示的date
      for i in [1..dayCount]
        dayClass = ''
        if i == @currDate.getDate()
          dayClass = 'datepicker-item-active'
        @dateRange.push({
          text: i
          class: dayClass
        })
      # 下个月应显示的date
      if @dateRange.length < 42
        nextMonthNeed = 42 - @dateRange.length
        for i in [1..nextMonthNeed]
          @dateRange.push({
            text: i
            class: 'cell-gray'
          })


window.dateTimepicker = dateTimepicker
