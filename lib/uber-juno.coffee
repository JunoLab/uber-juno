packages = require './packages'

module.exports =
  config:
    disabled:
      type: 'boolean'
      default: false
      description: "Don't run when Atom boots"

  activate: ->
    packages.setup()
