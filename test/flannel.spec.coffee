chai      = require "chai"
Winston   = require "winston"
sinon     = require "sinon"
Flannel   = require "../src/flannel"
{version} = require "../package.json"

{assert, expect} = chai
chai.use require "sinon-chai"


describe "Flannel.init options", ->

  origLogLevels = Flannel.logLevels
  afterEach ->
    Flannel.logLevels = origLogLevels
    delete Flannel.winston

  it "defaults to only using Console transport", ->
    Flannel.init()
    for key, transport of Flannel.winston.transports
      expect(key).to.equal "console"
      expect(transport.constructor).to.equal Winston.transports.Console

  it "can autoload a transport module", ->
    Flannel.init
      Logentries:
        token: "8a000000-aaaa-bbbb-cccc-ddddeeeeffff"

    for key, transport of Flannel.winston.transports
      expect(key).to.equal "logentries"
      expect(transport.constructor).to.equal Winston.transports.Logentries

  it "can pass options to a transport module", ->
    Flannel.init
      Couchdb:
        host: "test"

    for key, transport of Flannel.winston.transports
      expect(transport.host).to.equal "test"

  it "can set custom log levels", ->
    winston = new Winston.Logger
    spy = sinon.spy winston, "log"
    Flannel.winston = winston

    Flannel.logLevels = ["level0", "level1"]
    Flannel.init()

    assert.isFunction Flannel.winston.level0
    expect(spy.args[0][0]).to.equal "level1"

  it "can set custom colors", ->
    Flannel.init()

    expect(Winston.config.allColors).to.have.property " info"

  it "declares version", ->
    winston = new Winston.Logger
    spy = sinon.spy winston, "log"
    Flannel.winston = winston

    Flannel.init()

    [args] = spy.args
    [prefix, version] = args[1].split " "
    expect(args[0]).to.equal Flannel.logLevels[-1..][0]
    expect(prefix).to.equal "(Flannel:init)"
    expect(version).to.equal version


describe "Flannel methods", ->
  afterEach ->
    delete Flannel._morgan if Flannel._morgan

  it "initializes morgan", ->
    Flannel.morgan()
    assert.isFunction Flannel._morgan

  it "returns a flannel to wear", ->
    Flannel.init()
    helpers = Flannel.shirt()
    expect(helpers).to.have.property Flannel.logLevels[1].trim()

  it "will put a shirt on someone else", ->
    foo = {a: 1}
    Flannel.init()
    Flannel.shirt(foo)
    expect(foo).to.have.property Flannel.logLevels[2].trim()

