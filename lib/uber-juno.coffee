packages = require './packages'
pathfinder = require './path'
compat = require './incompatible-packages'

module.exports =
  config:
    disable:
      type: 'boolean'
      default: false
      description: "Don't run installation on Atom startup. (This option is set automatically once the installation is complete.)"

  activate: ->
    compat.checkIncompatible()
    return if atom.config.get 'uber-juno.disable'
    @configSetup()
    packages.setup ->
      atom.config.set 'uber-juno.disable', true

  defaultConfig:
    'tool-bar.position': 'Left'
    'julia-client.uiOptions.enableMenu': true
    'julia-client.uiOptions.enableToolBar': true
    'editor.scrollPastEnd': true
    'autocomplete-plus.confirmCompletion': "tab always, enter when suggestion explicitly selected"

  configSetup: ->
    for k, v of @defaultConfig
      atom.config.set k, v
    @setupPath()

  setupPath: ->
    current = atom.config.get 'julia-client.juliaPath'
    return if current? and current isnt 'julia'
    pathfinder.juliaShell().then (valid) ->
      if not valid
        pathfinder.getpath().then (p) ->
          if p?
            atom.config.set 'julia-client.juliaPath', p
            atom.notifications.addInfo "We found Julia on your system",
              description:
                """
                Juno is configured to boot Julia from: `#{p}`
                This path can be changed from `Juno → Settings…`.
                """
