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
env          = require 'environments/sunlight-field'

window.model = 
  run: ->
    plantSpecies.defs.CHANCE_OF_MUTATION = 0

    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png"
          traits: [
            new Trait {name: "size", default: 1}
            new Trait {name: "root size", default: 5}
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_2.png"
          traits: [
            new Trait {name: "size", default: 9}
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

    ### message script ###
    shownWinterMessage = false
    Events.addEventListener Environment.EVENTS.STEP, =>
      if shownWinterMessage then return

      if @env.get(0, 0, "season") is "winter"
        @showMessage "Winter has come and snow has fallen. <br/><br/>
                      All your plants have died. Boo hoo! <br/><br/>
                      But if they've flowered and dropped seeds maybe baby plants will grow.<br/>
                      Click 'OK' and let's see what happens.", true
        shownWinterMessage = true


  chartData: null
  chart: null
  setupChart: ->
    # setup chart data
    @chartData = new google.visualization.DataTable()
    @chartData.addColumn('string', 'Plant Type (Leaf Size)')
    @chartData.addColumn('number', 'Flowers')
    @chartData.addColumn({ type: 'string', role: 'style' })
    @chartData.addRows [
      ["1",  0, "color: #5942BF"]
      ["2",  0, "color: #904078"]
      ["3",  0, "color: #904078"]
      ["4",  0, "color: #904078"]
      ["5",  0, "color: #904078"]
      ["6",  0, "color: #904078"]
      ["7",  0, "color: #904078"]
      ["8",  0, "color: #904078"]
      ["9",  0, "color: #D34441"]
      ["10", 0, "color: #D34441"]
    ]

    # Set chart options
    options =
      title: 'Number of Flowers'
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
    @chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    @chart.draw(@chartData, options);

    Events.addEventListener Environment.EVENTS.STEP, =>
      unless @env.get(0, 0, "season") is "summer" then return
      existingCounts =
        1:  @chartData.getValue(0,1)
        5:  @chartData.getValue(4,1)
        9:  @chartData.getValue(8,1)
      counts =
        1: 0
        5: 0
        9: 0
      for agent in @env.agents
        counts[agent.get('size')] += 1 if agent.get('has flowers')

      changed = existingCounts[1] isnt counts[1] or
                existingCounts[5] isnt counts[5] or
                existingCounts[9] isnt counts[9]

      if changed
        @chartData.setValue(0, 1, counts[1])
        @chartData.setValue(4, 1, counts[5])
        @chartData.setValue(8, 1, counts[9])

        if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
          options.vAxis.gridlines.count = -1


        @chart.draw(@chartData, options)

  showMessage: (message, pause=false) ->
    if pause then @env.stop()
    helpers.showMessage message, @env.getView().view.parentElement, =>
      @env.start()

  preload: [
    "images/agents/varied-plants/buttons/seedpack_2.png",
    "images/agents/varied-plants/buttons/seedpack_6.png",
    "images/agents/varied-plants/buttons/seedpack_10.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupChart()
