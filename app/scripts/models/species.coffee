module.exports = class Species
  
  constructor: ({
      @speciesName
      @individualName
      @agentClass
      @traits
      @imageRules
      @reproductiveStrategy
      @mutationChance}) ->

  createAgent: ->
    agent = new @agentClass {species: this}
    for trait in @traits
      agent.set trait.name, trait.getDefaultValue()
    return agent

  getImage: (agent) ->
    # simple implementation first, then we'll need to add layers
    for imageRule in @imageRules
      if imageRule.useIf agent
        return imageRule.url