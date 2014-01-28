require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'

plantSpecies = require 'species/varied-plants'

window.model = 
  run: ->
    env = new Environment
      columns:  58
      rows:     52
      imgPath: "images/environments/sun5levels.jpg"
      barriers: [
          [0, 0, 60, 520]
          [0, 0, 580, 40]
          [560, 0, 20, 580]
        ]
      wrapEastWest: true
      wrapNorthSouth: true

    for col in [0..58]
      for row in [0..52]
        sunlight = switch
          when row < 13 then 10
          when row < 22 then 8
          when row < 32 then 6
          when row < 41 then 4
          else 2

        env.set col, row, "sunlight", sunlight

    env.addRule new Rule
      test: (agent) ->
        return agent.get('age') > (plantSpecies.defs.SPROUT_AGE + 4)
      action: (agent) ->
        size     = agent.get 'size'
        sunlight = agent.get 'sunlight'
        diff = Math.abs((11 - size) - sunlight)
        health = 1 - (diff /  20)
        agent.set 'health', health

    env.addRule new Rule
      action: (agent)->
        immortal = agent.get('age') < (plantSpecies.defs.SPROUT_AGE + 10) or agent.get('health') >= 0.87
        agent.set('is immortal', immortal)

    env.addRule new Rule
      action: (agent)->
        flowers = agent.get('age') > plantSpecies.defs.MATURITY_AGE and agent.get('health') >= 0.95
        agent.set('has flowers', flowers)

    interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          scatter: 10
          traits: [
            new Trait {name: "size", possibleValues: [5, 10]}
          ]
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 1}
          ]
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 5}
          ]
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 10}
          ]
        }
      ]

    document.getElementById('environment').appendChild interactive.getEnvironmentPane()

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
      ["5",  0, "color: #904078"]
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
      legend:
        position: 'none'
      width: 400
      height: 400

    # Instantiate and draw our chart, passing in some options.
    @chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    @chart.draw(@chartData, options);

    Events.addEventListener Environment.EVENTS.STEP, =>
      existingCounts =
        1:  @chartData.getValue(0,1)
        5:  @chartData.getValue(1,1)
        10: @chartData.getValue(2,1)
      counts =
        1: 0
        5: 0
        10: 0
      for agent in @env.agents
        counts[agent.get('size')] += 1 if agent.get('has flowers')

      changed = existingCounts[1]  isnt counts[1] or
                existingCounts[5]  isnt counts[5] or
                existingCounts[10] isnt counts[10]

      if changed
        @chartData.setValue(0, 1, counts[1])
        @chartData.setValue(1, 1, counts[5])
        @chartData.setValue(2, 1, counts[10])

        @chart.draw(@chartData, options)

window.onload = ->
  model.run()

  model.setupChart()
