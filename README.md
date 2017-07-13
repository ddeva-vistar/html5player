# html5player

[![Build Status](https://travis-ci.org/vistarmedia/html5player.svg)](https://travis-ci.org/vistarmedia/html5player)

An HTML 5 Player for Vistar Media assets.

### Building as a web app

`make build`

The full app will be in the `build` directory.

### Building for Cortex

`make package`

A zipfile will be in your current directory.  This can be uploaded through the
Cortex UI.

### As a standalone app

There is an example of using this in
[https://github.com/vistarmedia/html5player/blob/master/src/app.coffee](src/app.coffee).

## Configuration

To use a JSON configuration, pass in the config in the command line.

`make package config=/path/to/file/myjson.json`

The same argument can be used with other tasks. See an example config in
[https://github.com/vistarmedia/html5player/blob/master/config.json](config.json)

Note: when using gulp tasks, the parameter is --config.
