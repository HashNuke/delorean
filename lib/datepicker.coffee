class @Datepicker

  value: {}

  constructor: (@$input, @options={})->
    @currentDate = new Date()
    @setDefaultOptions()
    @parseInitialValue()
    @setDefaultDateIfNecessary()
    @lang = @getLocale(@options["locale"])
    @view = new Datepicker.View(@, @options.startingView)


  setDefaultDateIfNecessary: ->
    if @options.startingView == "months" || @options.startingView == "days"
      @value.year ||= @currentDate.getFullYear()
    if @options.startingView == "days"
      @value.month ||= @currentDate.getMonth()


  numberOfDaysInMonth = (year, month)->
    new Date(year, month + 1, 0).getDate()


  destroy: ->
    @view.destroy()
    delete @currentDate
    delete @lang
    delete @view


  setDefaultOptions: ->
    @options["locale"] ||= "en"
    @options["format"] ||= "yyyymmdd"
    @options["separator"] ||= "/"
    @options["startingView"] ||= "years"


  years: (yearAmongRange)->
    currentYear  = @currentDate.getFullYear()
    selectedYear = if @value.year? then @value.year else currentYear
    yearAmongRange ||=  (@value.year || currentYear)
    startingYear = yearAmongRange - (yearAmongRange % 10)
    endingYear   = startingYear + 9

    for year in [startingYear..endingYear]
      {
        year:     year
        current:  currentYear == year
        selected: @value.year == year
      }


  months: (year)->
    currentMonth  = @currentDate.getMonth()
    currentYear  = @currentDate.getFullYear()
    selectedMonth = if @value.month? then @value.month else currentMonth
    for monthLocale, index in @lang.months
      {
        month:     index
        monthName: monthLocale.short
        current:   currentMonth == index && currentYear == year
        selected:  selectedMonth == index && @value.year == year
      }


  shortWeekdayName: (weekdayId)->
    return @lang.days[weekdayId].short if @lang.days[weekdayId]?


  getLocale: (languageCode)->
    return Datepicker.Locale[languageCode] if Datepicker.Locale[languageCode]?
    throw new Datepicker.Error("Locale not available")


  days: (year, month)->
    currentYear  = @currentDate.getFullYear()
    currentMonth  = @currentDate.getMonth()
    currentDay = @currentDate.getDate()
    numberOfDaysInCurrentMonth  = numberOfDaysInMonth(year, month)
    numberOfDaysInPreviousMonth = numberOfDaysInMonth(year, month - 1)
    numberOfDaysInNextMonth     = numberOfDaysInMonth(year, month + 1)

    weekdayIdOfFirstDay = new Date(year, month, 1).getDay()
    weekdayIdOfLastDay  = new Date(year, month, numberOfDaysInCurrentMonth).getDay()
    daysToDisplayForNextMonth = 6 - weekdayIdOfLastDay

    # Because we have to start from the first Sunday to the last Saturday
    # to fill up the calendar
    dayRangeStart = 1 - weekdayIdOfFirstDay
    dayRangeEnd   = numberOfDaysInCurrentMonth + daysToDisplayForNextMonth
    daysForView = [dayRangeStart..dayRangeEnd]

    for dayNumber in daysForView
      weekdayId = (dayNumber + weekdayIdOfFirstDay - 1) % 7

      selectableMonth = false
      day = if dayNumber > numberOfDaysInCurrentMonth
              dayNumber - numberOfDaysInCurrentMonth
            else if dayNumber < 1
              numberOfDaysInPreviousMonth + dayNumber
            else if dayNumber > 0
              selectableMonth = true
              dayNumber

      selected = @value.year == year && @value.month == month && @value.day == day && selectableMonth
      current = currentYear == year && currentMonth == month && currentDay == day
      {day, weekdayId, selected, current, selectableMonth}


  setValue: (year, month, day)->
    @value.year  = year
    @value.month = month
    @value.day   = day


  padZero = (n)->
    if n < 10 then "0#{n}" else "#{n}"


  format: ->
    switch @options.format
      when "yyyymmdd" then [@value.year, padZero(@value.month+1), padZero(@value.day)].join(@options.separator)
      when "ddmmyyyy" then [padZero(@value.day), padZero(@value.month+1), @value.year].join(@options.separator)
      else new Datepicker.Error("Invalid format string")


  parseInitialValue: ->
    return if !@options.initialValue? || @options.initialValue.trim().length == 0
    dateParts = @options.initialValue.split(@options.separator)
    switch @options.format
      when "yyyymmdd"
        @setValue parseInt(dateParts[0], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[2], 10)
      when "ddmmyyyy"
        @setValue parseInt(dateParts[2], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[0], 10)
      else new Datepicker.Error("Initial value is of unknown format")
