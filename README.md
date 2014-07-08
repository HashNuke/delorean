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

* Install dependencies with `npm install` or install `coffee-script` and `bower` from npm yourself.
* To compile once run `make`
* To watch for changes and compile during development run `make watch`
