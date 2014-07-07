# Delorean - jQuery datepicker plugin


## Usage

Add delorean as a bower dependency or copy over the files in the `dist` dir.

```
$(selector).datepicker(options)
```

If the value of the input element is set, it'll be parsed.

### Options

* *startingView*: `years` (default), `months`, `days`
* *format*: `yyyymmdd` (default), `mmddyyyy`
* *seperator*: `/` (default). Resulting value would look like `2014/04/05`. To use '-', change this option's value to `-`
* *locale*: `en` (default). English is the only available locale right now


## Development

The CSS file is in `dist/delorean.css`. The coffeescript source files are in `lib/`

* Install CoffeeScript with `npm install -g coffee-script` or any other method you prefer
* To compile once run `make`
* To watch for changes during development run `make watch`
