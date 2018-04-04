'use babel'

export function checkIncompatible () {
  let incompat = []
  for (let package of atom.packages.getLoadedPackages()) {
    if (!package.isCompatible()) {
      incompat.push(package)
    }
  }

  if (incompat.length > 0) {
    showNotification(incompat)
  }
}

function showNotification (incompat) {
  let packageNames = incompat.map((p) => p.name)
  let warn = atom.notifications.addWarning('Incompatible packages detected.',
    {
      buttons: [
        {
          text: 'Rebuild packages',
          onDidClick: () => {
            warn.dismiss()
            atom.commands.dispatch(atom.views.getView(atom.workspace.getActivePane()), 'incompatible-packages:view')
          }
        }
      ],
      description: `The above packages are incompatible with the current version
                    of Atom and have been deactivated. Juno will not work properly
                    until they are rebuilt.`,
      detail: '\n' + packageNames.join('\n'),
      dismissable: true
    }
  )
}
