argus = require "argus"
async = require "async"
log = require "loggo"
status = require "../main"

module.exports = (ops, {name, plain}) ->
  process.env.PLAIN_TEXT = true if plain
  plugin = status.list()[name]
  return log.error "Plugin '#{name}' is not installed" unless plugin
  return log.error "No operations specified" unless typeof ops is "string" and ops.length > 0
  operations = argus.parse ops
  return log.error "No operations specified" unless Object.keys(operations).length > 0

  out = {}
  runOperation = (name, cb) ->
    plugin.run name, operations[name], (err, ret) ->
      return cb err if err?
      if process.env.PLAIN_TEXT
        out = ret
      else
        out[name] = ret
      return cb()

  async.forEach Object.keys(operations), runOperation, (err) ->
    return log.error err if err?
    if process.env.PLAIN_TEXT
      console.log out
    else
      console.log JSON.stringify out
    process.exit()