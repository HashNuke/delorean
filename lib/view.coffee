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
      .prepend @buildYearNav(years[0].year - 1, "&laquo; prev")
    @$content.children()
      .last()
      .append @buildYearNav(years[years.length-1].year + 1, "next &raquo;")


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
    $("<div/>").addClass("year-nav")
      .data(year: navYear)
      .html(text)


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
