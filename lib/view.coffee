class @Datepicker.View
  constructor: (@datepicker, startingView)->
    @layout()
    if startingView == "days"
      days = @datepicker.days(@datepicker.value.year, @datepicker.value.month)
      @daysView @datepicker.value.year, @datepicker.value.month, days
    else if startingView == "months"
      @monthsView @datepicker.value.year, @datepicker.months(@datepicker.value.year)
    else
      @yearsView @datepicker.years()


  destroy: -> @$root.remove()


  reposition: ->
    visibleTopOffset    = @datepicker.$input.offset().top - $(window).scrollTop()
    visibleBottomOffset = $(window).height() - (visibleTopOffset + @datepicker.$input.outerHeight())

    if visibleBottomOffset < 0
      visibleBottomOffset *= -1

    offsetLeft = @datepicker.$input.offset().left
    if visibleTopOffset > visibleBottomOffset
      offsetTop = @datepicker.$input.offset().top - @$root.outerHeight()
    else
      offsetTop = @datepicker.$input.offset().top + @datepicker.$input.outerHeight()

    @$root.css(top: offsetTop, left: offsetLeft)


  layout: ->
    @$root    = $("<div/>").addClass("datepicker")
    @$header  = $("<div/>").addClass("datepicker-header")
    @$content = $("<div/>").addClass("datepicker-content")
    @bindEvents()

    @$root.append(@$header).append(@$content)
    $("body").append @$root


  bindEvents: ->
    @$root.on "click", ".valid-year", (event)=>
      year = $(event.target).data("year")
      @monthsView year, @datepicker.months(year)

    @$root.on "click", ".change-year", (event)=>
      year  = $(event.target).data("year")
      @yearsView @datepicker.years(year)

    @$root.on "click", ".year-nav", (event)=>
      year = $(event.target).data("year")
      @yearsView @datepicker.years(year)

    @$root.on "click", ".change-month", (event)=>
      year  = $(event.target).data("year")
      @monthsView year, @datepicker.months(year)

    @$root.on "click", ".valid-month", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      @daysView year, month, @datepicker.days(year, month)

    @$root.on "click", ".valid-day", (event)=>
      year  = $(event.target).data("year")
      month = $(event.target).data("month")
      day   = $(event.target).data("day")
      @datepicker.setValue year, month, day
      inputValue = @datepicker.format()
      @datepicker.$input.val inputValue
      @datepicker.$input.trigger "datepicker:selected", [inputValue]
      $(window).trigger "datepicker:destroy"


  yearsView: (years)->
    @$content.empty()
    @$header.empty()

    if years.length == 1
      @$header.append $("<span/>").html(years[0].year)
    else
      yearRange = "#{years[0].year} - #{years[years.length-1].year}"
      @$header.append $("<span/>").html(yearRange)


    for yearInfo, index in years
      if [0, 2, 5, 8].indexOf(index) != -1
        @$content.append $("<div/>").addClass("datepicker-row")
      @$content.children().last().append @buildYear(yearInfo)


    if @datepicker.isValidYear(years[0].year - 1)
      @$content.children()
        .first()
        .prepend @buildYearNav(years[0].year - 1, "&laquo; prev")
    else
      @$content.children()
        .first()
        .prepend @buildYearNavDisabled("&laquo; prev")

    if @datepicker.isValidYear(years[years.length-1].year + 1)
      @$content.children()
        .last()
        .append @buildYearNav(years[years.length-1].year + 1, "next &raquo;")
    else
      @$content.children()
        .last()
        .append @buildYearNavDisabled("next &raquo;")

    @reposition()


  monthsView: (year, months)->
    @$content.empty()
    @$header.empty()
    @$header.append @yearHeaderNav(year)

    for monthInfo, index in months
      if index % 3 == 0
        @$content.append $("<div/>").addClass("datepicker-row")
      @$content.children().last().append @buildMonth(year, monthInfo)
    @reposition()


  daysView: (year, month, days)->
    @$content.empty()
    @$header.empty()
    @$header.append @monthHeaderNav(year, month)
    @$header.append @yearHeaderNav(year)

    @$content.append $("<div/>").addClass("datepicker-row").addClass("datepicker-weekdays")
    for dayInfo in days[0..6]
      weekdayName = @datepicker.shortWeekdayName(dayInfo.weekdayId)
      $weekday = $("<div/>").addClass("weekday").html weekdayName
      @$content.children().last().append $weekday

    for dayInfo in days
      @$content.append @buildDay(year, month, dayInfo)
    @reposition()


  buildYearNavDisabled: (text)->
    $("<div/>").addClass("year-nav").addClass('invalid-year').html(text)


  buildYearNav: (navYear, text)->
    $("<div/>").addClass("year-nav")
      .data(year: navYear)
      .html(text)


  buildYear: (yearInfo)->
    $year = $("<div/>")
            .addClass("year")
            .data({year: yearInfo.year})
            .html(yearInfo.year)
    if yearInfo.current && @datepicker.options.highlightToday then $year.addClass("current")
    if yearInfo.selected then $year.addClass("selected")
    if !yearInfo.disabled
      $year.addClass("valid-year")
    else
      $year.addClass("invalid-year")


  buildMonth: (year, monthInfo)->
    $month = $("<div/>")
            .addClass("month")
            .data({year: year, month: monthInfo.month})
            .html(monthInfo.monthName)
    if monthInfo.current && @datepicker.options.highlightToday then $month.addClass("current")
    if monthInfo.selected then $month.addClass("selected")
    if !monthInfo.disabled
      $month.addClass("valid-month")
    else
      $month.addClass("invalid-month")


  buildDay: (year, month, dayInfo)->
    $day = $("<div/>")
          .addClass("day")
          .data({year: year, month: month, day: dayInfo.day})
          .html(dayInfo.day)
    if dayInfo.selected then $day.addClass("selected")
    if dayInfo.current && @datepicker.options.highlightToday then $day.addClass("current")
    if dayInfo.selectableMonth && !dayInfo.disabled
      $day.addClass("valid-day")
    else
      $day.addClass("invalid-day")


  yearHeaderNav: (year)->
    $("<span/>").addClass("change-year")
      .data(year: year)
      .text(year)


  monthHeaderNav: (year, month)->
    $("<span/>").addClass("change-month")
      .data(year: year)
      .text(@datepicker.lang.months[month].long)
