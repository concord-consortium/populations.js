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

plantSpecies  = require 'species/fast-plants-roots'
rabbitSpecies = require 'species/varied-rabbits'
env           = require 'environments/dam'

window.model =
  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: []
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies
    @rabbitSpecies = rabbitSpecies

    @_reset()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @_reset()

  _reset: ->
    @env.setBackground("images/environments/dam-rv-year0.png")
    @damRemoved = false
    @env.setBarriers [[0, 240, 500, 50]]
    @_setEnvironmentProperty('water', 10, true)
    @_setEnvironmentProperty('water',  0, false)
    @_addPlants()
    @_addRabbits()

  _addPlants: ->
    for i in [0...105]
      @_createPlant((i%3)+1, true)
    for i in [0...35]
      @_createPlant(3, false)

  _addRabbits: ->
    for i in [0...60]
      @_createRabbit((i%3)+1, true)
    for i in [0...20]
      @_createRabbit(3, false)

  _createPlant: (size, north)->
    newPlant = @plantSpecies.createAgent()
    newPlant.set("growth rate", 0.04)
    newPlant.set("age of maturity", 10)
    newPlant.set("population size modifier", 0)
    newPlant.set("roots", size)

    loc = if north then @env.randomLocationWithin(0,   0, 500, 250, true) else @env.randomLocationWithin(0, 250, 500, 250, true)

    newPlant.setLocation loc
    @env.addAgent newPlant

  _createRabbit: (size, north)->
    newRabbit = @rabbitSpecies.createAgent()
    newRabbit.set('age', 100)
    newRabbit.set("size", size)

    loc = if north then @env.randomLocationWithin(0,   0, 500, 250, true) else @env.randomLocationWithin(0, 250, 500, 250, true)

    newRabbit.setLocation loc
    @env.addAgent newRabbit

  chartData1: null
  chartData2: null
  chart1: null
  chart2: null
  setupCharts: ->
    # setup chart data
    @chartData1 = new google.visualization.DataTable()
    @chartData2 = new google.visualization.DataTable()
    @_setupChartData(@chartData1)
    @_setupChartData(@chartData2)

    # Instantiate and draw our chart, passing in some options.
    options1 = @_getChartOptions("top")
    options2 = @_getChartOptions("bottom")
    @chart1 = new google.visualization.ColumnChart(document.getElementById('chart1'));
    @chart2 = new google.visualization.ColumnChart(document.getElementById('chart2'));
    @chart1.draw(@chartData1, options1)
    @chart2.draw(@chartData2, options2)

    updateCounts = =>
      counts =
        top: [0,0,0,0]
        bottom: [0,0,0,0]

      for agent in @env.agents
        if agent.species is @rabbitSpecies
          if agent.getLocation().y < (@env.rows * @env._rowHeight)/2
            counts.top[agent.get('size')] += 1
          else
            counts.bottom[agent.get('size')] += 1

      for i in [0..2]
        @chartData1.setValue(i, 1, counts.top[i+1])
        @chartData2.setValue(i, 1, counts.bottom[i+1])

      # if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
      #   options.vAxis.gridlines.count = -1

      @chart1.draw(@chartData1, options1)
      @chart2.draw(@chartData2, options2)
    updateCounts()

    Events.addEventListener Environment.EVENTS.STEP, updateCounts

  _setupChartData: (chartData)->
    chartData.addColumn('string', 'Rabbit types')
    chartData.addColumn('number', 'Number of rabbits')
    chartData.addColumn({ type: 'string', role: 'style' })
    chartData.addRows [
      ["Small",  0, "color: #FF0000"]
      ["Medium", 0, "color: #FF0000"]
      ["Big",    0, "color: #FF0000"]
    ]

  _getChartOptions: (titleMod)->
    # Set chart options
    return options =
      title: 'Rabbits in '+titleMod+' half of the field'
      hAxis:
        title: 'Rabbit types'
      vAxis:
        title: 'Number of rabbits'
        minValue: 0
        maxValue: 50
        gridlines:
          count: 6
      legend:
        position: 'none'
      width: 300
      height: 250

  _agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  damRemoved: false
  setupControls: ->
    removeDamButton = document.getElementById('remove-button')
    removeDamButton.onclick = =>
      unless @damRemoved
        @damRemoved = true
        # fast-forward to the beginning of the first year
        @env.date = Math.floor(10000/Environment.DEFAULT_RUN_LOOP_DELAY)-1
        @env.setBarriers []

    noneHighlightRadio = document.getElementById('highlight-none')
    smallHighlightRadio = document.getElementById('highlight-small')
    mediumHighlightRadio = document.getElementById('highlight-medium')
    bigHighlightRadio = document.getElementById('highlight-big')

    noneHighlightRadio.onclick = =>
      @_highlight -1
    smallHighlightRadio.onclick = =>
      @_highlight 1
    mediumHighlightRadio.onclick = =>
      @_highlight 2
    bigHighlightRadio.onclick = =>
      @_highlight 3

    Events.addEventListener Environment.EVENTS.RESET, =>
      noneHighlightRadio.click()

  _highlight: (size)->
    for agent in @env.agents
      if agent.species is @rabbitSpecies
        agent.set 'glow', (agent.get('size') is size)

  setupTimer: ->
    backgroundChangeable = false
    changeInterval = 10
    waterLevel = 0
    yearSpan = document.getElementById('year')
    waterLevelIndicator = document.getElementById('water-level-indicator')
    Events.addEventListener Environment.EVENTS.STEP, =>
      unless @damRemoved
        # time doesn't pass until the dam is built
        @env.date = 0
        return
      t = Math.floor(@env.date * Environment.DEFAULT_RUN_LOOP_DELAY / 1000) # this will calculate seconds at default speed

      year = t/changeInterval
      waterLevel = Math.min(10, year)
      waterLevelPct = waterLevel*10
      @_setEnvironmentProperty('water', waterLevel)
      # Update vertical bar level indicator in page
      waterLevelIndicator.style.height = ""+waterLevelPct+"%"
      if t % changeInterval is 0 and backgroundChangeable
        @_changeBackground(year)
        yearSpan.innerHTML = ""+year
        backgroundChangeable = false
      else if t % changeInterval isnt 0
        backgroundChangeable = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      yearSpan.innerHTML = "1"
      waterLevelIndicator.style.height = "0%"

  _changeBackground: (n)->
    return unless 0 < n < 11
    @env.setBackground("images/environments/dam-rv-year"+n+".png")

  _setAgentProperty: (agents, prop, val)->
    for a in agents
      a.set prop, val

  _setAgentProperty: (agents, prop, val)->
    for a in agents
      a.set prop, val

  _setEnvironmentProperty: (prop, val, all=false)->
    for row in [0..(@env.rows)]
      if all or row > @env.rows/2
        for col in [0..(@env.columns)]
          @env.set col, row, prop, val

  _addAgent: (species, properties=[])->
    agent = species.createAgent()
    agent.setLocation @env.randomLocation()
    for prop in properties
      agent.set prop[0], prop[1]
    @env.addAgent agent

  setupPopulationMonitoring: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      # Check population levels and adjust accordingly
      @_setPlantGrowthRate()
      @_setRabbitGrowthRate()
      if Math.random() < 0.1
        @_makeLandFertile()


  _plantsExist: false
  _setPlantGrowthRate: ->
    allPlants = @_agentsOfSpecies @plantSpecies
    if allPlants.length < 1
      @_plantsExist = false
      return;
    else
      @_plantsExist = true

    varieties = [[], [], [], [], [], []]
    for plant in allPlants
      rootSize = plant.get("roots")
      adder = if plant.getLocation().y > 250 then 3 else 0
      varieties[((rootSize - 1) + adder)].push(plant)

    for variety in varieties
      @_setGrowthRateForVariety(variety)

  _setRabbitGrowthRate: ->
    allRabbits = @_agentsOfSpecies @rabbitSpecies
    varieties = [[], [], [], [], [], []]
    for rabbit in allRabbits
      rabbitSize = rabbit.get("size")
      adder = if rabbit.getLocation().y > 250 then 3 else 0
      varieties[((rabbitSize - 1) + adder)].push(rabbit)

    for variety in varieties
      @_dontLetRabbitsDie(variety)

  _setGrowthRateForVariety: (plants)->
    plantSize = plants.length
    populationSizeModifier = 0.0
    if plantSize < 10
      populationSizeModifier = 0.7
    else if plantSize < 15
      populationSizeModifier = 0.4
    else if plantSize < 40
      populationSizeModifier = 0.1
    else if plantSize < 60
      populationSizeModifier = 0.0
    else if plantSize < 160
      populationSizeModifier = -0.02
    else if plantSize < 190
      populationSizeModifier = -0.03
    else if plantSize < 230
      populationSizeModifier = -0.05
    else
      i = plantSize-1
      while i > 0
        plants[i].die()
        i -= 5

    for plant in plants
      plant.set "population size modifier", populationSizeModifier

  _dontLetRabbitsDie: (rabbits)->
    rabbitsSize = rabbits.length
    maxOffspring = 6
    matingDistance = 90
    resourceConsumptionRate = 15
    metabolism = 2
    isImmortal = false

    if rabbitsSize < 3 && rabbitsSize > 0 && rabbits[0].get("size") == 3 && @_plantsExist
      maxOffspring = 12
      matingDistance = 250
      resourceConsumptionRate = 0
      metabolism = 1
      age = 30
      isImmortal = true
    else if rabbitsSize < 4 && rabbitsSize > 0 && rabbits[0].get("size") == 3 && @_plantsExist
      maxOffspring = 10
      matingDistance = 170
      resourceConsumptionRate = 1
      metabolism = 1
    else if rabbitsSize < 5 && rabbitsSize > 0 && rabbits[0].get("size") == 3
      maxOffspring = 9
      matingDistance = 160
      resourceConsumptionRate = 4
      metabolism = 1
    else if rabbitsSize < 6
      maxOffspring = 8
      matingDistance = 140
      resourceConsumptionRate = 5
      metabolism = 1
    else if rabbitsSize < 7
      maxOffspring = 7
      matingDistance = 130
      resourceConsumptionRate = 8
      metabolism = 2
    else if rabbitsSize < 20
    else if rabbitsSize < 25
      maxOffspring = 5
      matingDistance = 80
      resourceConsumptionRate = 16
      metabolism = 3
    else if rabbitsSize < 35
      maxOffspring = 2
      matingDistance = 80
      resourceConsumptionRate = 18
      metabolism = 5
    else
      maxOffspring = 0
      resourceConsumptionRate = 18
      metabolism = 9

    for rabbit in rabbits
      rabbit.set "max offspring", maxOffspring
      rabbit.set "mating distance", matingDistance
      rabbit.set "resource consumption rate", resourceConsumptionRate
      rabbit.set "metabolism", metabolism
      rabbit.set "is immortal", isImmortal

  _makeLandFertile: ->
    # TODO Implment this!
    # env.replenishResources()
    return
    # FIXME What does this do?
    # allPlants = @_agentsOfSpecies @plantSpecies
    # for plant in allPlants
    #   loc = plant.getLocation()
    #   if loc.y > 228 && loc.y < 260
    #     plant.die()

  preload: [
    "images/environments/dam-rv-year0.png",
    "images/environments/dam-rv-year1.png",
    "images/environments/dam-rv-year2.png",
    "images/environments/dam-rv-year3.png",
    "images/environments/dam-rv-year4.png",
    "images/environments/dam-rv-year5.png",
    "images/environments/dam-rv-year6.png",
    "images/environments/dam-rv-year7.png",
    "images/environments/dam-rv-year8.png",
    "images/environments/dam-rv-year9.png",
    "images/environments/dam-rv-year10.png"
  ]

window.onload = ->
  helpers.preload [model, env, rabbitSpecies, plantSpecies], ->
    model.run()
    model.setupControls()
    model.setupCharts()
    model.setupTimer()
    model.setupPopulationMonitoring()
