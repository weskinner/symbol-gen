SymbolGen = require '../lib/symbol-gen'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SymbolGen", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('symbolGen')

  describe "when the symbol-gen:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(workspaceElement.querySelector('.symbol-gen')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'symbol-gen:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.symbol-gen')).toExist()
        atom.views.getView(atom.workspace).trigger 'symbol-gen:toggle'
        expect(workspaceElement.querySelector('.symbol-gen')).not.toExist()
