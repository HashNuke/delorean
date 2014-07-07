# Years view
#   on selection display month
#   on prev repopulate years
#   on next repopulate years
#
# Months view
#   on click display month view
#
# Month view
#   on click set value of input field
#
# Additionals
#   If date value is already set, then open that specific year range in year view
#   If year and month don't change, then highlight selected day
#   Allow setting years, months or month view. Open up calendar depending on that


class @Pilgrim

  value: {}

  constructor: (@$input, @options={})->
    @currentDate = new Date()
    @setDefaultOptions()
    @parseInitialValue()
    @setDefaultDateIfNecessary()
    @lang = @getLocale(@options["locale"])
    @view = new Pilgrim.View(@, @options.startingView)


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
        selected: selectedYear == year
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
        selected:  selectedMonth == index
      }


  shortWeekdayName: (weekdayId)->
    return @lang.days[weekdayId].short if @lang.days[weekdayId]?


  getLocale: (languageCode)->
    return Pilgrim.Locale[languageCode] if Pilgrim.Locale[languageCode]?
    throw new Pilgrim.Error("Locale not available")


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
      else new Pilgrim.Error("Invalid format string")


  parseInitialValue: ->
    return if !@options.initialValue? || @options.initialValue.trim().length == 0
    dateParts = @options.initialValue.split(@options.separator)
    switch @options.format
      when "yyyymmdd"
        @setValue parseInt(dateParts[0], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[2], 10)
      when "ddmmyyyy"
        @setValue parseInt(dateParts[2], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[0], 10)
      else new Pilgrim.Error("Initial value is of unknown format")


class @Pilgrim.Error
  name: "Pilgrim.Error"
  constructor: (@message)->


class @Pilgrim.View
  constructor: (@pilgrim, startingView)->
    @layout()
    if startingView == "days"
      days = @pilgrim.days(@pilgrim.value.year, @pilgrim.value.month)
      @daysView @pilgrim.value.year, @pilgrim.value.month, days
    else if startingView == "months"
      @monthsView @pilgrim.value.year, @pilgrim.months(@pilgrim.value.year)
    else
      @yearsView @pilgrim.years()


  destroy: ->
    @$root.remove()


  layout: ->
    @$root    = $("<div/>").addClass("pilgrim")
    @$header  = $("<div/>").addClass("pilgrim-header")
    @$content = $("<div/>").addClass("pilgrim-content")
    @$root.append(@$header).append(@$content)
    #TODO actually position below @$input
    $("body").append @$root
    @bindEvents()


  bindEvents: ->
    @$root.on "click", ".year", (event)=>
      year = $(event.target).data("year")
      @monthsView year, @pilgrim.months(year)

    @$root.on "click", ".year-nav", (event)=>
      year = $(event.target).data("year")
      @yearsView @pilgrim.years(year)

    @$root.on "click", ".month", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      @daysView year, month, @pilgrim.days(year, month)

    @$root.on "click", ".valid-day", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      day = $(event.target).data("day")
      @pilgrim.setValue year, month, day
      @pilgrim.$input.val @pilgrim.format()
      $(document).trigger "pilgrim:destroy"

    @$root.on "click", ".change-month", (event)=>
      year  = $(event.target).data("year")
      @monthsView year, @pilgrim.months(year)

    @$root.on "click", ".change-year", (event)=>
      year  = $(event.target).data("year")
      @yearsView @pilgrim.years(year)


  yearsView: (years)->
    @$content.empty()
    @$header.empty()

    if years.length == 1
      @$header.append $("<span/>").html(years[0].year)
    else
      yearRange = "#{years[0].year} - #{years[years.length-1].year}"
      @$header.append $("<span/>").html(yearRange)


    for yearInfo, index in years
      if [0, 3, 7].indexOf(index) != -1
        @$content.append $("<div/>").addClass("pilgrim-row")
      @$content.children().last().append @buildYear(yearInfo)

    @$content.children()
      .first()
      .prepend @buildYearNav(years[0].year - 1, "&laquo;")
    @$content.children()
      .last()
      .append @buildYearNav(years[years.length-1].year + 1, "&raquo;")


  monthsView: (year, months)->
    @$content.empty()
    @$header.empty()
    @$header.append @yearHeaderNav(year)

    for monthInfo, index in months
      if index % 4 == 0
        @$content.append $("<div/>").addClass("pilgrim-row")
      @$content.children().last().append @buildMonth(year, monthInfo)


  daysView: (year, month, days)->
    @$content.empty()
    @$header.empty()
    @$header.append @monthHeaderNav(year, month)
    @$header.append @yearHeaderNav(year)

    @$content.append $("<div/>").addClass("pilgrim-row").addClass("pilgrim-weekdays")
    for dayInfo in days[0..6]
      weekdayName = @pilgrim.shortWeekdayName(dayInfo.weekdayId)
      $weekday = $("<div/>").addClass("weekday").html weekdayName
      @$content.children().last().append $weekday

    for dayInfo in days
      @$content.append @buildDay(year, month, dayInfo)


  buildYearNav: (navYear, text)->
    $("<div/>").addClass("year-nav").data(year: navYear).html(text)


  buildYear: (yearInfo)->
    $year = $("<div/>")
            .addClass("year")
            .data({year: yearInfo.year})
            .html(yearInfo.year)
    if yearInfo.current then $year.addClass("current")
    if yearInfo.selected then $year.addClass("selected")
    $year


  buildMonth: (year, monthInfo)->
    $month = $("<div/>")
            .addClass("month")
            .data({year: year, month: monthInfo.month})
            .html(monthInfo.monthName)
    if monthInfo.current then $month.addClass("current")
    if monthInfo.selected then $month.addClass("selected")
    $month


  buildDay: (year, month, dayInfo)->
    $day = $("<div/>")
          .addClass("day")
          .data({year: year, month: month, day: dayInfo.day})
          .html(dayInfo.day)
    if dayInfo.selected then $day.addClass("selected")
    if dayInfo.current then $day.addClass("current")
    if dayInfo.selectableMonth == true
      $day.addClass("valid-day")
    else
      $day.addClass("invalid-day")
    $day


  yearHeaderNav: (year)->
    $("<span/>").addClass("change-year")
      .data(year: year)
      .text(year)


  monthHeaderNav: (year, month)->
    $("<span/>").addClass("change-month")
      .data(year: year)
      .text(@pilgrim.lang.months[month].long)



class @Pilgrim.Locale
  # Language codes are ISO_639-1 (2-letter)
  # http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

  @en:
    months: [
      {short: "Jan", long: "January"},
      {short: "Feb", long: "February"},
      {short: "Mar", long: "March"},
      {short: "Apr", long: "April"},
      {short: "May", long: "May"},
      {short: "Jun", long: "June"},
      {short: "Jul", long: "July"},
      {short: "Aug", long: "August"},
      {short: "Sep", long: "September"},
      {short: "Oct", long: "October"},
      {short: "Nov", long: "November"},
      {short: "Dec", long: "December"}
    ]

    days: [
      {short: "Su"},
      {short: "Mo"},
      {short: "Tu"},
      {short: "We"},
      {short: "Th"},
      {short: "Fr"},
      {short: "Sa"}
    ]


# jQuery plugin
$.fn.pilgrim = (options={})->

  @on "focusin", (event)->
    $ele = $(this)
    options.initialValue = $ele.val() if $ele.val().trim().length != 0

    pilgrim = $("body").data("pilgrim") || new Pilgrim($ele, options)
    $ele.data("pilgrim-input", true)
    $("body").addClass("pilgrim-open").data("pilgrim", pilgrim)


  $(window).on "pilgrim:destroy", ->
    pilgrim = $("body").data("pilgrim")
    pilgrim.destroy()
    $("body").removeData("pilgrim").removeClass("pilgrim-open")


  $(window).on "click", (event)->
    $target = $(event.target)

    isPilgrimOpen = $("body").hasClass("pilgrim-open")
    isPilgrimElement = $target.hasClass("pilgrim")
    isPilgrimInput = $target.data("pilgrim-input")
    isChildOfPilgrimElement = $target.closest(".pilgrim").length > 0
    isElementInDom = $target.closest("body").length > 0

    console.log isPilgrimOpen, isPilgrimElement, isPilgrimInput, isChildOfPilgrimElement && isElementInDom
    if isPilgrimOpen && !isPilgrimElement && !isPilgrimInput && !isChildOfPilgrimElement && isElementInDom
      $(window).trigger "pilgrim:destroy"


# Start the engines
$("input").pilgrim()
