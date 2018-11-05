Agent = require 'models/agent'
BasicPlant = require 'models/agents/basic-plant'
Environment = require 'models/environment'
Species = require 'models/species'
Trait   = require 'models/trait'

BioSpecies =
  name: 'BioSpecies'
  chromosomeNames: ['1', '2', 'XY']
  chromosomeGeneMap:
    '1': ['C']
    '2': []
    'XY': []

  chromosomesLength:
    '1': 100000000
    '2': 100000000
    'XY': 70000000

  geneList:
    'color':
      alleles: ['c', 'C']
      start: 10000000
      length: 10584

  alleleLabelMap:
    'c': 'Color 1'
    'C': 'Color 2'
    'Y' : 'Y'
    ''  : ''

  traitRules:
    'color':
      'blue':   [['c','c']]
      'purple': [['c','C']]
      'red':    [['C','C']]

  ###
    Images are handled via the populations.js species
  ###
  getImageName: (org) ->
    undefined

  ###
    no lethal characteristics
  ###
  makeAlive: (org) ->
    undefined

testSpecies = new Species
  agentClass: Agent
  geneticSpecies: BioSpecies
  traits: [
    new Trait {
      name: 'color'
      possibleValues: ["a:c,b:c","a:c,b:C","a:C,b:c","a:C,b:C"]
      isGenetic: true
    }
  ]

describe 'Agent with genetics', ->

  describe 'has genetic-backed traits', ->
    it 'that function like normal traits', ->
      org1 = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:C,b:C', isGenetic: true}])
      org2 = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:c,b:C', isGenetic: true}])
      org3 = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:c,b:c', isGenetic: true}])
      org4 = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:C,b:c', isGenetic: true}])

      expect(org1.get('color')).toEqual 'red'
      expect(org2.get('color')).toEqual 'purple'
      expect(org3.get('color')).toEqual 'blue'
      expect(org4.get('color')).toEqual 'purple'

  describe 'can reproduce', ->

    it 'and create a newborn', ->
      mother = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:C,b:C', isGenetic: true}])
      father = testSpecies.createAgent([ new Trait {name: 'color', default: 'a:c,b:c', isGenetic: true}])

      offspring = mother.createOffspring(father)

      expect(offspring).toBeDefined()
      expect(offspring).not.toBeNull()

      expect(offspring.get('age')).toEqual 0
      expect(offspring.get('color')).toEqual 'purple'

