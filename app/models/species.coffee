helpers   = require 'helpers'

defaultDefs =
  MAX_AGE: 1000
  MAX_HEALTH: 1
  CHANCE_OF_MUTATION: 0.2

module.exports = class Species

  constructor: ({
      @speciesName
      @individualName
      @agentClass
      @traits
      @imageRules
      @defs
      @reproductiveStrategy
      @mutationChance}) ->
    @defs = helpers.setDefaults(@defs || {}, defaultDefs)

  ###
    Create an agent of this species, with the traits defined in
    the species. Optionally, add a second set of trait definitions.
  ###
  createAgent: (extraTraits=[]) ->
    agent = new @agentClass {species: this}

    for trait in @traits
      agent.set trait.name, trait.getDefaultValue()
    for trait in extraTraits
      agent.set trait.name, trait.getDefaultValue()

    return agent

  ###
    opts.buttonImage (default = false)
  ###
  getImages: (agent, opts = {}) ->
    images = []
    for layer in @imageRules
      continue unless @_contextMatches(opts.context, layer.contexts)

      layer.selectedImage = null
      for imageRule in layer.rules
        if not imageRule.useIf? or imageRule.useIf.call @, agent
          layer.selectedImage = imageRule.image
          break
      images.push layer if layer.selectedImage?

    return images

  getTrait: (traitName) ->
    for trait in @traits
      return trait if trait.name is traitName
    return null

  addTrait: (trait) ->
    @traits.push trait

  setMutatable: (traitName, mutatable) ->
    trait = @getTrait traitName
    if trait?
      trait.mutatable = mutatable

  _contextMatches: (context, validContexts)->
    return true unless context?  # assume no context info means all contexts valid
    return true unless validContexts? and validContexts.length > 0  # if no valid contexts are supplied, assume all contexts valid

    return validContexts.indexOf(context) isnt -1