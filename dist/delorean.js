// Generated by CoffeeScript 1.7.1
(function() {
  this.Datepicker = (function() {
    var numberOfDaysInMonth;

    Datepicker.prototype.regex = {
      dateRange: /^[\-+]\d+[dmwy]([\s,]+[\-+]\d+[dmwy])*$/,
      dateRangePartMatch: /([\-+]\d+)([dmwy])/,
      dateRangeParts: /([\-+]\d+)([dmwy])/g
    };

    Datepicker.prototype.value = {};

    function Datepicker($input, options) {
      this.$input = $input;
      this.options = options != null ? options : {};
      this.currentDate = new Date();
      this._setDefaultOptions();
      this._setInitialValue();
      this._parseInitialValue();
      if (this.options.startDate != null) {
        this.startDate = this.parseRange(this.options.startDate);
      }
      if (this.options.endDate != null) {
        this.endDate = this.parseRange(this.options.endDate);
      }
      this._setDefaultDateIfNecessary();
      this.lang = this.getLocale(this.options["locale"]);
      this.view = new Datepicker.View(this, this.options.startingView);
    }

    Datepicker.prototype._setInitialValue = function() {
      if (this.$input.val().trim().length !== 0) {
        return this.options.initialValue = this.$input.val().trim();
      } else {
        delete this.options.initialValue;
        return this.value = {};
      }
    };

    Datepicker.prototype.parseRange = function(range) {
      var date, moveBy, moveRange, part, parts, _i, _len, _matched_value, _ref;
      if (!this.regex.dateRange.test(range)) {
        return;
      }
      parts = range.match(this.regex.dateRangeParts);
      date = new Date();
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        _ref = this.regex.dateRangePartMatch.exec(part), _matched_value = _ref[0], moveBy = _ref[1], moveRange = _ref[2];
        moveBy = parseInt(moveBy, 10);
        switch (moveRange) {
          case 'd':
            date.setUTCDate(date.getUTCDate() + moveBy);
            break;
          case 'w':
            date.setUTCDate(date.getUTCDate() + moveBy * 7);
            break;
          case 'm':
            date = this._moveMonth(date, moveBy);
            break;
          case 'y':
            date = this._moveMonth(date, moveBy * 12);
        }
      }
      return {
        year: date.getUTCFullYear(),
        month: date.getUTCMonth(),
        day: date.getUTCDate()
      };
    };

    Datepicker.prototype._moveMonth = function(date, moveBy) {
      var day, i, magnitude, month, newDate, newMonth, testFunction, _i;
      newDate = new Date(date.valueOf());
      day = newDate.getUTCDate();
      month = newDate.getUTCMonth();
      magnitude = Math.abs(moveBy);
      moveBy = moveBy > 0 ? 1 : -1;
      if (magnitude === 1) {
        if (moveBy === -1) {
          testFunction = function() {
            return newDate.getUTCMonth() === month;
          };
        } else {
          testFunction = function() {
            return newDate.getUTCMonth() !== newMonth;
          };
        }
        newMonth = month + moveBy;
        newDate.setUTCMonth(newMonth);
        if (newMonth < 0 || newMonth > 11) {
          newMonth = (newMonth + 12) % 12;
        }
      } else {
        for (i = _i = 0; 0 <= magnitude ? _i < magnitude : _i > magnitude; i = 0 <= magnitude ? ++_i : --_i) {
          newDate = this._moveMonth(newDate, moveBy);
        }
        newMonth = newDate.getUTCMonth();
        newDate.setUTCDate(day);
        testFunction = function() {
          return newDate.getUTCMonth() !== newMonth;
        };
      }
      while (testFunction()) {
        newDate.setUTCDate(--day);
        newDate.setUTCMonth(newMonth);
      }
      return newDate;
    };

    Datepicker.prototype._setDefaultDateIfNecessary = function() {
      var _base, _base1;
      if (this.options.startingView === "months" || this.options.startingView === "days") {
        (_base = this.value).year || (_base.year = this.currentDate.getFullYear());
      }
      if (this.options.startingView === "days") {
        return (_base1 = this.value).month || (_base1.month = this.currentDate.getMonth());
      }
    };

    numberOfDaysInMonth = function(year, month) {
      return new Date(year, month + 1, 0).getDate();
    };

    Datepicker.prototype.destroy = function() {
      this.view.destroy();
      delete this.currentDate;
      delete this.lang;
      return delete this.view;
    };

    Datepicker.prototype._setDefaultOptions = function() {
      var _base, _base1, _base2, _base3, _base4;
      (_base = this.options)["locale"] || (_base["locale"] = "en");
      (_base1 = this.options)["format"] || (_base1["format"] = "yyyymmdd");
      (_base2 = this.options)["separator"] || (_base2["separator"] = "/");
      (_base3 = this.options)["startingView"] || (_base3["startingView"] = "years");
      return (_base4 = this.options)["highlightToday"] || (_base4["highlightToday"] = false);
    };

    Datepicker.prototype.years = function(yearAmongRange) {
      var currentYear, endingYear, startingYear, year, _i, _results;
      if ((this.startDate != null) && yearAmongRange < this.startDate.year) {
        throw new Datepicker.Error("Year is less than range");
      }
      if ((this.endDate != null) && yearAmongRange > this.endDate.year) {
        throw new Datepicker.Error("Year is greater than range");
      }
      currentYear = this.currentDate.getFullYear();
      yearAmongRange || (yearAmongRange = this.value.year ? this.value.year : (this.startDate != null) && currentYear < this.startDate.year ? this.startDate.year : (this.endDate != null) && currentYear > this.endDate.year ? this.endDate.year : currentYear);
      startingYear = yearAmongRange - (yearAmongRange % 10);
      endingYear = startingYear + 9;
      _results = [];
      for (year = _i = startingYear; startingYear <= endingYear ? _i <= endingYear : _i >= endingYear; year = startingYear <= endingYear ? ++_i : --_i) {
        _results.push({
          year: year,
          current: currentYear === year,
          selected: this.value.year === year,
          disabled: this.isDisabledYear(year)
        });
      }
      return _results;
    };

    Datepicker.prototype.isDisabledYear = function(year) {
      if ((this.startDate != null) && year < this.startDate.year) {
        return true;
      }
      if ((this.endDate != null) && year > this.endDate.year) {
        return true;
      }
      return false;
    };

    Datepicker.prototype.isDisabledMonth = function(year, month) {
      if (this.isDisabledYear(year)) {
        return true;
      }
      if ((this.startDate != null) && this.isDisabledYear(year - 1) && month < this.startDate.month) {
        return true;
      }
      if ((this.endDate != null) && this.isDisabledYear(year + 1) && month > this.endDate.month) {
        return true;
      }
      return false;
    };

    Datepicker.prototype.isDisabledDay = function(year, month, day) {
      if (this.isDisabledMonth(year, month)) {
        return true;
      }
      if ((this.startDate != null) && this.isDisabledMonth(year, month - 1) && day < this.startDate.day) {
        return true;
      }
      if ((this.endDate != null) && this.isDisabledMonth(year, month + 1) && day > this.endDate.day) {
        return true;
      }
      return false;
    };

    Datepicker.prototype.months = function(year) {
      var currentMonth, currentYear, index, monthLocale, selectedMonth, _i, _len, _ref, _results;
      currentMonth = this.currentDate.getMonth();
      currentYear = this.currentDate.getFullYear();
      selectedMonth = this.value.month != null ? this.value.month : currentMonth;
      _ref = this.lang.months;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        monthLocale = _ref[index];
        _results.push({
          month: index,
          monthName: monthLocale.short,
          current: currentMonth === index && currentYear === year,
          selected: selectedMonth === index && this.value.year === year,
          disabled: this.isDisabledMonth(year, index)
        });
      }
      return _results;
    };

    Datepicker.prototype.shortWeekdayName = function(weekdayId) {
      if (this.lang.days[weekdayId] != null) {
        return this.lang.days[weekdayId].short;
      }
    };

    Datepicker.prototype.getLocale = function(languageCode) {
      if (Datepicker.Locale[languageCode] != null) {
        return Datepicker.Locale[languageCode];
      }
      throw new Datepicker.Error("Locale not available");
    };

    Datepicker.prototype.days = function(year, month) {
      var current, currentDay, currentMonth, currentYear, day, dayNumber, dayRangeEnd, dayRangeStart, daysForView, daysToDisplayForNextMonth, disabled, numberOfDaysInCurrentMonth, numberOfDaysInNextMonth, numberOfDaysInPreviousMonth, selectableMonth, selected, weekdayId, weekdayIdOfFirstDay, weekdayIdOfLastDay, _i, _j, _len, _results, _results1;
      currentYear = this.currentDate.getFullYear();
      currentMonth = this.currentDate.getMonth();
      currentDay = this.currentDate.getDate();
      numberOfDaysInCurrentMonth = numberOfDaysInMonth(year, month);
      numberOfDaysInPreviousMonth = numberOfDaysInMonth(year, month - 1);
      numberOfDaysInNextMonth = numberOfDaysInMonth(year, month + 1);
      weekdayIdOfFirstDay = new Date(year, month, 1).getDay();
      weekdayIdOfLastDay = new Date(year, month, numberOfDaysInCurrentMonth).getDay();
      daysToDisplayForNextMonth = 6 - weekdayIdOfLastDay;
      dayRangeStart = 1 - weekdayIdOfFirstDay;
      dayRangeEnd = numberOfDaysInCurrentMonth + daysToDisplayForNextMonth;
      daysForView = (function() {
        _results = [];
        for (var _i = dayRangeStart; dayRangeStart <= dayRangeEnd ? _i <= dayRangeEnd : _i >= dayRangeEnd; dayRangeStart <= dayRangeEnd ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      _results1 = [];
      for (_j = 0, _len = daysForView.length; _j < _len; _j++) {
        dayNumber = daysForView[_j];
        weekdayId = (dayNumber + weekdayIdOfFirstDay - 1) % 7;
        selectableMonth = false;
        day = dayNumber > numberOfDaysInCurrentMonth ? dayNumber - numberOfDaysInCurrentMonth : dayNumber < 1 ? numberOfDaysInPreviousMonth + dayNumber : dayNumber > 0 ? (selectableMonth = true, dayNumber) : void 0;
        selected = this.value.year === year && this.value.month === month && this.value.day === day && selectableMonth;
        current = currentYear === year && currentMonth === month && currentDay === day;
        disabled = this.isDisabledDay(year, month, day);
        _results1.push({
          day: day,
          weekdayId: weekdayId,
          selected: selected,
          current: current,
          selectableMonth: selectableMonth,
          disabled: disabled
        });
      }
      return _results1;
    };

    Datepicker.prototype.setValue = function(year, month, day) {
      this.value.year = year;
      this.value.month = month;
      return this.value.day = day;
    };

    Datepicker.prototype._padZero = function(n) {
      if (n < 10) {
        return "0" + n;
      } else {
        return "" + n;
      }
    };

    Datepicker.prototype.format = function() {
      switch (this.options.format) {
        case "yyyymmdd":
          return [this.value.year, this._padZero(this.value.month + 1), this._padZero(this.value.day)].join(this.options.separator);
        case "ddmmyyyy":
          return [this._padZero(this.value.day), this._padZero(this.value.month + 1), this.value.year].join(this.options.separator);
        case "mmddyyyy":
          return [this._padZero(this.value.month + 1), this._padZero(this.value.day), this.value.year].join(this.options.separator);
        default:
          return new Datepicker.Error("Invalid format string");
      }
    };

    Datepicker.prototype._parseInitialValue = function() {
      var dateParts;
      if ((this.options.initialValue == null) || this.options.initialValue.trim().length === 0) {
        return;
      }
      dateParts = this.options.initialValue.split(this.options.separator);
      switch (this.options.format) {
        case "yyyymmdd":
          return this.setValue(parseInt(dateParts[0], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[2], 10));
        case "ddmmyyyy":
          return this.setValue(parseInt(dateParts[2], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[0], 10));
        case "mmddyyyy":
          return this.setValue(parseInt(dateParts[2], 10), parseInt(dateParts[0], 10) - 1, parseInt(dateParts[1], 10));
        default:
          return new Datepicker.Error("Initial value is of unknown format");
      }
    };

    return Datepicker;

  })();

  this.Datepicker.Error = (function() {
    Error.prototype.name = "Datepicker.Error";

    function Error(message) {
      this.message = message;
    }

    return Error;

  })();

  this.Datepicker.Locale = (function() {
    function Locale() {}

    Locale.en = {
      months: [
        {
          short: "Jan",
          long: "January"
        }, {
          short: "Feb",
          long: "February"
        }, {
          short: "Mar",
          long: "March"
        }, {
          short: "Apr",
          long: "April"
        }, {
          short: "May",
          long: "May"
        }, {
          short: "Jun",
          long: "June"
        }, {
          short: "Jul",
          long: "July"
        }, {
          short: "Aug",
          long: "August"
        }, {
          short: "Sep",
          long: "September"
        }, {
          short: "Oct",
          long: "October"
        }, {
          short: "Nov",
          long: "November"
        }, {
          short: "Dec",
          long: "December"
        }
      ],
      days: [
        {
          short: "Su"
        }, {
          short: "Mo"
        }, {
          short: "Tu"
        }, {
          short: "We"
        }, {
          short: "Th"
        }, {
          short: "Fr"
        }, {
          short: "Sa"
        }
      ]
    };

    return Locale;

  })();

  this.Datepicker.View = (function() {
    function View(datepicker, startingView) {
      var days;
      this.datepicker = datepicker;
      this.layout();
      if (startingView === "days") {
        days = this.datepicker.days(this.datepicker.value.year, this.datepicker.value.month);
        this.daysView(this.datepicker.value.year, this.datepicker.value.month, days);
      } else if (startingView === "months") {
        this.monthsView(this.datepicker.value.year, this.datepicker.months(this.datepicker.value.year));
      } else {
        this.yearsView(this.datepicker.years());
      }
    }

    View.prototype.destroy = function() {
      return this.$root.remove();
    };

    View.prototype.reposition = function() {
      var offsetLeft, offsetTop, visibleBottomOffset, visibleTopOffset;
      visibleTopOffset = this.datepicker.$input.offset().top - $(window).scrollTop();
      visibleBottomOffset = $(window).height() - (visibleTopOffset + this.datepicker.$input.outerHeight());
      if (visibleBottomOffset < 0) {
        visibleBottomOffset *= -1;
      }
      offsetLeft = this.datepicker.$input.offset().left;
      if (visibleTopOffset > visibleBottomOffset) {
        offsetTop = this.datepicker.$input.offset().top - this.$root.outerHeight();
      } else {
        offsetTop = this.datepicker.$input.offset().top + this.datepicker.$input.outerHeight();
      }
      return this.$root.css({
        top: offsetTop,
        left: offsetLeft
      });
    };

    View.prototype.layout = function() {
      this.$root = $("<div/>").addClass("datepicker");
      this.$header = $("<div/>").addClass("datepicker-header");
      this.$content = $("<div/>").addClass("datepicker-content");
      this.bindEvents();
      this.$root.append(this.$header).append(this.$content);
      return $("body").append(this.$root);
    };

    View.prototype.bindEvents = function() {
      this.$root.on("click", ".valid-year", (function(_this) {
        return function(event) {
          var year;
          year = $(event.target).data("year");
          return _this.monthsView(year, _this.datepicker.months(year));
        };
      })(this));
      this.$root.on("click", ".change-year", (function(_this) {
        return function(event) {
          var year;
          year = $(event.target).data("year");
          return _this.yearsView(_this.datepicker.years(year));
        };
      })(this));
      this.$root.on("click", ".year-nav", (function(_this) {
        return function(event) {
          var year;
          year = $(event.target).data("year");
          return _this.yearsView(_this.datepicker.years(year));
        };
      })(this));
      this.$root.on("click", ".change-month", (function(_this) {
        return function(event) {
          var year;
          year = $(event.target).data("year");
          return _this.monthsView(year, _this.datepicker.months(year));
        };
      })(this));
      this.$root.on("click", ".valid-month", (function(_this) {
        return function(event) {
          var month, year;
          year = $(event.target).data("year");
          month = $(event.target).data("month");
          return _this.daysView(year, month, _this.datepicker.days(year, month));
        };
      })(this));
      return this.$root.on("click", ".valid-day", (function(_this) {
        return function(event) {
          var day, inputValue, month, year;
          year = $(event.target).data("year");
          month = $(event.target).data("month");
          day = $(event.target).data("day");
          _this.datepicker.setValue(year, month, day);
          inputValue = _this.datepicker.format();
          _this.datepicker.$input.val(inputValue);
          _this.datepicker.$input.trigger("datepicker:selected", [inputValue]);
          return $(window).trigger("datepicker:destroy");
        };
      })(this));
    };

    View.prototype.yearsView = function(years) {
      var index, yearInfo, yearRange, _i, _len;
      this.$content.empty();
      this.$header.empty();
      if (years.length === 1) {
        this.$header.append($("<span/>").html(years[0].year));
      } else {
        yearRange = "" + years[0].year + " - " + years[years.length - 1].year;
        this.$header.append($("<span/>").html(yearRange));
      }
      for (index = _i = 0, _len = years.length; _i < _len; index = ++_i) {
        yearInfo = years[index];
        if ([0, 2, 5, 8].indexOf(index) !== -1) {
          this.$content.append($("<div/>").addClass("datepicker-row"));
        }
        this.$content.children().last().append(this.buildYear(yearInfo));
      }
      if (!years[0].disabled) {
        this.$content.children().first().prepend(this.buildYearNav(years[0].year - 1, "&laquo; prev"));
      }
      if (!years[years.length - 1].disabled) {
        this.$content.children().last().append(this.buildYearNav(years[years.length - 1].year + 1, "next &raquo;"));
      }
      return this.reposition();
    };

    View.prototype.monthsView = function(year, months) {
      var index, monthInfo, _i, _len;
      this.$content.empty();
      this.$header.empty();
      this.$header.append(this.yearHeaderNav(year));
      for (index = _i = 0, _len = months.length; _i < _len; index = ++_i) {
        monthInfo = months[index];
        if (index % 3 === 0) {
          this.$content.append($("<div/>").addClass("datepicker-row"));
        }
        this.$content.children().last().append(this.buildMonth(year, monthInfo));
      }
      return this.reposition();
    };

    View.prototype.daysView = function(year, month, days) {
      var $weekday, dayInfo, weekdayName, _i, _j, _len, _len1, _ref;
      this.$content.empty();
      this.$header.empty();
      this.$header.append(this.monthHeaderNav(year, month));
      this.$header.append(this.yearHeaderNav(year));
      this.$content.append($("<div/>").addClass("datepicker-row").addClass("datepicker-weekdays"));
      _ref = days.slice(0, 7);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dayInfo = _ref[_i];
        weekdayName = this.datepicker.shortWeekdayName(dayInfo.weekdayId);
        $weekday = $("<div/>").addClass("weekday").html(weekdayName);
        this.$content.children().last().append($weekday);
      }
      for (_j = 0, _len1 = days.length; _j < _len1; _j++) {
        dayInfo = days[_j];
        this.$content.append(this.buildDay(year, month, dayInfo));
      }
      return this.reposition();
    };

    View.prototype.buildYearNav = function(navYear, text) {
      return $("<div/>").addClass("year-nav").data({
        year: navYear
      }).html(text);
    };

    View.prototype.buildYear = function(yearInfo) {
      var $year;
      $year = $("<div/>").addClass("year").data({
        year: yearInfo.year
      }).html(yearInfo.year);
      if (yearInfo.current && this.datepicker.options.highlightToday) {
        $year.addClass("current");
      }
      if (yearInfo.selected) {
        $year.addClass("selected");
      }
      if (!yearInfo.disabled) {
        return $year.addClass("valid-year");
      } else {
        return $year.addClass("invalid-year");
      }
    };

    View.prototype.buildMonth = function(year, monthInfo) {
      var $month;
      $month = $("<div/>").addClass("month").data({
        year: year,
        month: monthInfo.month
      }).html(monthInfo.monthName);
      if (monthInfo.current && this.datepicker.options.highlightToday) {
        $month.addClass("current");
      }
      if (monthInfo.selected) {
        $month.addClass("selected");
      }
      if (!monthInfo.disabled) {
        return $month.addClass("valid-month");
      } else {
        return $month.addClass("invalid-month");
      }
    };

    View.prototype.buildDay = function(year, month, dayInfo) {
      var $day;
      $day = $("<div/>").addClass("day").data({
        year: year,
        month: month,
        day: dayInfo.day
      }).html(dayInfo.day);
      if (dayInfo.selected) {
        $day.addClass("selected");
      }
      if (dayInfo.current && this.datepicker.options.highlightToday) {
        $day.addClass("current");
      }
      if (dayInfo.selectableMonth && !dayInfo.disabled) {
        return $day.addClass("valid-day");
      } else {
        return $day.addClass("invalid-day");
      }
    };

    View.prototype.yearHeaderNav = function(year) {
      return $("<span/>").addClass("change-year").data({
        year: year
      }).text(year);
    };

    View.prototype.monthHeaderNav = function(year, month) {
      return $("<span/>").addClass("change-month").data({
        year: year
      }).text(this.datepicker.lang.months[month].long);
    };

    return View;

  })();

  $.fn.datepicker = function(options) {
    if (options == null) {
      options = {};
    }
    this.on("focusin", function(event) {
      var $ele, datepicker;
      $ele = $(this);
      datepicker = $ele.data("datepicker") || new Datepicker($ele, options);
      return $ele.addClass("datepicker-input").data("datepicker", datepicker);
    });
    $(window).on("datepicker:destroy", function() {
      var $datepicker, datepicker;
      $datepicker = $(".datepicker-input");
      if ($datepicker.length === 0) {
        return;
      }
      datepicker = $datepicker.data("datepicker");
      datepicker.destroy();
      return $datepicker.removeData("datepicker").removeClass("datepicker-input");
    });
    return $(window).on("click", function(event) {
      var $target, isChildOfDatepickerElement, isDatepickerElement, isDatepickerInput, isDatepickerOpen, isElementInDom;
      $target = $(event.target);
      isDatepickerOpen = $(".datepicker-input").length !== 0;
      isDatepickerElement = $target.hasClass("datepicker");
      isDatepickerInput = $target.hasClass("datepicker-input");
      isChildOfDatepickerElement = $target.closest(".datepicker").length > 0;
      isElementInDom = $target.closest("body").length > 0;
      if (isDatepickerOpen && !isDatepickerElement && !isDatepickerInput && !isChildOfDatepickerElement && isElementInDom) {
        return $(window).trigger("datepicker:destroy");
      }
    });
  };

}).call(this);
