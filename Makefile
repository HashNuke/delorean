all: compile

compile:
	coffee -c -j dist/delorean.js lib/datepicker.coffee lib/error.coffee lib/locale.coffee lib/view.coffee lib/jquery-plugin.coffee

watch:
	coffee -wc -j dist/delorean.js lib/datepicker.coffee lib/error.coffee lib/locale.coffee lib/view.coffee lib/jquery-plugin.coffee
