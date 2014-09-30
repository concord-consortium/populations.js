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
env          = require 'environments/sunlight-flowerboxes'

window.model = 
  run: ->
    plantSpecies.defs.CAN_SEED = false

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png"
          traits: [
            new Trait {name: "size", default: 1}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_2.png"
          traits: [
            new Trait {name: "size", default: 9}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

  chartData: null
  chart: null
  startData: false
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
      return if !@startData
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

  preload: [
    "images/agents/varied-plants/buttons/seedpack_2.png",
    "images/agents/varied-plants/buttons/seedpack_6.png",
    "images/agents/varied-plants/buttons/seedpack_10.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupChart()
    makeGraphButton = document.getElementById('make-graph')
    makeGraphButton.addEventListener 'click', ->
      model.startData = true
