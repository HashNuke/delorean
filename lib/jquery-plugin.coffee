$.fn.datepicker = (options={})->

  @on "focusin", (event)->
    $ele = $(this)
    datepicker = $ele.data("datepicker") || new Datepicker($ele, options)
    $ele.addClass("datepicker-input").data("datepicker", datepicker)


  $(window).on "datepicker:destroy", ->
    $datepicker = $(".datepicker-input")
    return if $datepicker.length == 0
    datepicker = $datepicker.data("datepicker")
    datepicker.destroy()
    $datepicker.removeData("datepicker").removeClass("datepicker-input")


  $(window).on "click", (event)->
    $target = $(event.target)

    isDatepickerOpen = $(".datepicker-input").length != 0
    isDatepickerElement = $target.hasClass("datepicker")
    isDatepickerInput = $target.hasClass("datepicker-input")
    isChildOfDatepickerElement = $target.closest(".datepicker").length > 0
    isElementInDom = $target.closest("body").length > 0

    if isDatepickerOpen && !isDatepickerElement && !isDatepickerInput && !isChildOfDatepickerElement && isElementInDom
      $(window).trigger "datepicker:destroy"
