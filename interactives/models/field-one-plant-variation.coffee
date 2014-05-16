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
    plantSpecies.defs.CHANCE_OF_MUTATION = 0.3
    plantSpecies.setMutatable 'root size', false

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
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

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
      counts = []; counts.push(0) for i in [0..9]
      for agent in @env.agents
        counts[agent.get('size')] += 1 if agent.get('has flowers')

      for i in [0..8]
        @chartData.setValue(i, 1, counts[i+1])

      if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
        options.vAxis.gridlines.count = -1

      @chart.draw(@chartData, options)

  preload: [
    "images/agents/varied-plants/buttons/seedpack_6.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupChart()
