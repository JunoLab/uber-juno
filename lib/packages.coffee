path = require 'path'

requirements = [
  'tool-bar'
  'latex-completions'
  'language-julia'
  'ink'
  'julia-client'
]

module.exports =
  setup: (cb) ->
    atom.packages.activatePackage('settings-view').then (p) =>
      return @settingsError() unless p?
      PackageManager = require path.join p.path, 'lib', 'package-manager'
      @packageManager = new PackageManager

      return cb() if @allInstalled requirements
      @setupInfo()
      @installAll requirements.slice(), cb

  allInstalled: (pkgs) ->
    for pkg in pkgs
      return false unless @packageManager.isPackageInstalled pkg
    return true

  install: (name, cb) ->
    return cb?() if @packageManager.isPackageInstalled name
    atom.notifications.addInfo "Installing #{name}"
    @packageManager.getPackage(name)
      .then (pkg) =>
        @packageManager.install pkg, (err) =>
          if err?
            @installError name, err
          else
            atom.notifications.addSuccess "Juno: Installed package #{name}"
            cb?()
      .catch (err) => @retreiveError name, err

  installAll: (pkgs, cb) ->
    if (pkg = pkgs.shift())?
      @install pkg, =>
        @installAll pkgs, cb
    else
      @setupnote.dismiss()
      atom.notifications.addSuccess "Juno: Success!",
        detail: "We've set up the Atom packages for you."
      cb?()

  setupInfo: ->
    @setupnote = atom.notifications.addInfo "Juno: Installing Atom packages",
      detail: """
        This will take a moment – hang tight!
        We'll let you know once it's done.
        """
      dismissable: true

  settingsError: ->
    atom.notifications.addError "Juno: Couldn't find settings-view package.",
      dismissable: true

  retreiveError: (name, err) ->
    @setupnote.dismiss()
    atom.notifications.addError "Juno: Error downloading package info for #{name}",
    detail: """
      Please check your internet connection, or report this to
          http://discuss.junolab.org
      and we'll try to help.
          –––
      #{err}
      """
    dismissable: true

  installError: (name, err) ->
    @setupnote.dismiss()
    atom.notifications.addError "Juno: Error installing package #{name}",
    detail: """
      Please check your internet connection, or report this to
          http://discuss.junolab.org
      and we'll try to help.
          –––
      #{err}
      """
    dismissable: true
