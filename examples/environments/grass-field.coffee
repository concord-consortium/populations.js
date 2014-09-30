Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  45
  rows:     45
  imgPath: "images/environments/grass.jpg"
  barriers: []
  wrapEastWest: false
  wrapNorthSouth: false

require.register "environments/grass-field", (exports, require, module) ->
  module.exports = env
