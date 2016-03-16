Winston   = require "winston"
Split     = require "split"
{version} = require "../package.json"


class Flannel
  @enabled: true

  @logLevels: [
    "  err"
    " warn"
    " info"
    "debug"
  ]

  @colorize: true
  @logLevelColors:
    "  err": "red"
    " warn": "yellow"
    " info": "green"
    "debug": "blue"

  @_dependencyMap:
    "Couchdb":    "winston-couchdb"
    "Logentries": "le_node"
    "Loggly":     "winston-loggly"
    "Logzio":     "winston-logzio"
    "Mongodb":    "winston-mongodb"
    "Riak":       "winston-riak"

  @makeLevels: (levels = {}) ->
    levels[level] = i for level, i in @logLevels
    levels

  @init: (@transports = {Console: {}}) ->
    @winston or= new Winston.Logger
    @setupWinston @transports

    @_helpers or= {}
    for level in @logLevels then do (level) =>
      @_helpers[level.trim()] = (objs...) -> Flannel.log level, @logPrefix, objs...

    @_helpers.log = @_helpers.debug if @_helpers.debug
    @log @logLevels[-1..][0], "(Flannel:init) flannel #{version}: feel like a lumberjack"
    this

  @setupWinston: (transportMap) ->
    levels = @makeLevels()
    Winston.addColors @logLevelColors

    transports = for logger, logopts of transportMap
      logopts.levels  or= levels
      logopts.colorize ?= @colorize
      require @_dependencyMap[logger] if @_dependencyMap[logger]
      new Winston.transports[logger] logopts

    @winston.configure {transports, levels}

  @morgan: (level = @logLevels[1], format = "combined", opts = {}) ->
    opts.stream or= @streamToWinston level
    @_morgan or= (require "morgan") format, opts

  @streamToWinston: (level) ->
    Split().on "data", (line) => @winston.log level, line

  @shirt: (obj) ->
    if obj then @wear.call obj, @shirt()
    else @_helpers

  @wear: (clothing) -> @[item] = worn for item, worn of clothing

  @log: (level, objs...) ->
    return unless @enabled
    @winston.log level, objs...


module.exports = Flannel
