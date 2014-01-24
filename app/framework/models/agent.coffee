AgentView = require 'views/agent-view'
###
  The base agent class
###
module.exports = class Agent

  constructor: ({@name, @environment, @species, x, y}) ->
    @_props = {}
    @_view = new AgentView({agent: @})
    if x? && y?
      @setLocation({x,y})
    @set('age', 0)

  getView: ->
    return @_view

  setLocation: ({x, y}) ->
    # TODO When we support movement, we'll have to check if the results changed,
    # and if so, update the agent's movement direction
    if @environment
      {x,y} = @environment.ensureValidLocation({x,y})
    @_x = x
    @_y = y

  getLocation: ->
    {x: @_x, y: @_y}

  set: (prop, value) ->
    @_props[prop] = value

  get: (prop) ->
    if @hasProp(prop) then return @_props[prop]
    else return @getEnvironmentProperty prop

  hasProp: (prop) ->
    return @_props[prop]?

  getAllProperties: ->
    return @_props

  getEnvironmentProperty: (prop) ->
    @environment.getAt @_x, @_y, prop

  getImages: ->
    @species.getImages this

  die: ->
    @set('dead', true)

  step: ->
    @_incrementAge()
    @_checkSurvival()

  _incrementAge: ->
    @set('age', @get('age')+1)

  _checkSurvival: ->
    chance = if @hasProp('chance of survival') then @get('chance of survival') else @_getSurvivalChances()
    @die() if Math.random() > chance

  _getSurvivalChances: ->
    return 1.0 if @get('is immortal')

    age = @get('age')
    ageMax = @species?.getTrait('age')?.max || 2000

    agePct = 1 - (age/ageMax)

    # TODO factor in HUNGER
    # p2 = Math.pow(hungerPct, 2)

    healthTrait = @species?.getTrait('health') || {min: 0, max: 100}
    health =
      value: @get('health')
      min: healthTrait.min
      max: healthTrait.max
    healthPct = (health.value - health.min)/(health.max - health.min)

    return agePct * healthPct


