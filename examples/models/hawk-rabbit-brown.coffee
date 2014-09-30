helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'
BasicAnimal = require 'models/basic-animal'

rabbitSpecies = require 'species/white-brown-rabbits'
hawkSpecies   = require 'species/hawks'
env           = require 'environments/snow'

window.model =
  brownness: 1
  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: rabbitSpecies
          imagePath: "images/agents/rabbits/rabbit2.png"
          traits: [
            new Trait {name: "mating desire bonus", default: -20}
            new Trait {name: "hunger bonus", default: -10}
            new Trait {name: "age", default: 3}
            new Trait {name: "resource consumption rate", default: 10}
            new Trait {name: "color", default: "white"}
          ]
          scatter: 30
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @env.setBackground("images/environments/snow-2.png")
    @hawkSpecies = hawkSpecies
    @rabbitSpecies = rabbitSpecies

    @addAgent(@hawkSpecies, [["mating desire bonus", -10]])
    @addAgent(@hawkSpecies, [["mating desire bonus", -10]])

    env.addRule new Rule
      action: (agent) =>
        if agent.species is rabbitSpecies
          if agent.get('color') is 'brown'
            agent.set 'chance of being seen', (0.6 - (@brownness*0.6))
          else
            agent.set 'chance of being seen', (@brownness*0.6)

  chartData1: null
  chart1: null
  setupGraph: ->
    # setup chart data
    @chartData1 = new google.visualization.DataTable()
    @_setupChartData(@chartData1)

    # Instantiate and draw our chart, passing in some options.
    options1 = @_getChartOptions("top")
    @chart1 = new google.visualization.ColumnChart(document.getElementById('chart1'));
    @chart1.draw(@chartData1, options1)

    Events.addEventListener Environment.EVENTS.STEP, =>
      counts =
        top: [0,0,0,0]

      # for agent in @env.agents
      #   if agent.species is @rabbitSpecies
      #     if agent.get('color') is "brown"
      #       counts.top[1] += 1
      #     else
      #       counts.top[2] += 1

      # for i in [0..1]
      #   @chartData1.setValue(i, 1, counts.top[i+1])
      counts.top = [2, 5, 14]

      # if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
      #   options.vAxis.gridlines.count = -1

      @chart1.draw(@chartData1, options1)

  _setupChartData: (chartData)->
    chartData.addColumn('string', 'Rabbit types')
    chartData.addColumn('number', 'Number of rabbits')
    chartData.addColumn({ type: 'string', role: 'style' })
    chartData.addRows [
      ["Brown",  2, "color: #904f10"]
      ["Sandy", 5, "color: #f2b05e"]
      ["White", 14, "color: #c5c4c3"]
    ]

  _getChartOptions: (titleMod)->
    # Set chart options
    return options =
      title: 'Rabbits remaining'
      hAxis:
        title: 'Rabbit types'
      vAxis:
        title: 'Number of rabbits'
        minValue: 0
        maxValue: 20
        gridlines:
          count: 6
      legend:
        position: 'none'
      width: 300
      height: 250
  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  countRabbits: ->
    whiteRabbits = 0
    brownRabbits = 0
    for a in @agentsOfSpecies(@rabbitSpecies)
      whiteRabbits++ if a.get('color') is 'white'
      brownRabbits++ if a.get('color') is 'brown'
    return [whiteRabbits, brownRabbits]

  setupTimer: ->
    backgroundChangeable = false
    changeInterval = 10

    Events.addEventListener Environment.EVENTS.RESET, =>
      @env.setBackground("images/environments/snow-2.png")

  changeBackground: (n)->
    return unless 0 < n < 10
    @env.setBackground("images/environments/snow-2.png")

  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  setupPopulationControls: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      @checkRabbits()
      @checkHawks()

  setProperty: (agents, prop, val)->
    for a in agents
      a.set prop, val

  addAgent: (species, properties=[])->
    agent = species.createAgent()
    agent.setLocation @env.randomLocation()
    for prop in properties
      agent.set prop[0], prop[1]
    @env.addAgent agent


  addedRabbits: false
  addedHawks: false
  numRabbits: 0
  checkRabbits: ->
    allRabbits = @agentsOfSpecies(@rabbitSpecies)

    @numRabbits = allRabbits.length

    if @numRabbits is 0
      if @addedRabbits and not @addedHawks
        @env.stop()
        @showMessage "Uh oh, all the rabbits have died!<br/>Did you add any plants? Reset the model and try it again."
        return

    if not @addedRabbits and @numRabbits > 0
      @addedRabbits = true

    if @addedRabbits and @numRabbits < 9
      @addAgent(@rabbitSpecies, [["resource consumption rate", 10]])
      @addAgent(@rabbitSpecies, [["resource consumption rate", 10]])
      # faking here
      color = if @brownness > 0.5 then "brown" else "white"
      @addAgent(@rabbitSpecies, [["resource consumption rate", 10],["color", color]])
      @addAgent(@rabbitSpecies, [["resource consumption rate", 10],["color", color]])

    if @numRabbits < 16
      @setProperty(allRabbits, "min offspring", 2)
      @setProperty(allRabbits, "speed", 70)
    else
      # @setProperty(allRabbits, "metabolism", 1)
      @setProperty(allRabbits, "mating desire bonus", -20)
      @setProperty(allRabbits, "hunger bonus", -10)
      @setProperty(allRabbits, "min offspring", 1)
      @setProperty(allRabbits, "speed", 50)

    if @numRabbits > 50
      @setProperty(allRabbits, "mating desire bonus", -40)

  checkHawks: ->
    allHawks = @agentsOfSpecies(@hawkSpecies)
    numHawks = allHawks.length

    if numHawks is 0
      if @addedHawks
        if @addedRabbits
          @env.stop()
          @showMessage "Uh oh, all the animals have died!<br/>Was there any food for the rabbits to eat? Reset the model and try it again."
        else
          @env.stop()
          @showMessage "Uh oh, all the hawks have died!<br/>Were there any rabbits for them to eat? Reset the model and try it again."
      return

    if not @addedHawks and numHawks > 0
      @addedHawks = true

    if @addedHawks and @numRabbits > 0 and numHawks < 2
      @addAgent @hawkSpecies

    if numHawks < 3 and @numRabbits > 0
      @setProperty(allHawks, "is immortal", true)
      @setProperty(allHawks, "mating desire bonus", -10)
      @setProperty(allHawks, "hunger bonus", 5)
    else
      if allHawks[0].get("is immortal")
        @setProperty(allHawks, "is immortal", false)

      if numHawks > 4
        @setProperty(allHawks, "mating desire bonus", -30)
        @setProperty(allHawks, "hunger bonus", -40)
      else
        @setProperty(allHawks, "mating desire bonus", -15)
        @setProperty(allHawks, "hunger bonus", -5)

  preload: [
    "images/agents/rabbits/rabbit2.png",
    "images/agents/hawks/hawk.png",
    "images/environments/snow-2.png"
  ]

window.onload = ->
  helpers.preload [model, env, rabbitSpecies, hawkSpecies], ->
    model.run()
    model.setupGraph()
    model.setupTimer()
    model.setupPopulationControls()
