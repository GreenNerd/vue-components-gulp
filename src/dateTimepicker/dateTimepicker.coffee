createTimepickerContainer = (TimepickerId) ->
  if document.getElementById(TimepickerId)
    timepickerContainer = document.getElementById(TimepickerId)
    timepickerContainer.innerHTML = ''
  else
    timepickerContainer = document.createElement('div')
    timepickerContainer.id = TimepickerId
    document.body.appendChild(timepickerContainer)
  timepickerContainer

dateTimepicker = (date = new Date(), type = 'date') ->
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
      <div class="datepicker-mask" @click="close" v-if="pickerView"></div>
      <div class="datepicker" v-if="datepickerView">
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
      <div class="timepicker" v-if="timepickerView">
        <div class="timepicker-hour-minute" v-show="displayTimeView">
          <div class="form-control">
            <span class="timepickerExit" @click="timepickerClose">关闭</span>
            <span class="timepickerSubmit">确认</span>
          </div>
          <div class="timepicker-inner">
            <div class="timepicker-hour">
              <span class="timeName">小时</span>
              <span class="preBtn">&and;</span>
              <div class="timeText">{{ hour }}</div>
              <div class="nextBtn">&or;</div>
            </div>
            <span class="connection">:</span>
            <div class="timepicker-minute">
              <span class="timeName">分钟</span>
              <span class="preBtn">&and;</span>
              <div class="timeText" @click="showMinuteView">{{ minute }}</div>
              <div class="nextBtn">&or;</div>
            </div>
          </div>
        </div>
        <div class="timepicker-hour" v-show="displayHourView">
          <div class="form-control">
            <span class="timepickerExit">关闭</span>
            <span class="timepickerSubmit">确认</span>
          </div>
          <div class="timepicker-inner">
            <span v-for="h in hourRange"><div>{{ h }}</div></span>
          </div>
        </div>
        <div class="timepicker-minute" v-show="displayMinuteView">
          <div class="form-control">
            <span class="timepickerExit">关闭</span>
            <span class="timepickerSubmit">确认</span>
          </div>
          <div class="timepicker-inner">
            <span v-for="m in minuteRange"><div>{{ m }}</div></span>
          </div>
        </div>
      </div>
    </div>
  """

  mounted: ->
    @year = @currDate.getFullYear()
    @month = @currDate.getMonth()
    @date = @currDate.getDate()
    @hour = @stringifyHours(@currDate.getHours())
    @minute = @currDate.getMinutes()
    @getDateRange()
    @pickerView = true
    @timepickerView = true

  data: ->
    pickerView: false
    datepickerView: false
    displayDateView: true
    displayMonthView: false
    displayYearView: false

    timepickerView: false
    displayTimeView: true
    displayHourView: false
    displayMinuteView: false
    year: '2017'
    month: '0'
    hour: ''
    minute: ''
    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    months: ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
    dateRange: []
    decadeRange: []
    hourRange: ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
    minuteRange: ["00","05","10","15","20","25","30","35","40","45","50","55"]
  watch:
    currDate: ->
      @year = @currDate.getFullYear()
      @month = @currDate.getMonth()
      @date = @currDate.getDate()
      @getDateRange()

  methods:
    stringifyHours: (h) ->
      if h < 10 then '0' + h else h

    monthClick: (num) ->
      if num == -1
        preMonth = @getYearMonth(@year, @month - 1)
        @currDate = new Date(preMonth.year, preMonth.month, @date)
      else
        nextMonth = @getYearMonth(@year, @month + 1)
        @currDate = new Date(nextMonth.year, nextMonth.month, @date)

    yearClick: (num) ->
      if num == -1 then @year = @year - 1 else @year = @year + 1

    decadeClick: (num) ->
      if num == -1 then @year = @year - 10 else @year = @year + 10
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
        if year % 400 == 0 or year % 4 == 0 and year % 100 != 0
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
      for i in [1..firstDayWeek]
        dayText = preMonthDayCount - firstDayWeek + i
        @dateRange.push({
          date: preMonth.year + '-' + preMonth.month + '-' + dayText
          text: dayText
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
      if @type == 'date'
        @datepickerClose()
      if @type == 'time'
        @timepickerClose()

    datepickerClose: ->
      pickerView = false
      @datepickerView = false
      dateTimepicker.instance = null

    submitDate: ->
      console.log(@currDate)
      @close()

    showHourView: ->
      @displayHourView = true
      @displayTimeView = false

    showMinuteView: ->
      @displayMinuteView = true
      @displayTimeView = false

    timepickerClose: ->
      @pickerView = false
      @timepickerView = false




window.dateTimepicker = dateTimepicker
