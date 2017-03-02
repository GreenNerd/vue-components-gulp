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
      selectedDate: date
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
            <span class="datepicker-text" @click="showMonthView">{{ year }}年{{ stringifyTime(month + 1) }}月</span>
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
            <div class="time-data" @click="changeView" v-if="isShowData">
              <i class="fa fa-clock-o"></i>{{ stringifyTime(hour) }}:{{ stringifyTime(minute) }}
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
        <div class="form-control">
          <span class="timepickerExit" @click="close">关闭</span>
          <span class="timepickerSubmit" @click="submitDate">确认</span>
        </div>
        <div class="timepicker-hour-minute" v-show="displayTimeView">
          <div class="date-data" @click="changeView" v-if="isShowData">
            <i class="fa fa-calendar"></i>{{ selectedDate.getFullYear() }}年{{ stringifyTime(selectedDate.getMonth() + 1) }}月{{ stringifyTime(selectedDate.getDate()) }}日
          </div>
          <div class="timepicker-inner">
            <div class="timepicker-hour">
              <span class="timeName">小时</span>
              <span class="preBtn" @click="hourClick(-1)">&and;</span>
              <div class="timeText" @click="showHourView">{{ stringifyTime(hour) }}</div>
              <div class="nextBtn" @click="hourClick(1)">&or;</div>
            </div>
            <span class="connection">:</span>
            <div class="timepicker-minute">
              <span class="timeName">分钟</span>
              <span class="preBtn" @click="minuteClick(-5)">&and;</span>
              <div class="timeText" @click="showMinuteView">{{ stringifyTime(minute) }}</div>
              <div class="nextBtn" @click="minuteClick(5)">&or;</div>
            </div>
          </div>
        </div>
        <div class="timepicker-hour" v-show="displayHourView">
          <div class="timepicker-inner">
            <span v-for="h in hourRange"
                  :class="{'timepicker-item-active': h == hour}"
                  @click="hourSelect(h)"><div>{{ h }}</div></span>
          </div>
        </div>
        <div class="timepicker-minute" v-show="displayMinuteView">
          <div class="timepicker-inner">
            <span v-for="m in minuteRange"
                  :class="{'timepicker-item-active': m == minute }"
                  @click="minuteSelect(m)"><div>{{ m }}</div></span>
          </div>
        </div>
      </div>
    </div>
  """

  mounted: ->
    @year = @currDate.getFullYear()
    @month = @currDate.getMonth()
    @date = @currDate.getDate()
    @hour = @currDate.getHours()
    @minute = @currDate.getMinutes()
    @pickerView = true
    @datepickerView = true if @type == 'date' or @type == 'datetime'
    @timepickerView = true if @type == 'time'
    @isShowData = true if @type == 'datetime'
    @getDateRange()
    @getMonthRange()
    @getTimeRange()

  data: ->
    pickerView: false
    datepickerView: false
    displayDateView: true
    displayMonthView: false
    displayYearView: false

    isShowData: false
    timepickerView: false
    displayTimeView: true
    displayHourView: false
    displayMinuteView: false
    year: '2017'
    month: '0'
    hour: '0'
    minute: '0'

    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    months: []
    dateRange: []
    decadeRange: []
    hourRange: []
    minuteRange: []
    dateFormat: 'yyyy/MM/dd'
    timeFormat: 'hh:mm'
    datetimeFormat: 'yyyy/MM/dd hh:mm'

  watch:
    currDate: ->
      @year = @currDate.getFullYear()
      @month = @currDate.getMonth()
      @date = @currDate.getDate()
      @getDateRange()

    selectedDate: ->
      @getDateRange()

  methods:
    getMonthRange: ->
      for i in [1..12]
        @months.push(i + '月')

    getTimeRange: ->
      for i in [0..23]
        @hourRange.push((('0')+i).slice(-2))
      for i in [0..55] by 5
        @minuteRange.push((('0')+i).slice(-2))

    changeView: ->
      @datepickerView = !@datepickerView
      @timepickerView = !@timepickerView

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
      @selectedDate = new Date(selectDate[0], selectDate[1] - 1, selectDate[2])

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

    getDateRange: ->
      @dateRange = []
      currMonthFirstDay = new Date(@year, @month, 1)
      firstDayWeek = currMonthFirstDay.getDay()
      if firstDayWeek == 0
        firstDayWeek = 7
      dayCount = new Date(@year, @month + 1, 0).getDate()
      # 上个月应显示的date
      preMonth = @getYearMonth(@year, @month - 1)
      preMonthDayCount = new Date(@year, @month, 0).getDate()
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
        if i == @selectedDate.getDate() && @selectedDate.getFullYear() == @year && @selectedDate.getMonth() == @month
          dayClass = 'datepicker-item-active'
        @dateRange.push({
          date: @year + '-' + (@month + 1) + '-' + i
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
      @pickerView = false
      @datepickerView = false
      @timepickerView = false
      dateTimepicker.instance = null

    submitDate: ->
      console.log(@stringify())
      @close()

    stringify: ->
      if @type == 'date'
        @dateFormat
        .replace(/yyyy/g, @selectedDate.getFullYear())
        .replace(/MM/g, (('0') + (@selectedDate.getMonth() + 1)).slice(-2))
        .replace(/dd/g, (('0') + @selectedDate.getDate()).slice(-2))
      else if @type == 'time'
        @timeFormat
        .replace(/hh/g, @stringifyTime(@hour))
        .replace(/mm/g, @stringifyTime(@minute))
      else
        @datetimeFormat
        .replace(/yyyy/g, @selectedDate.getFullYear())
        .replace(/MM/g, (('0') + (@selectedDate.getMonth() + 1)).slice(-2))
        .replace(/dd/g, (('0') + @selectedDate.getDate()).slice(-2))
        .replace(/hh/g, @stringifyTime(@hour))
        .replace(/mm/g, @stringifyTime(@minute))

    stringifyTime: (t) ->
      ('0' + t).slice(-2)

    hourClick: (num) ->
      if @hour + num > 23 then @hour = 0
      else if @hour + num < 0 then @hour = 23
      else @hour = @hour + num

    minuteClick: (num) ->
      if @minute + num > 59 then @minute = @minute + num - 60
      else if @minute + num < 0 then @minute = @minute + num + 60
      else @minute = @minute + num

    hourSelect: (h) ->
      @hour = parseInt(h)
      @displayTimeView = true
      @displayHourView = false

    minuteSelect: (m) ->
      @minute = parseInt(m)
      @displayTimeView = true
      @displayMinuteView = false

    showHourView: ->
      @displayHourView = true
      @displayTimeView = false

    showMinuteView: ->
      @displayMinuteView = true
      @displayTimeView = false



window.dateTimepicker = dateTimepicker
