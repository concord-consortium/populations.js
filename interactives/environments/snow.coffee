Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  45
  rows:     45
  imgPath: "images/environments/snow.png"
  wrapEastWest: false
  wrapNorthSouth: false

require.register "environments/snow", (exports, require, module) ->
  module.exports = env
