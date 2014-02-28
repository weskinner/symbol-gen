{$, EditorView, View} = require 'atom'
path = require('path')
fs = require('fs')
Q = require('q')
spawn = require('child_process').spawn

swapFile = '.tags_swap'

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
      @message.text('Generating Symbols\u2026')
      projectPath = atom.project.path
      swapFilePath = path.resolve(projectPath, swapFile)
      tagsFilePath = path.resolve(projectPath, 'tags')
      command = path.resolve(__dirname, '..', 'vendor', "ctags-#{process.platform}")
      defaultCtagsFile = require.resolve('./.ctags')
      args = ["--options=#{defaultCtagsFile}", '-R', "-f#{swapFilePath}"]
      ctags = spawn(command, args, {cwd: projectPath})

      ctags.stdout.on 'data', (data) -> console.log('stdout ' + data)
      ctags.stderr.on 'data', (data) -> console.log('stderr ' + data)
      ctags.on 'close', (data) =>
        console.log('Ctags process finished.  Tags swap file created.')
        fs.rename swapFilePath, tagsFilePath, (err) =>
          if err
            console.log('Error swapping file: ', err)
          console.log('Tags file swapped.  Generation complete.')
          @detach()
          deferred.resolve()

      deferred.promise
