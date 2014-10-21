$.fn.datepicker = (options={})->


  @on "focusin", (event)->
    $ele = $(this)
    datepicker = $ele.data("datepicker") || new Datepicker($ele, options)
    $ele.addClass("datepicker-input").data("datepicker", datepicker)


  globalDatepickerClickDestroy = (event)->
    $target = $(event.target)

    isDatepickerOpen = $(".datepicker-input").length != 0
    isDatepickerElement = $target.hasClass("datepicker")
    isDatepickerInput = $target.hasClass("datepicker-input")
    isChildOfDatepickerElement = $target.closest(".datepicker").length > 0
    isElementInDom = $target.closest("body").length > 0

    if isDatepickerOpen && !isDatepickerElement && !isDatepickerInput && !isChildOfDatepickerElement && isElementInDom
      $(window).trigger "datepicker:destroy"


  globalDatepickerKeyDestroy = (event)->
    $target = $(event.target)
    keyCode = event.keyCode || event.which

    isTabPressed   = keyCode == 9
    isEnterPressed = keyCode == 13
    isShiftPressed = event.shiftKey
    isDatepickerInput = $target.hasClass("datepicker-input")

    # console.log isDatepickerInput, isEnterPressed, isTabPressed
    if isDatepickerInput && isEnterPressed
      $(window).trigger "datepicker:destroy", 0


    console.log isTabPressed, isDatepickerInput, $(".datepicker-input").length > 1
    if isTabPressed && isDatepickerInput && $(".datepicker-input").length > 1
      index = if isShiftPressed then 1 else 0
      console.log "send:destroy"
      $(window).trigger "datepicker:destroy", index
      return


  $(window).on "datepicker:destroy", (event, index)->
    index = 0 if !index?

    debugger
    $datepicker = $(".datepicker-input").eq(index)
    if $datepicker? && $datepicker.length != 0
      datepicker = $datepicker.data("datepicker")
      datepicker.destroy()
      $datepicker.removeData("datepicker").removeClass("datepicker-input")
    $(window).off("click", globalDatepickerClickDestroy)
    $(window).off("keyup", globalDatepickerKeyDestroy)


  $(window).on "click", globalDatepickerClickDestroy
  $(window).on "keyup", globalDatepickerKeyDestroy
