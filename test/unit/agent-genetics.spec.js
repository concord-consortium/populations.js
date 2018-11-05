// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Agent = require('models/agent');
const BasicPlant = require('models/agents/basic-plant');
const Environment = require('models/environment');
const Species = require('models/species');
const Trait   = require('models/trait');

const BioSpecies = {
  name: 'BioSpecies',
  chromosomeNames: ['1', '2', 'XY'],
  chromosomeGeneMap: {
    '1': ['C'],
    '2': [],
    'XY': []
  },

  chromosomesLength: {
    '1': 100000000,
    '2': 100000000,
    'XY': 70000000
  },

  geneList: {
    'color': {
      alleles: ['c', 'C'],
      start: 10000000,
      length: 10584
    }
  },

  alleleLabelMap: {
    'c': 'Color 1',
    'C': 'Color 2',
    'Y' : 'Y',
    ''  : ''
  },

  traitRules: {
    'color': {
      'blue':   [['c','c']],
      'purple': [['c','C']],
      'red':    [['C','C']]
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
};

const testSpecies = new Species({
  agentClass: Agent,
  geneticSpecies: BioSpecies,
  traits: [
    new Trait({
      name: 'color',
      possibleValues: ["a:c,b:c","a:c,b:C","a:C,b:c","a:C,b:C"],
      isGenetic: true
    })
  ]});

describe('Agent with genetics', function() {

  describe('has genetic-backed traits', () =>
    it('that function like normal traits', function() {
      const org1 = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:C,b:C', isGenetic: true})]);
      const org2 = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:c,b:C', isGenetic: true})]);
      const org3 = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:c,b:c', isGenetic: true})]);
      const org4 = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:C,b:c', isGenetic: true})]);

      expect(org1.get('color')).toEqual('red');
      expect(org2.get('color')).toEqual('purple');
      expect(org3.get('color')).toEqual('blue');
      return expect(org4.get('color')).toEqual('purple');
    })
  );

  return describe('can reproduce', () =>

    it('and create a newborn', function() {
      const mother = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:C,b:C', isGenetic: true})]);
      const father = testSpecies.createAgent([ new Trait({name: 'color', default: 'a:c,b:c', isGenetic: true})]);

      const offspring = mother.createOffspring(father);

      expect(offspring).toBeDefined();
      expect(offspring).not.toBeNull();

      expect(offspring.get('age')).toEqual(0);
      return expect(offspring.get('color')).toEqual('purple');
    })
  );
});

