// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/biologica/white-brown-rabbits", (exports, require, module) =>

  module.exports = {

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
      'Y' : 'Y',
      ''  : ''
    },

    traitRules: {
      'color': {
        'brown':  [['b','b']],
        'white':  [['B','B'],['B','b']]
      }
    },

    /*
      Images are handled via the populations.js species
    */
    getImageName(org) {
      return undefined;
    },

    /*
      no lethal characteristics
    */
    makeAlive(org) {
      return undefined;
    }
  }
);
