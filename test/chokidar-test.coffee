chokidar = require '..'
isBinary = require '../lib/is-binary'
fs = require 'fs'
sysPath = require 'path'

getFixturePath = (subPath) ->
  sysPath.join __dirname, 'fixtures', subPath

fixturesPath = getFixturePath ''

describe 'chokidar', ->
  it 'should expose public API methods', ->
    chokidar.FSWatcher.should.be.a 'function'
    chokidar.watch.should.be.a 'function'

  describe 'watch', ->
    options = {}
    delay = (fn) =>
      setTimeout fn, 205

    beforeEach (done) ->
      @watcher = chokidar.watch fixturesPath, options
      delay =>
        done()

    afterEach (done) ->
      @watcher.close()
      delete @watcher
      delay =>
        done()

    before ->
      try fs.unlinkSync (getFixturePath 'add.txt'), 'b'
      fs.writeFileSync (getFixturePath 'change.txt'), 'b'
      fs.writeFileSync (getFixturePath 'unlink.txt'), 'b'

    after ->
      try fs.unlinkSync (getFixturePath 'add.txt'), 'a'
      fs.writeFileSync (getFixturePath 'change.txt'), 'a'
      fs.writeFileSync (getFixturePath 'unlink.txt'), 'a'

    it 'should produce an instance of chokidar.FSWatcher', ->
      @watcher.should.be.an.instanceof chokidar.FSWatcher

    it 'should expose public API methods', ->
      @watcher.on.should.be.a 'function'
      @watcher.emit.should.be.a 'function'
      @watcher.add.should.be.a 'function'
      @watcher.close.should.be.a 'function'

    it 'should emit `add` event when file was added', (done) ->
      spy = sinon.spy()
      testPath = getFixturePath 'add.txt'

      @watcher.on 'add', spy

      delay =>
        spy.should.not.have.been.called
        fs.writeFileSync testPath, 'hello'
        delay =>
          spy.should.have.been.calledOnce
          spy.should.have.been.calledWith testPath
          done()

    it 'should emit `change` event when file was changed', (done) ->
      spy = sinon.spy()
      testPath = getFixturePath 'change.txt'

      @watcher.on 'change', spy

      delay =>
        spy.should.not.have.been.called
        fs.writeFileSync testPath, 'c'
        delay =>
          spy.should.have.been.calledOnce
          spy.should.have.been.calledWith testPath
          done()

    it 'should emit `unlink` event when file was removed', (done) ->
      spy = sinon.spy()
      testPath = getFixturePath 'unlink.txt'

      @watcher.on 'unlink', spy

      delay =>
        spy.should.not.have.been.called
        fs.unlinkSync testPath
        delay =>
          spy.should.have.been.calledOnce
          spy.should.have.been.calledWith testPath
          done()

describe 'is-binary', ->
  it 'should be a function', ->
    isBinary.should.be.a 'function'

  it 'should correctly determine binary files', ->
    isBinary('a.jpg').should.equal yes
    isBinary('a.jpeg').should.equal yes
    isBinary('a.zip').should.equal yes
    isBinary('ajpg').should.equal no
    isBinary('a.txt').should.equal no
