mongoose = require('mongoose')
Config   = require('../../models/config')
map      = require('arr-map')
Promise = require("bluebird")
co = Promise.coroutine

getDelay = co (req) ->
  console.log 'getting delay'
  yield Config.findOne()

#module.exports.updateDelay = function(req, res) {
    #delay = req.body.delay

    #Config.update(
        #{},
        #{
          #$set: {
          #actionCaptureDelay: delay
          #}
        #},
        #{upsert: true},
  #function(err, numAffected, raw) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({numAffected: numAffected})
      #}
    #)
#}

getDuration = co (req) ->
  yield Config.find()

#module.exports.updateDuration = function(req, res) {
    #duration = req.body.duration

    #Config.update(
        #{},
        #{
          #$set: {
          #clipDuration: duration
          #}
        #},
        #{upsert: true},
  #function(err, numAffected, raw) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({numAffected: numAffected})
      #}
    #)
#}

getStitches = co (req) ->
  yield Config.find()

#module.exports.updateStitches = function(req, res) {
  #stitch = req.body

  #Config.find(function(err, config) {
    #isFound = false
    #if (err) {
        #res.send(err)
    #}
    #if (config.length > 0) {
      #stitches = config[0].stitchesHash
      #for(i = 0 i < stitches.length i++) {
  #if (JSON.stringify(stitches[i]) === JSON.stringify(stitch)) {
          #isFound = true
        #}
      #}
    #} else {
      #config = new Config()
      #config.save(function(err) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({config: config})
      #})
    #}

    #if (isFound || (stitch === null)) {
      #res.json(404, {info: "stitch hash already exist"})
    #} else {
    #Config.update(
        #{},
        #{
          #$addToSet: {
          #stitchesHash: stitch
          #}
        #},
        #{ upsert: true },
  #function(err, numAffected, raw) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({numAffected: numAffected})
        #})
    #}
  #})
#}

#module.exports.deleteStitches = function(req, res) {
    #Config.update(
  #{},
  #{$set: {stitchesHash: []}},
  #function(err, numAffected, raw) {
        #if (err) {
            #res.send(err)
        #}
        #res.sendStatus(200)
    #})
#}

#module.exports.updateActions = function(req, res) {
  #action = req.body.action

  #Config.find(function(err, config) {
    #isFound = false
    #if (err) {
        #res.send(err)
    #}
    #if (config.length > 0) {
      #actions = config[0].detectableActions
      #for(i = 0 i < actions.length i++) {
        #if (actions[i] === action) {
          #isFound = true
        #}
      #}
    #} else {
      #config = new Config()
      #config.save(function(err) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({config: config})
      #})
    #}

    #if (isFound || (action === "")) {
      #res.json(404, {info: "word already exist"})
    #} else {
    #Config.update(
        #{},
        #{
          #$addToSet: {
          #detectableActions: action
          #}
        #},
        #{ upsert: true },
  #function(err, numAffected, raw) {
          #if (err) {
              #res.send(err)
          #}
          #res.json({numAffected: numAffected})
        #})
    #}
  #})
#}

getActions = co (req) ->
  yield Config.find()

#module.exports.deleteActions = function(req, res) {
    #Config.update(
  #{},
  #{$set: {detectableActions: []}},
  #function(err, numAffected, raw) {
        #if (err) {
            #res.send(err)
        #}
        #res.sendStatus(200)
    #})
#}

getConfigs = co (req) ->
  yield Config.findAll()

deleteConfigs = co (req) ->
  yield Config.remove()
module.exports =
  getDelay: (req) -> getDelay(req)
  getDuration: (req) -> getDuration(req)
  getStitches: (req) -> getStitches(req)
  getActions: (req) -> getActions(req)
  getConfigs: (req) -> getConfigs(req)
  deleteConfigs: (req) -> deleteConfigs(req)
