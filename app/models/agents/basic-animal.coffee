Agent = require 'models/agent'
Events = require 'events'
Environment = require 'models/environment'
Trait = require 'models/trait'
helpers = require 'helpers'

defaultProperties =
  'direction': 0
  'speed': 1
  'default speed': 10
  'sex': 'female'
  'prey': []
  'predator': []
  'hiding place': []
  'chance of being seen': 1.0
  'max energy': 100
  'energy': 100
  'metabolism': 3
  'vision distance': 300
  'eating distance': 50
  'mating distance': 50
  'current behavior': 'wandering'
  'calculate drives': true
  'hunger bonus': 0
  'mating desire bonus': 0
  'fear bonus': 0
  'wandering threshold': 5
  'bubble showing': 'none'

###
  The base class of a simple animal
###
module.exports = class BasicAnimal extends Agent
  label: 'animal'
  _viewLayer: 2
  _hasEatenOnce: false
  _timeLastMated: -20

  @BEHAVIOR:
    EATING: 'eating'
    MATING: 'mating'
    FLEEING: 'fleeing'
    HIDING: 'hiding'
    WANDERING: 'wandering'

  constructor: (args) ->
    if args.additionalDefaults?
      defaults = helpers.setDefaults(helpers.clone(defaultProperties), args.additionalDefaults)
    else
      defaults = helpers.clone defaultProperties
    args.additionalDefaults = defaults
    super(args)

  makeNewborn: ->
    super()
    @set 'sex', (if ExtMath.flip() is 0 then 'female' else 'male')
    @set 'energy', @get('max energy')
    @set 'direction', ExtMath.randomFloat(2 * Math.PI)
    @set 'speed', @get('default speed')

  step: ->
    @_closestAgents = null
    @_setSpeedAppropriateForAge()
    @_depleteEnergy()
    if @get 'calculate drives'
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
    nearest = @_nearestPredator()
    if nearest?
      hidingPlace = @_nearestHidingPlace()
      if hidingPlace?
        speed = @get 'speed'
        @set 'speed', speed*6
        @chase(hidingPlace)
        @set 'speed', speed

        @set('current behavior', BasicAnimal.BEHAVIOR.HIDING) if hidingPlace.distanceSq < Math.pow(@get('speed'), 2)
      else
        @runFrom(nearest)
    else
      @wander()

  mate: ->
    nearest = @_nearestMate()
    if nearest?
      @chase(nearest)
      if nearest.distanceSq < Math.pow(@get('mating distance'), 2) and (not @species.defs.CHANCE_OF_MATING? or Math.random() < @species.defs.CHANCE_OF_MATING)
        max = @get('max offspring')
        @set 'max offspring', Math.max(max/2, 1)
        @reproduce(nearest)
        @set 'max offspring', max
        @_timeLastMated = @environment.date
    else
      @wander(@get('speed') * Math.random() * 0.75)

  wander: (speed)->
    unless speed?
      maxSpeed = @get('speed')
      speed = (maxSpeed/2) + ExtMath.randomGaussian() * (maxSpeed/6)
    @set 'direction', (@get('direction') + ExtMath.randomGaussian()/10)
    @move(speed)

  chase: (agentDistance)->
    directionToAgent =  @_direction(@getLocation(), agentDistance.agent.getLocation())
    directionRelativeToMe = ExtMath.normalizeRads(directionToAgent - this.get('direction'))
    directionToMove = @get('direction') + directionRelativeToMe / 10
    @set('direction', directionToMove)
    speed = Math.min(@get('speed'), Math.sqrt(agentDistance.distanceSq))
    @move(speed)

  runFrom: (agentDistance)->
    directionToRunTo =  @_direction(@getLocation(), agentDistance.agent.getLocation()) + Math.PI + (ExtMath.randomGaussian()/3)
    directionToMove = (@get('direction')*19 + directionToRunTo) / 20
    @set('direction', directionToMove)
    @move(@get 'speed')

  move: (speed) ->
    dir = @get 'direction'
    return if speed is 0
    throw new Error('invalid speed') unless typeof(speed) is 'number'
    throw new Error('invalid direction') unless typeof(dir) is 'number'
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

    return ExtMath.normalizeRads(Math.atan2(dy, dx))

  _eatPrey: (agent)->
    food = agent.get('food')
    currEnergy = @get('energy')
    @set('energy', Math.min(@get('max energy'), currEnergy + food))
    agent.die()
    @_hasEatenOnce = true

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
    age = @get 'age'
    return 0 if @species.defs.MATURITY_AGE? and age < @species.defs.MATURITY_AGE
    return 0 if @get('max offspring') < 1
    return 0 unless @_hasEatenOnce
    return 0 if (@environment.date - @_timeLastMated) < 20

    proximityDesire = if @_nearestMate()? then 30 else 15
    reciprocationFactor = if @_nearestMatingMate()? then 15 else 0
    matingBonus = @get 'mating desire bonus'

    return proximityDesire + reciprocationFactor + matingBonus

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
      nearest = @_nearestAgentsMatching {types: predator, quantity: 1}
      return nearest[0] || null
    return null

  _nearestPrey: ->
    prey = @get('prey')
    if prey? and prey.length? and prey.length > 0
      nearest = @_nearestAgentsMatching {types: prey}
      return nearest[ExtMath.randomInt(nearest.length)]

    return null

  _nearestHidingPlace: ->
    hidingPlace = @get('hiding place')
    if hidingPlace? and hidingPlace.length? and hidingPlace.length > 0
      nearest = @_nearestAgentsMatching {types: hidingPlace, quantity: 1}
      return nearest[0] || null

    return null

  _nearestMate: ->
    desiredSex = if @get('sex') is 'male' then 'female' else 'male'
    trait = new Trait({name: 'sex', possibleValues: [desiredSex]})
    nearest = @_nearestAgentsMatching {types: [{name: @species.speciesName, traits: [trait]}], quantity: 1, mating: true}
    return nearest[0] || null

  _nearestMatingMate: ->
    desiredSex = if @get('sex') is 'male' then 'female' else 'male'
    trait  = new Trait({name: 'sex', possibleValues: [desiredSex]})
    trait2 = new Trait({name: 'current behavior', possibleValues: [BasicAnimal.BEHAVIOR.MATING]})
    nearest = @_nearestAgentsMatching {types: [{name: @species.speciesName, traits: [trait, trait2]}], quantity: 1, mating: true}
    return nearest[0] || null

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
      mating: false
      quantity: 3
      crossBarriers: false

    throw new Error("Must pass agent types array") unless opts.types? or typeof(opts.types) isnt 'object' or not opts.types.length?

    nearest = @_nearestAgents()
    returnedAgents = []
    for agentDistance in nearest
      agent = agentDistance.agent
      for type in opts.types
        throw new Error("types array must be an array of objects in format {name: 'foo', traits: []}") if typeof(type) isnt 'object' or not type.name?
        continue if type.name isnt agent.species.speciesName

        continue if agent is @
        continue if opts.camo and not opts.mating and agent instanceof BasicAnimal and ExtMath.randomFloat() > agent.get('chance of being seen')
        continue if agent.hasProp('current behavior') and agent.get('current behavior') is BasicAnimal.BEHAVIOR.HIDING
        continue if !opts.crossBarriers and @environment.crossesBarrier(@getLocation(), agent.getLocation())
        if type.traits? and type.traits.length > 0
          # All traits must match to be considered a valid agent match
          nextType = false
          for trait in type.traits
            nextType = true unless trait.isPossibleValue(agent.get(trait.name))
          continue if nextType

        returnedAgents.push agentDistance
        return returnedAgents if returnedAgents.length >= opts.quantity

    return returnedAgents

  _distanceSquared: (p1, p2)->
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    return (dx*dx + dy*dy)

  _getSurvivalChances: ->
    return 1.0 if @get('is immortal')

    basicPct = super()

    energy = @get 'energy'
    energyPct = 1 - Math.pow(1-(energy/100), 8)

    return basicPct * energyPct

class AgentDistance
  constructor: (@agent, @distanceSq)->
    undefined

