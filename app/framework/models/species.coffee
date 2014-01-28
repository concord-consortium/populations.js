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

  createAgent: ->
    agent = new @agentClass {species: this}
    for trait in @traits
      agent.set trait.name, trait.getDefaultValue()
    return agent

  ###
    opts.buttonImage (default = false)
  ###
  getImages: (agent, opts = {}) ->
    images = []
    for layer in @imageRules
      if (opts.buttonImage != layer.buttonImage) then continue

      layer.selectedImage = null
      for imageRule in layer.rules
        if imageRule.useIf.call @, agent
          layer.selectedImage = imageRule.image
          break
      images.push layer if layer.selectedImage?

    return images

  getTrait: (traitName)->
    for trait in @traits
      return trait if trait.name is traitName
