inject   = require 'honk-di'


class Logger
  @types: {
    AD_REQUEST:             'AdRequest'
    PROOF_OF_PLAY_CONFIRM:  'ProofOfPlay (confirm)'
    PROOF_OF_PLAY_EXPIRE:   'ProofOfPlay (expire)'
    PROOF_OF_PLAY_REQUEUE:  'ProofOfPlay (requeue)'
    PROOF_OF_PLAY_DROP:     'ProofOfPlay (drop)'
    FAILURE:                'failure'
    SUCCESS:                'success'
  }

  config: inject 'config'

  write: (obj) =>
    if @config.debug
      obj['timestamp'] = @now()
      console.log JSON.stringify(obj)

  now: -> Math.floor((new Date()).getTime() / 1000)


module.exports = Logger
