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

timeMixins =
  methods:
    stringifyTime: (t) ->
      ('0' + t).slice(-2)

Date.prototype.format = (format) ->
  format
  .replace(/年/g, @getFullYear())
  .replace(/yyyy/g, @getFullYear())
  .replace(/月/g, ('0' + (@getMonth() + 1)).slice(-2))
  .replace(/MM/g, ('0' + (@getMonth() + 1)).slice(-2))
  .replace(/日/g, ('0' + @getDate()).slice(-2))
  .replace(/dd/g, ('0' + @getDate()).slice(-2))
  .replace(/时/g, ('0' + @getHours()).slice(-2))
  .replace(/hh/g, ('0' + @getHours()).slice(-2))
  .replace(/分/g, ('0' + @getMinutes()).slice(-2))
  .replace(/mm/g, ('0' + @getMinutes()).slice(-2))

dateTimepicker = (date = new Date(), type = 'datetime') ->
  dateTimepicker.instance = new datetimepickerSelection
    el: createModalContainer('modal-container')

    data:
      initValue: date
      formatType: type

    components:
      'selection': selection
      'datetimepicker': datetimepicker

  dateTimepicker.instance

datetimepickerSelection = Vue.extend
  template: """
    <selection :nowValue=initValue :dateType=formatType>
      <datetimepicker slot="content" :Default.sync=initValue :dateType=formatType></datetimepicker>
    </selection>
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

datePicker = Vue.extend
  template:"""
    <div class="datepicker">
      <div class="datepicker-date" v-show="displayDateView">
        <div class='datepicker-ctrl'>
          <span class="datepicker-preBtn" @click="monthClick(-1)"><i class="fa fa-chevron-left"></i></span>
          <span class="datepicker-text" @click="showMonthView">{{ year }}年{{ stringifyTime(month + 1) }}月</span>
          <span class="datepicker-nextBtn" @click="monthClick(1)"><i class="fa fa-chevron-right"></i></span>
        </div>
        <div class="datepicker-inner">
          <div class="datepicker-weekRange">
            <span v-for="(w, $index) in daysOfWeek"
                  :class="{'highlightWeekend': $index == 0 || $index == 6 }">{{ w }}</span>
          </div>
          <div class="datepicker-dateRange">
            <div v-for="d in dateRange"
                  class="day-cell"
                  :class="d.class"
                  :date-data="d.date"
                  @click="daySelect(d.date)"><span>{{ d.text }}</span></div>
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
            <div v-for="(m, $index) in months"
                  :class="{'datepicker-item-active':months[month] == m && year == displayDate.getFullYear() }"
                  @click="monthSelect($index)"><span>{{ m }}</span></div>
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
            <div v-for="y in decadeRange"
                  :class="{'datepicker-item-active':year == y.text && year == displayDate.getFullYear() }"
                  @click="yearSelect(y.text)"><span>{{ y.text }}</span></div>
          </div>
        </div>
      </div>
    </div>
  """

  props:
    initDate:
      type: Object

  mixins: [timeMixins]

  mounted: ->
    @displayDate = @initDate
    @year = @initDate.getFullYear()
    @month = @initDate.getMonth()
    @date = @initDate.getDate()
    @getDateRange()
    @getMonthRange()

  data: ->
    displayDate: ''
    displayDateView: true
    displayMonthView: false
    displayYearView: false
    year: '2017'
    month: '0'
    date: '1'
    daysOfWeek: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    months: []
    dateRange: []
    decadeRange: []

  watch:
    displayDate: ->
      @year = @displayDate.getFullYear()
      @month = @displayDate.getMonth()
      @date = @displayDate.getDate()
      @getDateRange()
      @$emit('daySelect', [@year, @month + 1, @date])

  methods:
    getMonthRange: ->
      for i in [1..12]
        @months.push(i + '月')

    monthClick: (num) ->
      if num == -1
        preMonth = @getYearMonth(@year, @month - 1)
        @displayDate = new Date(preMonth.year, preMonth.month, @date)
      else
        nextMonth = @getYearMonth(@year, @month + 1)
        @displayDate = new Date(nextMonth.year, nextMonth.month, @date)

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
      if date
        selectDate = date.split('-')
        @displayDate = @selectedDate = new Date(selectDate[0], selectDate[1] - 1, selectDate[2])

    monthSelect: (index) ->
      @displayMonthView = false
      @displayDateView = true
      @displayDate = new Date(@year, index, @date)

    yearSelect: (num) ->
      @displayYearView = false
      @displayMonthView = true
      @displayDate = new Date(num , @month, @date)

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
      dateRangeLength = firstDayWeek == 0 ? 35 : 42
      dayCount = new Date(@year, @month + 1, 0).getDate()
      # 上个月的date
      for i in [1..firstDayWeek]
        @dateRange.push({
          text: ''
        })
      # 这个月应显示的date
      for i in [1..dayCount]
        dayClass = ''
        if i == @date
          dayClass = 'datepicker-item-active'
        @dateRange.push({
          date: @year + '-' + (@month + 1) + '-' + i
          text: i
          class: dayClass
        })
      # 下个月的date
      if @dateRange.length < dateRangeLength
        nextMonthNeed = dateRangeLength - @dateRange.length
        for i in [1..nextMonthNeed]
          @dateRange.push({
            text: ''
          })

      @getDecadeRange()

    getDecadeRange: ->
      @decadeRange = []
      firstDecadeYear = @year - 5
      for i in [0..11]
        @decadeRange.push({
          text: firstDecadeYear + i
        })

timePicker = Vue.extend
  template:"""
    <div class="timepicker">
      <div class="timepicker-hour-minute" v-show="displayTimeView">
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
  """

  props:
    initTime:
      type: Object

  mixins: [timeMixins]

  mounted: ->
    @hour = @initTime.getHours()
    @minute = @initTime.getMinutes()
    @getTimeRange()

  watch:
    hour: ->
      @$emit('update', [@hour, @minute])

    minute: ->
      @$emit('update', [@hour, @minute])

  data: ->
    displayTimeView: true
    displayHourView: false
    displayMinuteView: false
    hour: '00'
    minute: '00'
    hourRange: []
    minuteRange: []

  methods:
    getTimeRange: ->
      for i in [0..23]
        @hourRange.push((('0')+i).slice(-2))
      for i in [0..55] by 5
        @minuteRange.push((('0')+i).slice(-2))

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

datetimepicker = Vue.extend
  template:"""
    <div class="datetimepicker">
      <datepicker :initDate=currDate
                  v-show="isShowDate"
                  v-on:daySelect="updateDate"></datepicker>
      <div class="date-time-data" v-if="dateType == 'datetime'" @click="changeView">
        <div class="data-view" v-if="showtime">
          <i class="fa fa-clock-o"></i><span>{{ stringifyTime(currDate.getHours()) }}:{{ stringifyTime(currDate.getMinutes()) }}</span>
        </div>
        <div class="data-view" v-else>
          <i class="fa fa-calendar"></i><span>{{ currDate.getFullYear() }}年{{ stringifyTime(currDate.getMonth() + 1) }}月{{ stringifyTime(currDate.getDate()) }}日</span>
        </div>
      </div>
      <timepicker :initTime=currDate
                  v-show="isShowTime"
                  v-on:update="updateTime"
                  ></timepicker>
    </div>
  """

  mixins: [timeMixins]

  components:
    'datepicker': datePicker
    'timepicker': timePicker

  props:
    Default:
      type: Object

    dateType:
      type: String

  created: ->
    if @dateType == 'date' || @dateType == 'datetime'
      @isShowDate = true
    else
      @isShowTime = true
    @currDate = @Default

  data: ->
    currDate: new Date()
    displayContent: true
    isShowDate: false
    isShowTime: false
    showtime: true
    year: '2017'
    month: '0'
    date: '1'
    hour: '00'
    minute: '00'
    dateFormat: '年/月/日'
    timeFormat: '时:分'
    datetimeFormat: 'yyyy/mm/dd hh:mm'

  methods:
    changeView: ->
      @showtime = !@showtime
      @isShowDate = !@isShowDate
      @isShowTime = !@isShowTime

    updateDate: (selectDate) ->
      @currDate.setFullYear(selectDate[0], selectDate[1] - 1, selectDate[2])

    updateTime: (selectTime) ->
      @currDate.setHours(selectTime[0], selectTime[1])

    submitDate: ->
      if (@type == 'date')
        console.log(@currDate.format(@dateFormat))
      else if (@type == 'time')
        console.log(@currDate.format(@timeFormat))
      else
        console.log(@currDate.format(@datetimeFormat))
      @close()

    close: ->
      @displayContent = false
      dateTimepicker.instance = null

window.dateTimepicker = dateTimepicker
