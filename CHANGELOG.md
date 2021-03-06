# vistar-html5player

an html5 Vistar Media ad request library.

### 1.6.4

Issue when publishing to npm called for a version bump and redeploy

### 1.6.3

Added JSON configuration support. Removed Cortex configuration.

### 1.6.2

Update link to new knowledge base article about the HTML5 Player

### 1.6.1

send more accurate `display_time` with proof of play

* assume that `ProofOfPlay#write` is called right after the advertisement is
  played.  set `display_time` on the proof of play request to current time -
  advertisement duration

### 1.6.0

Logging to give more detailed information.

* log ProofOfPlay expire and success
* rename the 'name' key on some logging messages to prepare for listening for or
  dropping certain types of logging messages
* expose Logger implementation to allow DI binding to it for custom logging
  implementations

### 1.5.1

* add `lastRequestTime` and `@lastSuccessfulRequestTime` attributes on
  VariedAdStream and ProofOfPlay to be timestamps

### 1.5.0

* add `lastRequestTime` and `@lastSuccessfulRequestTime` attributes to
  VariedAdStream and ProofOfPlay

### 1.4.2

* upgrade Ajax version.  should have no effect unless this project is required
  by a project that also uses the specific Ajax project listed in package.json

### 1.4.1

same as 1.4.0:  messed up version tags at some point

### 1.4.0

* Download
  * inject Logger using correct variable
  * tests around Cortex API behavior
  * remove annoying 'download-cache' binding, make it private.  this
    makes it so every app doesn't have to declare a 'download-cache'
    binding, even though it might not use it
* VariedAdStream:
  * fixed bug with deferred(downloads) call.  should be arguments, not array.
    was always succeeding even if some asset_url download calls failed.
  * if only some asset_url download calls succeed, only call `_next` callback
    with ad objects where the asset download succeeded.  Previously, asset_url
    would be updated with the cached path when it succeeded and would keep the
    remote url if downloading the asset_url failed.
  * for the moment, not going to worry about expiring ads that are not emitted from
    VariedAdStream
  * will only included cached ads if config.cacheAssets is true
