path = require 'path'

requirements = ['indent-detective']

module.exports =
  activate: ->
    @info "Juno: Installing Atom packages", """
    This will take a moment – hang tight!
    """
    # setTimeout (=> @install()), 1000
    @install()

  install: ->
    atom.packages.activatePackage('settings-view').then (p) ->
      return @error "Juno Error: Couldn't find settings-view package." unless p?
      packages = require path.join p.path, 'lib', 'package-manager'

  error: (msg, detail) ->
    atom.notifications.addError msg,
      detail: detail
      dismissable: true

  info: (msg, detail) ->
    atom.notifications.addInfo msg,
      detail: detail
