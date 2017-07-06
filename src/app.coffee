inject              = require 'honk-di'

Player              = require './player'
ProofOfPlay         = require './proof_of_play'
VariedAdStream      = require './varied_ad_stream'
{Ajax, XMLHttpAjax} = require 'ajax'
http                = require 'http'


config = ''

window?.Vistar = ->
  # an example app
  class Binder extends inject.Binder
    configure: ->
      @bind(Ajax).to(XMLHttpAjax)
      @bindConstant('navigator').to window.navigator
      @bindConstant('video').to document.querySelector('.player video')
      @bindConstant('image').to document.querySelector('.player img')
      @bindConstant('config').to config

    if !!CONFIG
      # CONFIG is a global variable in config.js that is an optional json
      config = CONFIG
    else
      config = {
        url:               'http://dev.api.vistarmedia.com/api/v1/get_ad/json'
        apiKey:            'DEFAULT_API_KEY'
        networkId:         'DEFAULT_NETWORK_ID'
        deviceId:          'DEFAULT_DEVICE_ID'
        venueId:           'DEFAULT_VENUE_ID'
        width:             1280
        height:            720
        cacheAssets:       true
        allowAudio:        true
        directConnection:  false
        latitude:          39.9859241
        longitude:         -75.1299363
        queueSize:         10
        debug:             false
        mimeTypes:         ['image/gif', 'image/jpeg', 'image/png', 'video/webm']
        displayArea: [
          {
            id:               'display-0'
            width:            1280
            height:           720
            allow_audio:      false
            cpm_floor_cents:  Number(0)
          }
        ]
      }

    injector = new inject.Injector(new Binder)
    ads      = injector.getInstance VariedAdStream
    player   = injector.getInstance Player
    pop      = injector.getInstance ProofOfPlay

    # this exists only so one can inspect the different components while it's
    # running
    window.__vistarplayer =
      ads:     ads
      player:  player
      pop:     pop

    ads
      .pipe(player)
      .pipe(pop)
