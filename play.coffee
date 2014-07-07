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
    @setDefaultsIfNecessary()
    @lang = @getLocale(@options["locale"])
    @currentDate = new Date()
    @view = new Pilgrim.View(@)


  destroy: ->
    @view.destroy()
    delete @currentDate
    delete @lang
    delete @view


  setDefaultsIfNecessary: ->
    @options["locale"] ||= "en"
    @options["format"] ||= "%y/%-m/%-d"


  years: (yearOptions={})->
    currentYear  = @currentDate.getFullYear()
    selectedYear = if yearOptions.selectedYear? then yearOptions.selectedYear else currentYear
    startingYear = selectedYear - (selectedYear % 10) + 1
    endingYear   = startingYear + 9

    for year in [startingYear..endingYear]
      {
        year:     year
        current:  currentYear == year
        selected: selectedYear == year
      }


  months: (monthOptions={})->
    currentMonth  = @currentDate.getMonth()
    selectedMonth = if monthOptions.selectedMonth? then monthOptions.selectedMonth else currentMonth
    for monthLocale, index in @lang.months
      {
        month:     index
        monthName: monthLocale.short
        current:   currentMonth == index
        selected:  selectedMonth == index
      }


  shortWeekdayName: (weekdayId)->
    return @lang.days[weekdayId].short if @lang.days[weekdayId]?


  getLocale: (languageCode)->
    return Pilgrim.Locale[languageCode] if Pilgrim.Locale[languageCode]?
    throw new Pilgrim.Error("Locale not available")


  days: (year, month)->
    currentDay = @currentDate.getDate()
    numberOfDaysInCurrentMonth  = @numberOfDaysInMonth(year, month)
    numberOfDaysInPreviousMonth = @numberOfDaysInMonth(year, month - 1)
    numberOfDaysInNextMonth     = @numberOfDaysInMonth(year, month + 1)

    weekdayIdOfFirstDay = new Date(year, month, 1).getDay()
    weekdayIdOfLastDay  = new Date(year, month, numberOfDaysInCurrentMonth).getDay()
    daysToDisplayForNextMonth = 7 - weekdayIdOfLastDay

    # Because we have to start from the first Sunday to the last Saturday
    # to fill up the calendar
    daysForView = [(1 - weekdayIdOfFirstDay)...(numberOfDaysInCurrentMonth + daysToDisplayForNextMonth)]

    for dayNumber in daysForView
      weekdayId = (dayNumber + weekdayIdOfFirstDay - 1) % 7

      currentMonth = false
      day = if dayNumber > numberOfDaysInCurrentMonth
              dayNumber - numberOfDaysInNextMonth
            else if dayNumber < 1
              numberOfDaysInPreviousMonth + dayNumber
            else if dayNumber > 0
              currentMonth = true
              today = true if @currentDate.getDate() == dayNumber
              dayNumber

      {
        day:          day
        weekdayId:    weekdayId
        currentMonth: currentMonth
        currentDay:   (currentMonth && currentDay == day)
      }


  setValue: (year, month, day)->
    @value.year  = year
    @value.month = month
    @value.day   = day
    formatter = new Pilgrim.Formatter(@options.format, @value)
    @$input.val formatter.format()
    $(document).trigger "pilgrim:destroy"


  numberOfDaysInMonth: (year, month)->
    new Date(year, month + 1, 0).getDate()



class @Pilgrim.Formatter
  constructor: (@formatString, @dateParts)->

  format: ->
    outputValue = @formatString
    for formatString in ["%y", "%Y", "%m", "%-m", "%d", "%-d"]
      outputValue = @substituteFormatter(formatString, outputValue)
    outputValue

  padZero = (n)->
    if n < 10 then "0#{n}" else "#{n}"

  substituteFormatter: (formatString, inputString)->
    switch formatString
      when "%y"  then inputString.replace formatString, @dateParts.year
      when "%Y"  then inputString.replace formatString, "#{@dateParts.year}".substring(2,4)
      when "%m"  then inputString.replace formatString, @dateParts.month+1
      when "%-m" then inputString.replace formatString, padZero(@dateParts.month+1)
      when "%d"  then inputString.replace formatString, @dateParts.day
      when "%-d" then inputString.replace formatString, padZero(@dateParts.day)


class @Pilgrim.Error
  name: "Pilgrim.Error"
  constructor: (@message)->


class @Pilgrim.View
  constructor: (@pilgrim)->
    @layout()
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

    @$root.on "click", ".month", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      @daysView year, month, @pilgrim.days(year, month)

    @$root.on "click", ".valid-day", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      day = $(event.target).data("day")
      @pilgrim.setValue year, month, day

    @$root.on "click", ".change-month", (event)=>
      year  = $(event.target).data("year")
      @monthsView year, @pilgrim.months(year)

    @$root.on "click", ".change-year", (event)=>
      @yearsView @pilgrim.months(year)


  yearsView: (years)->
    @$content.empty()
    @$header.append $("<span/>").text("Select a year")


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

    for monthInfo, index in months
      if index % 4 == 0
        @$content.append $("<div/>").addClass("pilgrim-row")
      @$content.children().last().append @buildMonth(year, monthInfo)


  daysView: (year, month, days)->
    @$content.empty()

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
    if yearInfo.current then $year.addClass("current") else $year


  buildMonth: (year, monthInfo)->
    $month = $("<div/>")
            .addClass("month")
            .data({year: year, month: monthInfo.month})
            .html(monthInfo.monthName)
    if monthInfo.current then $month.addClass("current") else $month


  buildDay: (year, month, dayInfo)->
    $day = $("<div/>")
          .addClass("day")
          .data({year: year, month: month, day: dayInfo.day})
          .html(dayInfo.day)
    if dayInfo.currentDay then $day.addClass("current")
    if dayInfo.currentMonth == true
      $day.addClass("valid-day")
    else
      $day.addClass("invalid-day")
    $day


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
    # Decide which options to use: from attributes or from function args?
    pilgrim = $("body").data("pilgrim") || new Pilgrim($(this))
    $(this).data("pilgrim-input", true)
    $("body").addClass("pilgrim-open").data("pilgrim", pilgrim)


  $(document).on "pilgrim:destroy", ->
    pilgrim = $("body").data("pilgrim")
    pilgrim.destroy()
    $("body").removeData("pilgrim").removeClass("pilgrim-open")


  $(document).on "click", (event)->
    $target = $(event.target)

    isPilgrimOpen = $("body").hasClass("pilgrim-open")
    isPilgrimElement = $target.hasClass("pilgrim")
    isPilgrimInput = $target.data("pilgrim-input")
    isChildOfPilgrimElement = $target.parents(".pilgrim").length > 0
    isElementInDom = $target.closest("body").length > 0

    if isPilgrimOpen && !isPilgrimElement && !isPilgrimInput && !isChildOfPilgrimElement && isElementInDom
      $(document).trigger "pilgrim:destroy"


# Start the engines
$("input").pilgrim()
