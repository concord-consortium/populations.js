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
    agent = new @agentClass({})
    for trait in @traits
      agent.setProperty trait.name, trait.getDefaultValue()
    return agent

  getImage: (agent) ->
