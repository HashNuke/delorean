$.fn.datepicker = (options={})->


  @on "focusin", (event)=>
    $ele = $(this)

    # destroy any other datepicker
    currentDatepickerId = $(window).data('current-datepicker-id')
    if currentDatepickerId?
      $(window).trigger "datepicker:destroy"

    uniqueId = "delorean-#{new Date().getUTCMilliseconds()}"
    datepicker = $ele.data("datepicker") || new Datepicker($ele, options)
    $ele.addClass("datepicker-input")
        .data("datepicker", datepicker)
        .addClass("#{uniqueId}")
    $(window).data('current-datepicker-id', uniqueId)


  # destroy datepicker when enter key is pressed in the input box
  @on "keypress", (event)->
    keyCode = event.keyCode || event.which
    if keyCode == 13
      $(window).trigger "datepicker:destroy"


  destroyDatepickerOnTabPress = (event)->
    keyCode = event.keyCode || event.which
    isDatepickerInput = $(event.target).hasClass("datepicker-input")

    if keyCode == 9 && !isDatepickerInput
      $(window).trigger "datepicker:destroy"



  $(window).on "datepicker:destroy", (event)=>
    currentDatepickerId = $(window).data('current-datepicker-id')
    $datepicker = $(".#{currentDatepickerId}")
    if $datepicker.length > 0
      datepicker = $datepicker.data("datepicker")
      datepicker.destroy()
      $datepicker.removeData("datepicker")
                 .removeClass("datepicker-input")
                 .removeClass("#{currentDatepickerId}")
      $(window).off "click", destroyDatepickerOnTabPress


  $(window).on "click", (event)->
    $target = $(event.target)

    isDatepickerOpen = $(".datepicker-input").length != 0
    isDatepickerElement = $target.hasClass("datepicker")
    isDatepickerInput = $target.hasClass("datepicker-input")
    isChildOfDatepickerElement = $target.closest(".datepicker").length > 0
    isElementInDom = $target.closest("body").length > 0

    if isDatepickerOpen && !isDatepickerElement && !isDatepickerInput && !isChildOfDatepickerElement && isElementInDom
      $(window).trigger "datepicker:destroy"


  $(window).on "keyup", destroyDatepickerOnTabPress
