help = {}

getHelp = (task) ->
  return help  if task == undefined
  help[task]

setHelp = (task, deps, opts) ->
  help[task] =
    deps: deps
    opts: opts

module.exports =
  getHelp: getHelp
  setHelp: setHelp

