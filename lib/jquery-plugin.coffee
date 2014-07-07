$.fn.datepicker = (options={})->

  @on "focusin", (event)->
    $ele = $(this)
    options.initialValue = $ele.val() if $ele.val().trim().length != 0

    pilgrim = $("body").data("pilgrim") || new Pilgrim($ele, options)
    $ele.data("pilgrim-input", true)
    $("body").addClass("pilgrim-open").data("pilgrim", pilgrim)


  $(window).on "datepicker:destroy", ->
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
      $(window).trigger "datepicker:destroy"
