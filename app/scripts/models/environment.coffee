EnvironmentView = require 'views/environment-view'

module.exports = class Environment

  constructor: ({@width, @height, imgPath}) ->
    @view = new EnvironmentView({@width, @height, imgPath})

  getView: ->
    return @view
