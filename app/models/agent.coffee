AgentView = require 'views/agent-view'
helpers   = require 'helpers'

defaultProperties =
  'min offspring': 1
  'max offspring': 3
  'min offspring distance': 10
  'max offspring distance': 40
  'health': 1
  'is immortal': false
  'resource deficit': 0
  'resource consumption rate': 1

###
  The base agent class
###
module.exports = class Agent
  label: "organism"
  bred: false
  _viewLayer: 1

  constructor: ({@name, @environment, @species, x, y, additionalDefaults}) ->
    @_props = helpers.clone defaultProperties
    @_props = helpers.setDefaults(@_props, additionalDefaults) if additionalDefaults?
    @_view = new AgentView({agent: @})
    @_viewLayer = @species.viewLayer if @species?.viewLayer?
    if x? && y?
      @setLocation({x,y})
    @alleles = {}
    @makeNewborn()

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
    if @hasProp(prop) then val = @_props[prop]
    else val = @getEnvironmentProperty prop

    if !val? then throw new Error("Cannot find property "+prop)
    return val

  hasProp: (prop) ->
    return @_props[prop]?

  getAllProperties: ->
    return @_props

  getEnvironmentProperty: (prop) ->
    return null unless @environment?
    @environment.getAt @_x, @_y, prop

  setEnvironmentProperty: (prop, val) ->
    return unless @environment?
    @environment.setAt @_x, @_y, prop, val

  getImages: (opts = {})->
    @species.getImages this, opts

  getSize: ->
    if @species.defs.MATURITY_AGE
      maturity = @get('age') / @species.defs.MATURITY_AGE
      Math.min maturity, 1
    else
      1

  isDead: false

  die: ->
    @isDead = true

  step: ->
    @_incrementAge()
    @_checkSurvival()

  makeNewborn: ->
    @set('age', 0)

  ###
    Creates one or more offspring, depending on the min- and max- offspring
    properties, and places them in the environment.

    Returns the array of offspring.

    Only asexual for now
  ###
  reproduce: (mate) ->
    minOffspring = @get 'min offspring'
    maxOffspring = @get 'max offspring'
    numOffspring = minOffspring + ExtMath.randomInt(1 + maxOffspring - minOffspring)

    for i in [0...numOffspring]
      @createOffspring(mate)

  ###
    Returns an offspring and places it in the environment
  ###
  createOffspring: (mate) ->
    offspring = @_breed(mate)
    offspring._mutate(offspring.organism?)
    offspring.makeNewborn()
    offspring.resetGeneticTraits(!offspring.organism?)
    offspring.bred = true

    if @environment
      offspring.setLocation @_findOffspringLocation()
      @environment.addAgent offspring

    return offspring

  resetGeneticTraits: (createOrganism=true)->
    if @species.geneticSpecies?
      if createOrganism
        desired_sex = (if @hasProp('sex') && @get('sex') == 'male' then BioLogica.MALE else BioLogica.FEMALE)
        allele_set = []
        allele_set.push(allele) for own trait, allele of @alleles
        @organism = new BioLogica.Organism @species.geneticSpecies, allele_set.join(), desired_sex
      for trait in @species.traits
        if trait.isGenetic
          characteristic = @organism.getCharacteristic(trait.name)
          if trait.isNumeric
            @set trait.name, (if trait.float then parseFloat(characteristic) else parseInt(characteristic))
          else
            @set trait.name, characteristic

  canShowInfo: ->
    true

  zIndex: (val)->
    if val?
      @_zIndex = val
      return

    return if @_zIndex? then @_zIndex else @_y

  _clone: ->
    clone = @species.createAgent()
    for prop of @_props
      clone.set prop, @_props[prop]
    for trait, allele of @alleles
      clone.alleles[trait] = allele
    return clone

  _breed: (mate)->
    child = @_clone()
    if @species.geneticSpecies? && @organism? && mate?.organism?
      if @hasProp('sex') && @get('sex') is 'male'
        mother = mate.organism
        father = @organism
      else
        mother = @organism
        father = mate.organism
      child.organism = BioLogica.breed(mother, father, false) # TODO Support crossing over?
      if child.hasProp('sex')
        child.set('sex', if child.organism.sex is BioLogica.FEMALE then 'female' else 'male')
      for trait in @species.traits
        if trait.isGenetic
          # find the alleles and set them on the organism
          alleleStr = child.organism.getAlleleStringForTrait(trait.name)
          child.alleles[trait.name] = alleleStr
    return child

  _mutate: (skipGenetic=false)->
    for trait in @species.traits
      if trait.mutatable and Math.random() < @species.defs.CHANCE_OF_MUTATION
        if trait.isGenetic
          continue if skipGenetic
          currentVal = @alleles[trait.name]
          mutatedVal = trait.mutate currentVal
          @alleles[trait.name] = mutatedVal
        else
          currentVal = @get trait.name
          mutatedVal = trait.mutate currentVal
          @set trait.name, mutatedVal

  _findOffspringLocation: ->
    loc = @getLocation()

    minD = @get 'min offspring distance'
    maxD = @get 'max offspring distance'

    distance = ExtMath.randomValue minD, maxD
    angle    = Math.random() * 2 * Math.PI

    xStep = Math.floor distance * Math.sin angle
    yStep = Math.floor distance * Math.cos angle

    return {x: loc.x + xStep, y: loc.y + yStep}


  _incrementAge: ->
    @set('age', @get('age')+1)

  _consumeResources: ->
    food = @getEnvironmentProperty('food')
    consumption = @get('resource consumption rate')
    if food >= consumption
      @setEnvironmentProperty('food', food - consumption)
      @set('resource deficit', 0)
    else
      underfed = consumption - food
      currDeficit = @get('resource deficit')
      @set('resource deficit', currDeficit + underfed)
      @setEnvironmentProperty('food', 0)

  _checkSurvival: ->
    chance = if @hasProp('chance of survival') then @get('chance of survival') else @_getSurvivalChances()
    @die() if Math.random() > chance

  _getSurvivalChances: ->
    return 1.0 if @get('is immortal')

    age = @get('age')
    ageMax = @species.defs.MAX_AGE || 2000

    agePct = 1 - (age/ageMax)

    # TODO factor in HUNGER
    hunger = @get 'resource deficit'
    hungerPct = 1 - Math.pow(hunger/100, 2)

    healthPct = @get('health')/@species.defs.MAX_HEALTH

    return agePct * hungerPct * healthPct


