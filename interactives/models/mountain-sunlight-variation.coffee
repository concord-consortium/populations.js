helpers     = require 'helpers'
Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/sunlight-mountain'

window.model =
  emptyBarriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520]
  ]
  mountainBarriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520],
    [140, 490,  25,  30],
    [165, 450,  25,  70],
    [190, 300,  30, 220],
    [220, 150,  40, 370],
    [260,  70,  25, 450],
    [285,   0,  50, 520],
    [335,   0,  25, 490],
    [360,   0,  25, 335],
    [385,   0,  20, 260],
    [405,   0,  20, 160]
  ]
  run: ->
    plantSpecies.defs.CHANCE_OF_MUTATION = 0.21
    plantSpecies.setMutatable 'root size', false

    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          scatter: 8
          limit: 40
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

  setupMountains: ->
    mountains1 = document.getElementById('mountains1')
    mountains2 = document.getElementById('mountains2')
    mountains3 = document.getElementById('mountains3')
    mountains4 = document.getElementById('mountains4')
    mountains5 = document.getElementById('mountains5')

    mountains1.onclick = =>
      @_updateMountains "images/environments/mountains1.jpg", @emptyBarriers, 6, 6
    mountains2.onclick = =>
      @_updateMountains "images/environments/mountains2flipped.jpg", @mountainBarriers, 7, 5
    mountains3.onclick = =>
      @_updateMountains "images/environments/mountains3flipped.jpg", @mountainBarriers, 8, 4
    mountains4.onclick = =>
      @_updateMountains "images/environments/mountains4flipped.jpg", @mountainBarriers, 9, 3
    mountains5.onclick = =>
      @_updateMountains "images/environments/mountains5flipped.jpg", @mountainBarriers, 10, 2

    Events.addEventListener Environment.EVENTS.RESET, ->
      mountains1.click()

  _updateMountains: (imgPath, barriers, leftSunlight, rightSunlight)->
    @env.setBackground imgPath
    @env.setBarriers barriers
    for col in [0..60]
      light = if col > 30 then rightSunlight else leftSunlight
      for row in [0..52]
        @env.set col, row, "sunlight", light

    for agent in @env.agents
      loc = agent.getLocation()
      if @env.isInBarrier(loc.x, loc.y)
        agent.die()

  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  setupMessages: ->
    extinctionCount = 0 # this does NOT reset between runs
    successful = false  # this does NOT reset between runs
    userAddedAgents = false
    yearsSuccessful = 0 # don't win until final plants liev at least one year
    shownMessage = false
    allAgents = []

    Events.addEventListener Environment.EVENTS.RESET, ->
      userAddedAgents = false
      yearsSuccessful = 0 # don't win until final plants liev at least one year
      shownMessage = false
      allAgents = []

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, ->
      userAddedAgents = true

    Events.addEventListener Environment.EVENTS.SEASON_CHANGED, (evt)=>
      if !shownMessage
        if evt.detail.season is "winter" || evt.detail.season is "spring"
          return   # don't check on winter or spring, because it's hard for user to see what's happening
        allAgents = @env.agents
        allExtinct = false
        halfExtinct = false
        willAnyoneSurvive = false  # if half extinct but no one will survive (all wilted) wait until all are extinct
        if allAgents.length is 0
          allExtinct = true
        else
          sunlightTopLeft = @env.get(0,0,"sunlight")
          mountainHeight = sunlightTopLeft - 6
          if mountainHeight is 0
            return
          halfExtinct = @_getSideIsExtinct()
          if halfExtinct
            willAnyoneSurvive = @_getWillAnyoneSurvive()
        if allExtinct || halfExtinct
          if successful && (allExtinct || willAnyoneSurvive)
            # case 2
            @showMessage "The plants went extinct. Why did the plants go\nextinct when the mountains changed quickly?"
            env.stop()
            extinctionCount++
          else if extinctionCount is 0
            # case 1, first time
            if allExtinct
              @showMessage "Your plants went extinct. Click reset and try again."
              env.stop()
              extinctionCount++
            else if willAnyoneSurvive
              @showMessage "Your plants went extinct on one side. Remember, the challenge is to have flowering plants\ngrowing on both sides of the mountains. Click reset and try again."
              env.stop()
              extinctionCount++
          else
            # case 1, next times
            if allExtinct
              @showMessage "Your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height."
              env.stop()
              extinctionCount++
            else if willAnyoneSurvive
              @showMessage "Half your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height."
              env.stop()
              extinctionCount++
          shownMessage = true
          return
        # not extinct
        if mountainHeight is 4
          # end
          if evt.detail.season is "fall"
            # only end on fall so we can see flowers
            if @_atLeastTenPlantsHealthyOnBothSides()
              yearsSuccessful++
              if yearsSuccessful > 1
                successful = true
                if extinctionCount > 0
                  # case 1 success
                  @showMessage "Great job! The mountains grew slowly enough so that the plants could evolve.\nTake a Snapshot to help answer the question."
                  env.stop()
                  shownMessage = true
                else
                  # case 2 success
                  @showMessage "Congratulations! The mountains grew slowly and the plants had time to evolve.\n Take a Snapshot to help answer the question.\nThen click reset and try changing the environment quickly. What do you think will happen?"
                  env.stop()
                  shownMessage = true

  _getSideIsExtinct: ()->
    eastAlive = false
    westAlive = false
    for agent in @env.agents
      x = agent.getLocation().x
      if x < ((@env.columns / 2) * @env._columnWidth)
        eastAlive = true
      else
        westAlive = true
      if eastAlive && westAlive
        return false
    return true

  _getWillAnyoneSurvive: ()->
    for agent in @env.agents
      healthy = agent.get("health") > 0.99
      if healthy
        return true
    return false

  _atLeastTenPlantsHealthyOnBothSides: ->
    eastHealthyCount = 0
    westHealthyCount = 0
    for agent in @env.agents
      if agent.get("health") > 0.99 && !agent.get("is seed")
        x = agent.getLocation().x
        if x < ((@env.columns / 2) * @env._columnWidth)
          eastHealthyCount++
        else
          westHealthyCount++
      if eastHealthyCount >= 10 && westHealthyCount >= 10
        return true
    return false

  chartData: null
  chart: null
  setupChart: ->
    domChart = document.getElementById('chart')

    if domChart?
      toggleButton = document.getElementById('chart-visibility')
      if toggleButton?
        toggleButton.onclick = ->
          if toggleButton.innerHTML is "Show Graph"
            domChart.style.display = "block"
            toggleButton.innerHTML = "Hide Graph"
          else
            domChart.style.display = "none"
            toggleButton.innerHTML = "Show Graph"

      # init chart
      @chartData = new google.visualization.DataTable()
      @chartData.addColumn('string', 'Plant Type (Leaf Size)')
      @chartData.addColumn('number', 'Number of plants')
      @chartData.addColumn({ type: 'string', role: 'style' })
      @chartData.addRows [
        ["1",  0, "color: #5942BF"]
        ["2",  0, "color: #5F42B8"]
        ["3",  0, "color: #65429F"]
        ["4",  0, "color: #73419E"]
        ["5",  0, "color: #874084"]
        ["6",  0, "color: #904078"]
        ["7",  0, "color: #9F416B"]
        ["8",  0, "color: #B5435A"]
        ["9",  0, "color: #C84349"]
        ["10", 0, "color: #D34441"]
      ]

      # Set chart options
      options =
        title: 'Number of flowers'
        hAxis:
          title: 'Plant Type (Leaf Size)'
        vAxis:
          title: 'Flowers'
          minValue: 0
          maxValue: 10
          gridlines:
            count: 6
        legend:
          position: 'none'
        width: 500
        height: 400

      # Instantiate and draw our chart, passing in some options.
      @chart = new google.visualization.ColumnChart(domChart);
      @chart.draw(@chartData, options);

      Events.addEventListener Environment.EVENTS.STEP, =>
        unless @env.get(0, 0, "season") is "summer" then return
        counts = []; counts.push(0) for i in [0..9]
        for agent in @env.agents
          counts[agent.get('size')] += 1 if agent.get('has flowers')

        for i in [0..8]
          @chartData.setValue(i, 1, counts[i+1])

        if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
          options.vAxis.gridlines.count = -1

        @chart.draw(@chartData, options)

  preload: [
    "images/agents/varied-plants/buttons/seedpack_10.png",
    "images/environments/mountains1.jpg",
    "images/environments/mountains2flipped.jpg",
    "images/environments/mountains3flipped.jpg",
    "images/environments/mountains4flipped.jpg",
    "images/environments/mountains5flipped.jpg"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupMountains()
    model.setupMessages()
    model.setupChart()
