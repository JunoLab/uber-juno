packages = require './packages'

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
