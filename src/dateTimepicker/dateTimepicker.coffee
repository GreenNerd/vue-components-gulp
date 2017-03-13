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
  .replace(/YYYY/g, @getFullYear())
  .replace(/MM/g, ('0' + (@getMonth() + 1)).slice(-2))
  .replace(/DD/g, ('0' + @getDate()).slice(-2))
  .replace(/hh/g, ('0' + @getHours()).slice(-2))
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
    <selection v-on:submit="submitDate"
               v-on:closeModal="close">
      <datetimepicker slot="content" :currDate.sync=initValue :dateType=formatType></datetimepicker>
    </selection>
  """

  data: ->
    initValue: new Date()

  methods:
    submitDate: ->
      @$emit 'valueChanged', @initValue

    close: ->

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
      @$emit('closeModal')
      @displayModal = false
      dateTimepicker.instance = null

    toggleDisplay: (e) ->
      @close() if e.target.classList.contains('modal')

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
                  :key="$index"
                  :class="{'highlightWeekend': $index == 0 || $index == 6 }">{{ w }}</span>
          </div>
          <div class="datepicker-dateRange">
            <div v-for="d in dateRange"
                 :key="d.date"
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
                 :key="$index"
                 :class="{'datepicker-item-active':months[month] == m && year == selectedDate.getFullYear() }"
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
                 :key="y.text"
                 :class="{'datepicker-item-active':year == y.text }"
                 @click="yearSelect(y.text)"><span>{{ y.text }}</span></div>
          </div>
        </div>
      </div>
    </div>
  """

  props:
    initDate:
      type: Object
      default: new Date()

    daysOfWeek:
      default: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]

  mixins: [timeMixins]

  created: ->
    @displayDate = @selectedDate = @initDate
    @getDateRange()
    @getMonthRange()

  computed:
    year: ->
      @displayDate.getFullYear()
    month: ->
      @displayDate.getMonth()
    date: ->
      @displayDate.getDate()

  data: ->
    displayDate: ''
    selectedDate: ''
    displayDateView: true
    displayMonthView: false
    displayYearView: false
    months: []
    dateRange: []
    decadeRange: []

  watch:
    displayDate: ->
      @getDateRange()

    selectedDate: ->
      @getDateRange()
      @$emit('daySelect', [@selectedDate.getFullYear(), @selectedDate.getMonth() + 1, @selectedDate.getDate()])

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
      if num == -1 then @displayDate = new Date(@year - 1, @month, @date) else @displayDate = new Date(@year + 1, @month, @date)

    decadeClick: (num) ->
      if num == -1 then @displayDate = new Date(@year - 10, @month, @date) else @displayDate = new Date(@year + 10, @month, @date)

    showMonthView: ->
      @displayDateView = false
      @displayMonthView = true

    showYearView: ->
      @displayMonthView = false
      @displayYearView = true

    daySelect: (date) ->
      if date
        selectDate = date.split('-')
        @selectedDate = new Date(selectDate[0], selectDate[1] - 1, selectDate[2])

    monthSelect: (index) ->
      @displayMonthView = false
      @displayDateView = true
      @displayDate = @selectedDate = new Date(@year, index, @date)

    yearSelect: (num) ->
      @displayYearView = false
      @displayMonthView = true
      @displayDate = @selectedDate = new Date(num , @month, @date)

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
        if i == @selectedDate.getDate() && @year == @selectedDate.getFullYear() && @month == @selectedDate.getMonth()
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
            <div class="preBtn" @click="hourClick(-1)">&and;</div>
            <div class="timeText" @click="showHourView">{{ stringifyTime(hour) }}</div>
            <div class="nextBtn" @click="hourClick(1)">&or;</div>
          </div>
          <span class="connection">:</span>
          <div class="timepicker-minute">
            <span class="timeName">分钟</span>
            <div class="preBtn" @click="minuteClick(-1)">&and;</div>
            <div class="timeText" @click="showMinuteView">{{ stringifyTime(minute) }}</div>
            <div class="nextBtn" @click="minuteClick(1)">&or;</div>
          </div>
        </div>
      </div>
      <div class="timepicker-hour" v-show="displayHourView">
        <div class="timepicker-inner">
          <div v-for="h in hourRange"
               :key="h"
               :class="{'timepicker-item-active': h == hour}"
               @click="hourSelect(h)"><span>{{ h }}</span></div>
        </div>
      </div>
      <div class="timepicker-minute" v-show="displayMinuteView">
        <div class="timepicker-inner">
          <div v-for="m in minuteRange"
               :key="m"
               :class="{'timepicker-item-active': m == minute }"
               @click="minuteSelect(m)"><span>{{ m }}</span></div>
        </div>
      </div>
    </div>
  """

  props:
    initTime:
      type: Object
      default: new Date()

  mixins: [timeMixins]

  created: ->
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
    currDate:
      type: Object
      default: new Date()

    dateType:
      type: String

  created: ->
    if @dateType == 'date' || @dateType == 'datetime'
      @isShowDate = true
    else
      @isShowTime = true

  data: ->
    isShowDate: false
    isShowTime: false
    showtime: true
    year: '2017'
    month: '0'
    date: '1'
    hour: '00'
    minute: '00'

  methods:
    changeView: ->
      @showtime = !@showtime
      @isShowDate = !@isShowDate
      @isShowTime = !@isShowTime

    updateDate: (selectDate) ->
      @currDate.setFullYear(selectDate[0], selectDate[1] - 1, selectDate[2])

    updateTime: (selectTime) ->
      @currDate.setHours(selectTime[0], selectTime[1])

window.dateTimepicker = dateTimepicker
