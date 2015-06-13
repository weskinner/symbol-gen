path = require('path')
fs = require('fs')
Q = require('q')
spawn = require('child_process').spawn

swapFile = '.tags_swap'

module.exports =
class SymbolGenView

  isActive: false

  constructor: (serializeState) ->
    atom.commands.add 'atom-workspace', "symbol-gen:generate", => @generate()
    atom.commands.add 'atom-workspace', "symbol-gen:purge", => @purge()
    @activate_for_projects (activate) =>
      return unless activate
      @isActive = true
      @watch_for_changes()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  watch_for_changes: ->
    atom.commands.add 'atom-workspace', 'core:save', => @check_for_on_save()
    atom.commands.add 'atom-workspace', 'core:save-as', => @check_for_on_save()
    atom.commands.add 'atom-workspace', 'window:save-all', => @check_for_on_save()

  check_for_on_save: ->
    return unless @isActive
    onDidSave =
      atom.workspace.getActiveTextEditor().onDidSave =>
        @generate()
        onDidSave.dispose()

  activate_for_projects: (callback) ->
    projectPaths = atom.project.getPaths()
    shouldActivate = projectPaths.some (projectPath) =>
      tagsFilePath = path.resolve(projectPath, 'tags')
      try fs.accessSync tagsFilePath; return true
    callback shouldActivate

  purge_for_project: (projectPath) ->
    swapFilePath = path.resolve(projectPath, swapFile)
    tagsFilePath = path.resolve(projectPath, 'tags')
    fs.unlink tagsFilePath, -> # no-op
    fs.unlink swapFilePath, -> # no-op

  generate_for_project: (deferred, projectPath) ->
    swapFilePath = path.resolve(projectPath, swapFile)
    tagsFilePath = path.resolve(projectPath, 'tags')
    command = path.resolve(__dirname, '..', 'vendor', "ctags-#{process.platform}")
    defaultCtagsFile = require.resolve('./.ctags')
    args = ["--options=#{defaultCtagsFile}", '-R', "-f#{swapFilePath}"]
    ctags = spawn(command, args, {cwd: projectPath})

    ctags.stderr.on 'data', (data) -> console.error('symbol-gen:', 'ctag:stderr ' + data)
    ctags.on 'close', (data) =>
      fs.rename swapFilePath, tagsFilePath, (err) =>
        if err then console.warn('symbol-gen:', 'Error swapping file: ', err)
        deferred.resolve()

  purge: ->
    projectPaths = atom.project.getPaths()
    projectPaths.forEach (path) =>
      @purge_for_project(path)
    @isActive = false

  generate: ->
    if not @isActive
      @isActive = true
      @watch_for_changes()

    promises = []
    projectPaths = atom.project.getPaths()
    projectPaths.forEach (path) =>
      p = Q.defer()
      @generate_for_project(p, path)
      promises.push(p)
    Q.all(promises)
