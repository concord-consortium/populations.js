// Generated by CoffeeScript 1.6.3
(function() {
  require.register("species/biologica/white-brown-rabbits", function(exports, require, module) {
    return module.exports = {
      name: 'Rabbits',
      chromosomeNames: ['1', '2', 'XY'],
      chromosomeGeneMap: {
        '1': [],
        '2': ['B'],
        'XY': []
      },
      chromosomesLength: {
        '1': 100000000,
        '2': 100000000,
        'XY': 70000000
      },
      geneList: {
        'color': {
          alleles: ['B', 'b'],
          start: 10000000,
          length: 10584
        }
      },
      alleleLabelMap: {
        'b': 'Brown',
        'B': 'White',
        'Y': 'Y',
        '': ''
      },
      traitRules: {
        'color': {
          'brown': [['b', 'b']],
          'white': [['B', 'B'], ['B', 'b']]
        }
      },
      /*
        Images are handled via the populations.js species
      */

      getImageName: function(org) {
        return void 0;
      },
      /*
        no lethal characteristics
      */

      makeAlive: function(org) {
        return void 0;
      }
    };
  });

}).call(this);