inject      = require 'honk-di'
{Ajax}      = require 'ajax'
{Transform} = require('stream')

Logger             = require './logger'
{requestErrorBody} = require './error'


nowInSeconds = -> Math.round(new Date().getTime() / 1000)

class ProofOfPlay extends Transform
  http:    inject Ajax
  config:  inject 'config'
  log:     inject Logger

  constructor: ->
    super(objectMode: true, highWaterMark: 100)

    @lastRequestTime = new Date().getTime()
    @lastSuccessfulRequestTime = new Date().getTime()

  expire: (ad) ->
    url       = ad.expiration_url
    timestamp = @log.now()

    req = @http.request
      type:             'GET'
      url:              url
      dataType:         'json'
      withCredentials:  false
      timeout:          7500
    req.then (response) =>
      @log.write
        name:     Logger.types.PROOF_OF_PLAY_EXPIRE
        message:  Logger.types.SUCCESS
        request:
          advertisement:  ad
          timestamp:      timestamp
          url:            url
        response:
          body:       response
          url:        url
          timestamp:  @log.now()
     req.catch (respOrEvent) =>
        @log.write
          name:     Logger.types.PROOF_OF_PLAY_EXPIRE
          message:  Logger.types.FAILURE
          request:
            advertisement:  ad
            timestamp:      timestamp
            url:            url
          response:
            body:       requestErrorBody(respOrEvent)
            url:        url
            timestamp:  @log.now()
    req

  confirm: (ad) ->
    displayTime = nowInSeconds() - ad.length_in_seconds
    body      = JSON.stringify(display_time: displayTime)
    timestamp = @log.now()
    url       = ad.proof_of_play_url

    req = @http.request
      type:             'POST'
      url:              url
      dataType:         'json'
      withCredentials:  false
      data:             body
      timeout:          7500
    req.then (response) =>
      @log.write
        name:     Logger.types.PROOF_OF_PLAY_CONFIRM
        message:  Logger.types.SUCCESS
        request:
          advertisement:  ad
          body:           body
          timestamp:      timestamp
          url:            url
        response:
          body:  response
          url:   url
    req.catch (respOrEvent) =>
      @log.write
        name:     Logger.types.PROOF_OF_PLAY_CONFIRM
        message:  Logger.types.FAILURE
        request:
          advertisement:  ad
          body:           body
          timestamp:      timestamp
          url:            url
        response:
          body:  requestErrorBody(respOrEvent)
          url:   url
    req

  _transform: (ad, encoding, callback) ->
    @lastRequestTime = new Date().getTime()
    write = =>
      @write ad
    if @_wasDisplayed(ad)
      @confirm(ad).then (response) =>
        @lastSuccessfulRequestTime = new Date().getTime()
        @_process(response, callback)
      .catch (e) =>
        callback()
        # According to W3 XHR spec, if the state is UNSENT, OPENED or the error
        # flag is set, status code will be 0. Otherwise, status will be set to
        # HTTP status code. We need to drop the PoP request on server errors.
        if e?.currentTarget?.status == 0
          @log.write
            name: Logger.types.PROOF_OF_PLAY_REQUEUE
            message:  'confirm failed:  adding back to the queue.'
            advertisement:  ad
          setTimeout(write, 5000)
        else
          @log.write
            name: Logger.types.PROOF_OF_PLAY_DROP
            message: 'confirm failed: dropping the request.'
            advertisement: ad
    else
      @expire(ad).then (response) =>
        @lastSuccessfulRequestTime = new Date().getTime()
        @_process(response, callback)
      .catch (e) =>
        callback()
        if e?.currentTarget?.status == 0
          @log.write
            name: Logger.types.PROOF_OF_PLAY_REQUEUE
            message: 'expire failed: adding back to the queue.'
            advertisement: ad
          setTimeout(write, 5000)
        else
          @log.write
            name: Logger.types.PROOF_OF_PLAY_DROP
            message: 'expire failed: dropping the request.'
            advertisement: ad

  _wasDisplayed: (ad) ->
    ad.html5player?.was_played

  _process: (response, cb) ->
    # optionally pass PoP response on down the pipe.  if there are no consumers
    # of these stream, drop it on the floor.  This needs to happen because if
    # we fill up our _readableState.buffer to the highWaterMark, we'll stop
    # making PoP requests
    if @_readableState.pipesCount > 0
      cb(null, response)
    else
      cb()


module.exports = ProofOfPlay
