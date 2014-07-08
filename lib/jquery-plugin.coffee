$.fn.datepicker = (options={})->

  @on "focusin", (event)->
    $ele = $(this)
    options.initialValue = $ele.val() if $ele.val().trim().length != 0

    datepicker = $("body").data("datepicker") || new Datepicker($ele, options)
    $ele.data("datepicker-input", true)
    $("body").addClass("datepicker-open").data("datepicker", datepicker)


  $(window).on "datepicker:destroy", ->
    datepicker = $("body").data("datepicker")
    datepicker.destroy()
    $("body").removeData("datepicker").removeClass("datepicker-open")


  $(window).on "click", (event)->
    $target = $(event.target)

    isDatepickerOpen = $("body").hasClass("datepicker-open")
    isDatepickerElement = $target.hasClass("datepicker")
    isDatepickerInput = $target.data("datepicker-input")
    isChildOfDatepickerElement = $target.closest(".datepicker").length > 0
    isElementInDom = $target.closest("body").length > 0

    console.log isDatepickerOpen, isDatepickerElement, isDatepickerInput, isChildOfDatepickerElement && isElementInDom
    if isDatepickerOpen && !isDatepickerElement && !isDatepickerInput && !isChildOfDatepickerElement && isElementInDom
      $(window).trigger "datepicker:destroy"
