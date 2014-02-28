{$, EditorView, View} = require 'atom'
path = require('path')
Q = require('q')
spawn = require('child_process').spawn

module.exports =
class SymbolGenView extends View
  @content: ->
    @div class: 'symbol-gen overlay from-top mini', =>
      @div class: 'message', outlet: 'message'

  initialize: (serializeState) ->
    atom.workspaceView.command "symbol-gen:generate", => @generate()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  generate: () ->
    if @hasParent()
      @detatch()
    else
      deferred = Q.defer()
      atom.workspaceView.append(this)
      @message.text('Generating Symbols...')
      tags = []
      command = path.resolve(__dirname, '..', 'vendor', "ctags-#{process.platform}")
      defaultCtagsFile = require.resolve('./.ctags')
      args = ["--options=#{defaultCtagsFile}", '-R']
      ctags = spawn(command, args, {cwd: atom.project.path})

      ctags.stdout.on 'data', (data) -> console.log('stdout ' + data)
      ctags.stderr.on 'data', (data) -> console.log('stderr ' + data)
      ctags.on 'close', (data) =>
        console.log('Child Process Closed.')
        @detach()
        deferred.resolve(tags)

      deferred.promise
