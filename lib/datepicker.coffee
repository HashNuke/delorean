class @Datepicker

  regex:
    dateLimitSpec: /^[\-+]\d+[dmwy]([\s,]+[\-+]\d+[dmwy])*$/
    dateLimitPartSpec:  /([\-+]\d+)([dmwy])/
    dateLimitPartsSpec: /([\-+]\d+)([dmwy])/g

  value: {}

  constructor: (@$input, @options={})->
    @currentDate = new Date()
    @_setDefaultOptions()
    @_setInitialValue()
    @_parseInitialValue()

    if @options.startDate?
      @startDate = @parseLimit(@options.startDate)

    if @options.endDate?
      @endDate = @parseLimit(@options.endDate)

    @_setDefaultDateIfNecessary()
    @lang = @getLocale(@options["locale"])
    @view = new Datepicker.View(@, @options.startingView)


  _setInitialValue: ->
    if @$input.val().trim().length != 0
      @options.initialValue = @$input.val().trim()
    else
      delete @options.initialValue
      @value = {}


  # Borrowed and modified from bootstrap-datepicker
  # https://github.com/eternicode/bootstrap-datepicker/blob/9e48783a799/js/bootstrap-datepicker.js#L1466
  # Thanks to @eternicode
  parseLimit: (limitSpecifier)->
    limitSpecifier = "+0d" if limitSpecifier == "today"
    limitSpecifier = "+1d" if limitSpecifier == "tomorrow"

    return unless @regex.dateLimitSpec.test(limitSpecifier)
    parts = limitSpecifier.match(@regex.dateLimitPartsSpec)
    date  = new Date()

    for part in parts
      [_matched_value, moveBy, moveRange] = @regex.dateLimitPartSpec.exec part
      moveBy  = parseInt moveBy, 10
      switch moveRange
        when 'd'
          date.setUTCDate(date.getUTCDate() + moveBy)
        when 'w'
          date.setUTCDate(date.getUTCDate() + moveBy * 7)
        when 'm'
          date = @_moveMonth(date, moveBy)
        when 'y'
          date = @_moveMonth(date, moveBy * 12)

    {year: date.getUTCFullYear(), month: date.getUTCMonth(), day: date.getUTCDate()}


  # Borrowed and modified from bootstrap-datepicker
  # https://github.com/eternicode/bootstrap-datepicker/blob/9e48783a799/js/bootstrap-datepicker.js#L1055
  # Thanks to @eternicode
  _moveMonth: (date, moveBy)->
    newDate   = new Date(date.valueOf())
    day       = newDate.getUTCDate()
    month     = newDate.getUTCMonth()
    magnitude = Math.abs(moveBy)

    moveBy = if moveBy > 0 then 1 else -1

    if magnitude == 1
      if moveBy == -1
        # If going back one month, make sure month is not current month
        # (eg, Mar 31 -> Feb 31 == Feb 28, not Mar 02)
        testFunction = -> newDate.getUTCMonth() == month
      else
        # If going forward one month, make sure month is as expected
        # (eg, Jan 31 -> Feb 31 == Feb 28, not Mar 02)
        testFunction = -> newDate.getUTCMonth() != newMonth

      newMonth = month + moveBy
      newDate.setUTCMonth(newMonth)

      # Dec -> Jan (12) or Jan -> Dec (-1) -- limit expected date to 0-11
      if newMonth < 0 || newMonth > 11
        newMonth = (newMonth + 12) % 12
    else
      # For magnitudes >1, move one month at a time...
      for i in [0...magnitude]
        # ...which might decrease the day (eg, Jan 31 to Feb 28, etc)...
        newDate = @_moveMonth(newDate, moveBy)

      # ...then reset the day, keeping it in the new month
      newMonth = newDate.getUTCMonth()
      newDate.setUTCDate(day)
      testFunction = -> newDate.getUTCMonth() != newMonth

    # Common date-resetting loop -- if date is beyond end of month, make it
    # end of month
    while testFunction()
      newDate.setUTCDate(--day)
      newDate.setUTCMonth(newMonth)
    newDate


  _setDefaultDateIfNecessary: ->
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


  _setDefaultOptions: ->
    @options["locale"] ||= "en"
    @options["format"] ||= "yyyymmdd"
    @options["separator"] ||= "/"
    @options["startingView"] ||= "years"
    @options["highlightToday"] ||= false


  years: (yearAmongRange)->
    if @startDate? && yearAmongRange < @startDate.year
      throw new Datepicker.Error("Year is less than range")

    if @endDate? && yearAmongRange > @endDate.year
      throw new Datepicker.Error("Year is greater than range")

    currentYear = @currentDate.getFullYear()
    yearAmongRange ||= if @value.year
                         @value.year
                       else if @startDate? && currentYear < @startDate.year
                         @startDate.year
                       else if @endDate? && currentYear > @endDate.year
                         @endDate.year
                       else
                         currentYear

    startingYear = yearAmongRange - (yearAmongRange % 10)
    endingYear   = startingYear + 9


    for year in [startingYear..endingYear]
      {
        year:     year
        current:  currentYear == year
        selected: @value.year == year
        disabled: @isDisabledYear(year)
      }


  isDisabledYear: (year)->
    return true if @startDate? && year < @startDate.year
    return true if @endDate? && year > @endDate.year
    false


  isDisabledMonth: (year, month)->
    return true if @isDisabledYear(year)
    if @startDate? && @isDisabledYear(year - 1) && month < @startDate.month
      return true
    if @endDate?   && @isDisabledYear(year + 1) && month > @endDate.month
      return true
    false


  isDisabledDay: (year, month, day)->
    return true if @isDisabledMonth(year, month)
    if @startDate? && @isDisabledMonth(year, month - 1) && day < @startDate.day
      return true
    if @endDate?   && @isDisabledMonth(year, month + 1) && day > @endDate.day
      return true
    false


  months: (year)->
    currentMonth = @currentDate.getMonth()
    currentYear  = @currentDate.getFullYear()
    selectedMonth = if @value.month? then @value.month else currentMonth
    for monthLocale, index in @lang.months
      {
        month:     index
        monthName: monthLocale.short
        current:   currentMonth == index && currentYear == year
        selected:  selectedMonth == index && @value.year == year
        disabled:  @isDisabledMonth(year, index)
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
      current  = currentYear == year && currentMonth == month && currentDay == day
      disabled = @isDisabledDay(year, month, day)
      {day, weekdayId, selected, current, selectableMonth, disabled}


  setValue: (year, month, day)->
    @value.year  = year
    @value.month = month
    @value.day   = day


  _padZero: (n)->
    if n < 10 then "0#{n}" else "#{n}"


  format: ->
    switch @options.format
      when "yyyymmdd" then [@value.year, @_padZero(@value.month+1), @_padZero(@value.day)].join(@options.separator)
      when "ddmmyyyy" then [@_padZero(@value.day), @_padZero(@value.month+1), @value.year].join(@options.separator)
      when "mmddyyyy" then [@_padZero(@value.month+1), @_padZero(@value.day), @value.year].join(@options.separator)
      else new Datepicker.Error("Invalid format string")


  _parseInitialValue: ->
    return if !@options.initialValue? || @options.initialValue.trim().length == 0
    dateParts = @options.initialValue.split(@options.separator)
    switch @options.format
      when "yyyymmdd"
        @setValue parseInt(dateParts[0], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[2], 10)
      when "ddmmyyyy"
        @setValue parseInt(dateParts[2], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[0], 10)
      when "mmddyyyy"
        @setValue parseInt(dateParts[2], 10), parseInt(dateParts[0], 10) - 1, parseInt(dateParts[1], 10)
      else new Datepicker.Error("Initial value is of unknown format")
