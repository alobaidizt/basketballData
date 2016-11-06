`import Ember from 'ember'`
`import config from 'ember-get-config'`

{ key } = config.jwplayer

JwPlayer = Ember.Component.extend
  classNames: []
  tagName: "div"
  elementId: "my-element"
  attributeBindings: "key type file image title description
    mediaid mute autostart repeat abouttext aboutlink controls
    width height visualplaylist displaytitle display description
    stretching hlshtml primary flashplayer base".w()

  mute: false
  autostart: false
  repeat: false
  abouttext: ''
  aboutlink: 'https://www.jwplayer.com/learn-more'

  controls: true
  width: '640'
  height: '360'
  visualplaylist: true
  displaytitle: true
  displaydescription: false
  stretching: 'uniform' # uniform - exactfit - fill - none

  hlshtml: true
  primary: 'html5' # html5 - flash

  didInsertElement: ->
    console.log key
    jwplayer.key = key
    console.log jwplayer.key
    jwplayer(this.$().get(0)).setup
      file: @get 'file'
      image: @get 'image'
      mute: @get 'mute'
      autostart: @get 'autostart'
      repeat: @get 'repeat'
      abouttext: @get 'abouttext'
      aboutlink: @get 'aboutlink'

      controls: @get 'controls'
      width: @get 'width'
      height: @get 'height'
      visualplaylist: @get 'visualplaylist'
      displaytitle: @get 'displaytitle'
      displaydescription: @get 'displaydescription'
      stretching: @get 'stretching'

      hlshtml: @get 'hlshtml'
      primary: @get 'primary'


  willDestroyElement: ->
    @_super(arguments...)
    jwplayer(this.$().get(0)).remove()


  # jwplayer actions
  setupError: (msg) ->
    console.log 'error', msg
  play: (oldState) ->
    console.log 'played', oldState
  pause: (oldState) ->
    console.log 'paused', oldState
  complete: ->
    console.log 'completed'
  buffer: (buffer) ->
    console.log 'buffering', buffer

`export default JwPlayer`
