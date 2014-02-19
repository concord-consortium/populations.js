Agent = require 'models/agent'
Events = require 'events'
Environment = require 'models/environment'
helpers = require 'helpers'

defaultProperties =
  'direction': 0
  'speed': 1
  'default speed': 10
  'sex': 'female'
  'prey': []
  'predator': []
  'chance of being seen': 1.0
  'max energy': 100
  'energy': 100
  'metabolism': 3
  'vision distance': 30
  'eating distance': 5
  'mating distance': 5
  'current behavior': 'wandering'
  'calculate drives': true
  'hunger bonus': 0
  'mating desire bonus': 0
  'fear bonus': 0
  'wandering threshold': 10
  'bubble showing': 'none'

###
  The base class of a simple animal
###
module.exports = class BasicAnimal extends Agent
  label: 'animal'

  @BEHAVIOR:
    EATING: 'eating'
    MATING: 'mating'
    FLEEING: 'fleeing'
    HIDING: 'hiding'
    WANDERING: 'wandering'

  constructor: (args) ->
    if args.additionalDefaults?
      defaults = helpers.setDefaults(defaultProperties, args.additionalDefaults)
    else
      defaults = helpers.clone defaultProperties
    args.additionalDefaults = defaults
    super(args)

  getSize: ->
    age = @get('age')
    if @species.defs.MATURITY_AGE?
      maturity = @get('age') / @species.defs.MATURITY_AGE
      Math.min maturity, 1
    else
      1

  makeNewborn: ->
    super()
    @set 'sex', (ExtMath.flip is 0 ? 'female' : 'male')
    @set 'energy', @get('max energy')
    @set 'direction', ExtMath.randomFloat(2 * Math.PI)
    @set 'speed', @get('default speed')

  step: ->
    @_closestAgents = null
    @_setSpeedAppropriateForAge()
    @_depleteEnergy()
    @set 'current behavior', @_determineBehavior()

    switch @get('current behavior')
      when BasicAnimal.BEHAVIOR.EATING
        @eat()
      when BasicAnimal.BEHAVIOR.FLEEING
        @flee()
      when BasicAnimal.BEHAVIOR.MATING
        @mate()
      when BasicAnimal.BEHAVIOR.WANDERING
        @wander()
      else
        # NOOP

    @_incrementAge()
    @_checkSurvival()

  eat: ->
    nearest = @_nearestPrey()
    if nearest?
      eatingDist = @get('eating distance')
      if nearest.distanceSq < Math.pow(eatingDist, 2)
        @_eatPrey(nearest.agent)
      else
        @chase(nearest)
    else
      @wander(@get('speed') * 0.75)

  flee: ->
    # TODO
  mate: ->
    # TODO

  wander: (speed)->
    unless speed?
      maxSpeed = @get('speed')
      speed = (maxSpeed/2) + ExtMath.randomGaussian() * (maxSpeed/6)
    @set 'speed', speed
    @set 'direction', (@get('direction') + ExtMath.randomGaussian()/2)
    @move()

  chase: (agentDistance)->
    @set('direction', @_direction(@getLocation(), agentDistance.agent.getLocation()))
    @set('speed', Math.min(@get('speed'), Math.sqrt(agentDistance.distanceSq)))
    @move()

  move: ->
    dir = @get 'direction'
    speed = @get 'speed'
    throw 'invalid speed' unless typeof(speed) is 'number'
    throw 'invalid direction' unless typeof(dir) is 'number'
    loc = @getLocation()
    dx = speed * Math.cos(dir)
    dy = speed * Math.sin(dir)

    newLoc = {x: loc.x + dx, y: loc.y + dy}
    if @environment.crossesBarrier(loc, newLoc)
      # stay where you are and turn around, for now
      @set 'direction', dir + Math.PI
    else
      @setLocation newLoc

  _direction: (from, to)->
    dx = to.x - from.x
    dy = to.y - from.y

    return Math.atan2(dy, dx)

  _eatPrey: (agent)->
    food = agent.get('food')
    currEnergy = @get('energy')
    @set('energy', Math.min(@get('max energy'), currEnergy + food))
    agent.die()

    Events.dispatchEvent(Environment.EVENTS.AGENT_EATEN, {predator: @, prey: agent})

  _setSpeedAppropriateForAge: ->
    age = @get 'age'
    speed = @get 'default speed'
    if age < 5
      speed = 2
    else if age < 10
      speed = 5
    @set 'speed', speed

  _depleteEnergy: ->
    currEnergy = @get 'energy'
    rate = @get 'metabolism'
    behavior = @get 'current behavior'
    if behavior is BasicAnimal.BEHAVIOR.HIDING
      rate = rate/2
    @set 'energy', Math.max(0, currEnergy - rate)

  _hunger: ->
    # hunger is just directly inversely proportional to energy
    percentEnergy = @get('energy') / @get('max energy')

    # when we add the bonus, instead of the hunger line going from 0 to 100 it goes from 'bonus' to 100
    range = 100 - @get('hunger bonus')

    return 100 - (range * percentEnergy)

  _fear: ->
    if not @get('predator') instanceof String
      nearest = @_nearestPredator()
      if nearest?
        vision = @get('vision distance')
        percentCloseness = (vision - Math.sqrt(nearest.distanceSq)) / vision
        return Math.pow(10 * percentCloseness, 2)

    return 0

  _desireToMate: ->
    # TODO
    return 0

  _determineBehavior: ->
    hunger = @_hunger()
    fear = @_fear()
    desire = @_desireToMate()
    wanderThreshold = @get('wandering threshold')
    if hunger < wanderThreshold and fear < wanderThreshold and desire < wanderThreshold
      return BasicAnimal.BEHAVIOR.WANDERING

    max = Math.max(Math.max(hunger, fear), desire)
    # in case of ties, order is FLEE, EAT, MATE
    if max == fear
      return BasicAnimal.BEHAVIOR.FLEEING
    else if max == hunger
      return BasicAnimal.BEHAVIOR.EATING
    else
      return BasicAnimal.BEHAVIOR.MATING

  _nearestPredator: ->
    predator = @get('predator')
    if predator? and predator.length? and predator.length > 0
      # TODO Add in trait filter
      nearest = @_nearestAgentsMatching {types: predator, quantity: 1}
      return nearest[0] || null
    return null

  _nearestPrey: ->
    prey = @get('prey')
    if prey? and prey.length? and prey.length > 0
      # TODO Add in trait filter
      nearest = @_nearestAgentsMatching {types: prey}
      return nearest[ExtMath.randomInt(nearest.length)]

    return null

  _nearestAgents: ->
    return @_closestAgents if @_closestAgents?
    loc = @getLocation()
    vision = @get('vision distance')
    vision = @get('speed') * 15 unless vision?
    visibleArea = {x: loc.x - vision, y: loc.y - vision, width: vision*2, height: vision*2}
    visibleAgents = @environment.agentsWithin(visibleArea)

    closest = []
    for a in visibleAgents
      closest.push new AgentDistance(a, @_distanceSquared(loc, a.getLocation()))

    @_closestAgents = closest.sort (a,b)->
      return a.distanceSq - b.distanceSq
    return @_closestAgents

  _nearestAgentsMatching: (options)->
    opts = helpers.setDefaults options,
      camo: true
      quantity: 3
      crossBarriers: false

    throw "Must pass agent types array" unless opts.types? or typeof(opts.types) isnt 'object' or not opts.types.length?

    nearest = @_nearestAgents()
    returnedAgents = []
    for agentDistance in nearest
      agent = agentDistance.agent
      continue if opts.types.indexOf(agent.species.speciesName) is -1

      continue if agent is @
      continue if opts.camo and agent instanceof BasicAnimal and ExtMath.randomFloat() > agent.get('chance seen')
      continue if agent.hasProp('current behavior') and agent.get('current behavior') is BasicAnimal.BEHAVIOR.HIDING
      continue if !opts.crossBarriers and @environment.crossesBarrier(@getLocation(), agent.getLocation())
      continue if opts.trait? # TODO
      returnedAgents.push agentDistance
      break if returnedAgents.length >= opts.quantity

    return returnedAgents

  _distanceSquared: (p1, p2)->
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    return (dx*dx + dy*dy)

class AgentDistance
  constructor: (@agent, @distanceSq)->
