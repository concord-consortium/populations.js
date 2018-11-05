require.register "species/biologica/varied-plants", (exports, require, module) ->

  module.exports =

    name: 'VariedPlants'

    chromosomeNames: ['1', '2', 'XY']

    chromosomeGeneMap:
      '1': ['L4']
      '2': ['R4']
      'XY': []

    chromosomesLength:
      '1': 100000000
      '2': 100000000
      'XY': 70000000

    geneList:
      'size':
        alleles: ['L1', 'L2', 'L3', 'L4']
        start: 10000000
        length: 10584
      'root size':
        alleles: ['R1', 'R2', 'R3', 'R4']
        start: 70000000
        length: 9094

    alleleLabelMap:
      'L1': 'Tiny leaves'
      'L2': 'Small leaves'
      'L3': 'Large leaves'
      'L4': 'Huge leaves'
      'R1': 'Tiny roots'
      'R2': 'Small roots'
      'R3': 'Large roots'
      'R4': 'Huge roots'
      'Y' : 'Y'
      ''  : ''

    traitRules:
      'size':
        1:  [['L1','L1']]
        2:  [['L1','L2']]
        3:  [['L1','L3']]
        4:  [['L2','L2']]
        5:  [['L1','L4']]
        6:  [['L2','L3']]
        7:  [['L2','L4']]
        8:  [['L3','L3']]
        9:  [['L3','L4']]
        10: [['L4','L4']]

      'root size':
        1:  [['R1','R1']]
        2:  [['R1','R2']]
        3:  [['R1','R3']]
        4:  [['R2','R2']]
        5:  [['R1','R4']]
        6:  [['R2','R3']]
        7:  [['R2','R4']]
        8:  [['R3','R3']]
        9:  [['R3','R4']]
        10: [['R4','R4']]

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
