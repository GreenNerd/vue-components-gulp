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
    <div>
      <div class="datepicker-mask" @click="close" v-show="datepickerView"></div>
      <div class="datepicker" v-show="datepickerView">
        <div class="form-control">
          <span class="datepickerExit" @click="close">关闭</span>
          <span class="datepickerSubmit" @click="submitDate">确认</span>
        </div>
        <div class="datepicker-date" v-show="displayDateView">
          <div class='datepicker-ctrl'>
            <span class="datepicker-preBtn" @click="monthClick(-1)">&lt;</span>
            <span class="datepicker-text" @click="showMonthView">{{ year }}年{{ month + 1 }}月</span>
            <span class="datepicker-nextBtn" @click="monthClick(1)">&gt;</span>
          </div>
          <div class="datepicker-inner">
            <div class="datepicker-weekRange">
              <span v-for="(w, $index) in daysOfWeek"
                    :class="{'highlightWeekend': $index == 0 || $index == 6 }">{{ w }}</span>
            </div>
            <div class="datepicker-dateRange">
              <span v-for="d in dateRange"
                    class="day-cell"
                    :class="d.class"
                    @click="daySelect(d.date)"><div>{{ d.text }}</div></span>
            </div>
          </div>
        </div>
        <div class="datepicker-month" v-show="displayMonthView">
          <div class='datepicker-ctrl'>
            <span class="datepicker-preBtn" @click="yearClick(-1)">&lt;</span>
            <span class="datepicker-text" @click="showYearView">{{ year }}年</span>
            <span class="datepicker-nextBtn "@click="yearClick(1)">&gt;</span>
          </div>
          <div class='datepicker-inner'>
            <div class="datepicker-monthRange">
              <span v-for="(m, $index) in months"
                    :class="{'datepicker-item-active':months[month] == m && year == currDate.getFullYear() }"
                    @click="monthSelect($index)"><div>{{ m }}</div></span>
            </div>
          </div>
        </div>
        <div class="datepicker-year" v-show="displayYearView">
          <div class='datepicker-ctrl'>
            <span class="datepicker-preBtn" @click="decadeClick(-1)">&lt;</span>
            <span class="datepicker-text">{{ stringifyDecadeYear(year) }}</span>
            <span class="datepicker-nextBtn" @click="decadeClick(1)">&gt;</span>
          </div>
          <div class='datepicker-inner'>
            <div class=datepicker-decadeRange>
              <span v-for="y in decadeRange"
                    :class="{'datepicker-item-active':year == y.text && year == currDate.getFullYear() }"
                    @click="yearSelect(y.text)"><div>{{ y.text }}</div></span>
            </div>
          </div>
        </div>
      </div>
    </div>
  """

  mounted: ->
    @year = @currDate.getFullYear()
    @month = @currDate.getMonth()
    @date = @currDate.getDate()
    @getDateRange()
    @datepickerView = true
    @displayDateView = true

  data: ->
    datepickerView: false
    displayDateView: false
    displayMonthView: false
    displayYearView: false
    year: ''
    month: ''
    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    months: ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
    dateRange: []
    decadeRange: []

  watch:
    currDate: ->
      @year = @currDate.getFullYear()
      @month = @currDate.getMonth()
      @remakeCalendar()

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
        @year = @year - 1
      else
        @year = @year + 1

    decadeClick: (num) ->
      if num == -1
        @year = @year - 10
      else
        @year = @year + 10
      @getDateRange()

    showMonthView: ->
      @displayDateView = false
      @displayMonthView = true

    showYearView: ->
      @displayMonthView = false
      @displayYearView = true

    daySelect: (date) ->
      selectDate = date.split('-')
      @currDate = new Date(selectDate[0], selectDate[1], selectDate[2])

    monthSelect: (index) ->
      @displayMonthView = false
      @displayDateView = true
      @currDate = new Date(@year, index, @date)

    yearSelect: (num) ->
      @displayYearView = false
      @displayMonthView = true
      @currDate = new Date(num , @month, @date)

    stringifyDecadeYear: (year) ->
      year - 5 + '-' + ( year + 6 )

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
      nextMonth = @getYearMonth(@year, @month + 1)
      for i in [0..firstDayWeek-1]
        date = preMonthDayCount - firstDayWeek + 1 + i
        @dateRange.push({
          date: preMonth.year + '-' + preMonth.month + '-' + date
          text: date
          class: 'cell-gray'
        })
      # 这个月应显示的date
      for i in [1..dayCount]
        dayClass = ''
        if i == @currDate.getDate() && @currDate.getFullYear() == @year && @currDate.getMonth() == @month
          dayClass = 'datepicker-item-active'
        @dateRange.push({
          date: @year + '-' + @month + '-' + i
          text: i
          class: dayClass
        })
      # 下个月应显示的date
      if @dateRange.length < 42
        nextMonthNeed = 42 - @dateRange.length
        for i in [1..nextMonthNeed]
          @dateRange.push({
            date: nextMonth.year + '-' + nextMonth.month + '-' + i
            text: i
            class: 'cell-gray'
          })

      @getDecadeRange()

    getDecadeRange: ->
      @decadeRange = []
      firstDecadeYear = @year - 5
      for i in [0..11]
        @decadeRange.push({
          text: firstDecadeYear + i
        })

    close: ->
      @datepickerView = false
      @displayDateView = false
      @displayMonthView = false
      @displayYearView = false


window.dateTimepicker = dateTimepicker
