fs = require 'fs'
path = require 'path'
child_process = require 'child_process'

readdir = (dir) ->
  new Promise (resolve) ->
    fs.readdir dir, (err, children) ->
      resolve children or []

stat = (path) ->
  new Promise (resolve) ->
    fs.stat path, (err, stat) -> resolve stat

module.exports =

  home: (p...) ->
    path.join (process.env.USERPROFILE or process.env.HOME), p...

  searchpaths: ->
    if process.platform is 'darwin'
      [
        ['/Applications', /^Julia-([\d\.]+).app$/, 'Contents/Resources/julia/bin/julia']
        [@home(), /^julia/, 'usr/bin/julia']
      ]
    else if process.platform is 'linux'
      [
        [@home(), /^julia/, 'bin/julia']
        [@home(), /^julia/, 'usr/bin/julia']
      ]
    else if process.platform is 'win32'
      [
        [@home('AppData\\Local'), /^Julia-([\d\.]+)$/, 'bin\\julia.exe']
        ['C:\\Program Files\\', /^Julia-([\d\.]+)$/, 'bin\\julia.exe']
      ]
    else []

  validpaths: ([pre, r, post]) ->
    readdir pre
      .then (ps) ->
        ps.filter (path) -> path.match r
          .map (path) -> {path, version: path.match(r)[1]}
          .map ({path: p, version}) -> {path: path.join(pre, p, post), version}
      .then (ps) ->
        Promise.all ps.map ({path, version}) ->
          stat(path).then (stat) -> {path, version, file: stat?.isFile()}
      .then (ps) -> ps.filter ({file}) -> file

  search: (templates) ->
    Promise.all templates.map (t) => @validpaths t
      .then (ps) -> ps.reduce((a, b) -> a.concat(b))

  getpath: ->
    # TODO: sort by version
    @search(@searchpaths())
      .then (ps) -> ps[0]?.path

  juliaShell: ->
    new Promise (resolve) ->
      which = if process.platform is 'win32' then 'where' else 'which'
      proc = child_process.spawn which, ['julia']
      proc.on 'exit', (status) ->
        resolve status is 0
