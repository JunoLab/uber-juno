packages = require './packages'
pathfinder = require './path'

module.exports =
  config:
    disable:
      type: 'boolean'
      default: false
      description: "Don't run when Atom boots"

  activate: ->
    return if atom.config.get 'uber-juno.disable'
    @configSetup()
    packages.setup ->
      atom.config.set 'uber-juno.disable', true

  defaultConfig:
    'tool-bar.position': 'Left'
    'julia-client.enableMenu': true
    'julia-client.enableToolBar': true
    'julia-client.launchOnStartup': true

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
              detail: """
                Juno is configured to boot Julia from:
                  #{p}
                This path can be changed from Julia → Settings.
                """
