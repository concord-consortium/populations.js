Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  50
  rows:     50
  imgPath: "images/environments/green2.png"
  barriers: []
  wrapEastWest: false
  wrapNorthSouth: false

require.register "environments/open", (exports, require, module) ->
  module.exports = env
