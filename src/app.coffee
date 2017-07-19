inject              = require 'honk-di'

Player              = require './player'
ProofOfPlay         = require './proof_of_play'
VariedAdStream      = require './varied_ad_stream'
{Ajax, XMLHttpAjax} = require 'ajax'
http                = require 'http'

broadsign = window.BroadSignObject


config = {}

clientWidth = window.document.documentElement.clientWidth
clientHeight = window.document.documentElement.clientHeight

# broadsign width and height
dimensions = broadsign?.frame_resolution or "#{clientWidth}x#{clientHeight}"
[width, height] = (Number(p) for p in dimensions.split('x'))

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
    config = CONFIG
    config.deviceId = broadsign?.player_id or config.deviceId
    config.venueId  = broadsign?.player_id or config.venueId
    config.width = width
    config.height = height
    config.displayArea = config.displayArea.map (area) ->
      area.width = width
      area.height = height
      area
  else
    config = {
      url:               'http://staging.api.vistarmedia.com/api/v1/get_ad/json'
      apiKey:            'DEFAULT_API_KEY'
      networkId:         'DEFAULT_NETWORK_ID'
      deviceId:          broadsign?.player_id or ''
      venueId:           broadsign?.player_id or ''
      width:             width
      height:            height
      cacheAssets:       true
      allowAudio:        true
      directConnection:  false
      queueSize:         1
      debug:             false
      mimeTypes:         ['image/gif', 'image/jpeg', 'image/png', 'video/webm']
      displayArea: [
        {
          id:               'display-0'
          width:            width
          height:           height
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
