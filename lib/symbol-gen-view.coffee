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

  tagfilePath: ->
    atom.config.get('symbol-gen.tagFile')

  consumeStatusBar: (@statusBar) ->
    element = document.createElement 'div'
    element.classList.add('inline-block')
    element.textContent = 'Generating symbols'
    element.style.display = 'none'
    @statusBarTile = @statusBar.addRightTile(item: element, priority: 100)

  watch_for_changes: ->
    atom.commands.add 'atom-workspace', 'core:save', => @check_for_on_save()
    atom.commands.add 'atom-workspace', 'core:save-as', => @check_for_on_save()
    atom.commands.add 'atom-workspace', 'window:save-all', => @check_for_on_save()

  check_for_on_save: ->
    return unless @isActive
    editor = atom.workspace.getActiveTextEditor()
    if (editor)
      onDidSave =
        editor.onDidSave =>
          @generate()
          onDidSave.dispose()

  activate_for_projects: (callback) ->
    projectPaths = atom.project.getPaths()
    shouldActivate = projectPaths.some (projectPath) =>
      tagsFilePath = path.resolve(projectPath, @tagfilePath())
      try fs.accessSync tagsFilePath; return true
    callback shouldActivate

  purge_for_project: (projectPath) ->
    swapFilePath = path.resolve(projectPath, swapFile)
    tagsFilePath = path.resolve(projectPath, @tagfilePath())
    fs.unlink tagsFilePath, -> # no-op
    fs.unlink swapFilePath, -> # no-op

  generate_for_project: (deferred, projectPath) ->
    swapFilePath = path.resolve(projectPath, swapFile)
    tagsFilePath = path.resolve(projectPath, @tagfilePath())
    command = path.resolve(__dirname, '..', 'vendor', "ctags-#{process.platform}")
    defaultCtagsFile = require.resolve('./.ctags')
    excludes = @get_ctags_excludes(projectPath)
    args = ["--options=#{defaultCtagsFile}", '-R', "-f#{swapFilePath}"].concat excludes
    ctags = spawn(command, args, {cwd: projectPath})

    ctags.stderr.on 'data', (data) -> console.error('symbol-gen:', 'ctag:stderr ' + data)
    ctags.on 'close', (data) =>
      fs.rename swapFilePath, tagsFilePath, (err) =>
        if err then console.warn('symbol-gen:', 'Error swapping file: ', err)
        deferred.resolve()

  get_ctags_excludes: (projectPath) ->
    ignoredNames = atom.config.get("core.ignoredNames")
    if atom.config.get("core.excludeVcsIgnoredPaths")
      ignoredNames = ignoredNames.concat @get_vcs_excludes(projectPath)
    ignoredNames.map (glob) => "--exclude=#{glob}"

  get_vcs_excludes: (projectPath) ->
    gitIgnorePath = path.resolve(projectPath, '.gitignore')
    require('ignored')(gitIgnorePath)

  purge: ->
    projectPaths = atom.project.getPaths()
    projectPaths.forEach (path) =>
      @purge_for_project(path)
    @isActive = false

  generate: () ->
    if not @isActive
      @isActive = true
      @watch_for_changes()

    isGenerating = true
    # show status bar tile if it takes a while to generate tags
    showStatus = =>
      return unless isGenerating
      @statusBarTile?.getItem().style.display = 'inline-block'
    setTimeout showStatus, 300

    promises = []
    projectPaths = atom.project.getPaths()
    projectPaths.forEach (path) =>
      p = Q.defer()
      @generate_for_project(p, path)
      promises.push(p.promise)

    Q.all(promises).then =>
      # hide status bar tile
      @statusBarTile?.getItem().style.display = 'none'
      isGenerating = false
