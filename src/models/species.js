// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import * as helpers from '../helpers';

const defaultDefs = {
  MAX_AGE: 1000,
  MAX_HEALTH: 1,
  CHANCE_OF_MUTATION: 0.2
};

export default class Species {

  // coffeelint: disable=indentation
  constructor({
      speciesName,
      individualName,
      agentClass,
      traits,
      viewLayer,
      imageProperties,
      imageRules,
      defs,
      reproductiveStrategy,
      geneticSpecies,
      mutationChance}) {
    this.speciesName = speciesName;
    this.individualName = individualName;
    this.agentClass = agentClass;
    this.traits = traits;
    this.viewLayer = viewLayer;
    this.imageProperties = imageProperties;
    this.imageRules = imageRules;
    this.defs = defs;
    this.reproductiveStrategy = reproductiveStrategy;
    this.geneticSpecies = geneticSpecies;
    this.mutationChance = mutationChance;
    this.defs = helpers.setDefaults(this.defs || {}, defaultDefs);
    this._parsePreloads();
  }
  // coffeelint: enable=indentation

  /*
    Create an agent of this species, with the traits defined in
    the species. Optionally, add a second set of trait definitions.
  */
  createAgent(extraTraits) {
    if (extraTraits == null) { extraTraits = []; }
    const agent = new this.agentClass({species: this});

    for (var trait of Array.from(this.traits)) {
      if (trait.isGenetic) {
        agent.alleles[trait.name] = trait.getDefaultValue();
      } else {
        agent.set(trait.name, trait.getDefaultValue());
      }
    }
    for (trait of Array.from(extraTraits)) {
      if (trait.isGenetic) {
        agent.alleles[trait.name] = trait.getDefaultValue();
      } else {
        agent.set(trait.name, trait.getDefaultValue());
      }
    }

    agent.resetGeneticTraits();

    return agent;
  }

  /*
    opts.buttonImage (default = false)
  */
  getImages(agent, opts) {
    if (opts == null) { opts = {}; }
    const images = [];
    for (let layer of Array.from(this.imageRules)) {
      if (!this._contextMatches(opts.context, layer.contexts)) { continue; }

      layer.selectedImage = null;
      for (let imageRule of Array.from(layer.rules)) {
        if ((imageRule.useIf == null) || imageRule.useIf.call(this, agent)) {
          layer.selectedImage = imageRule.image;
          break;
        }
      }
      if (layer.selectedImage != null) { images.push(layer); }
    }

    return images;
  }

  getTrait(traitName) {
    for (let trait of Array.from(this.traits)) {
      if (trait.name === traitName) { return trait; }
    }
    return null;
  }

  addTrait(trait) {
    return this.traits.push(trait);
  }

  setMutatable(traitName, mutatable) {
    const trait = this.getTrait(traitName);
    if (trait != null) {
      return trait.mutatable = mutatable;
    }
  }

  _contextMatches(context, validContexts){
    if (context == null) { return true; }  // assume no context info means all contexts valid
    if ((validContexts == null) || !(validContexts.length > 0)) { return true; }  // if no valid contexts are supplied, assume all contexts valid

    return validContexts.indexOf(context) !== -1;
  }

  _parsePreloads() {
    this.preload = [];
    if (this.imageRules == null) { return; }
    return (() => {
      const result = [];
      for (var layer of Array.from(this.imageRules)) {
        if (layer.rules == null) { continue; }
        result.push((() => {
          const result1 = [];
          for (var imageRule of Array.from(layer.rules)) {
            if ((imageRule.image != null ? imageRule.image.path : undefined) != null) { this.preload.push(imageRule.image.path); }
            if ((imageRule.image != null ? imageRule.image.animations : undefined) == null) { continue; }
            result1.push((() => {
              const result2 = [];
              for (let animation of Array.from(imageRule.image.animations)) {
                if (animation.path != null) { result2.push(this.preload.push(animation.path)); } else {
                  result2.push(undefined);
                }
              }
              return result2;
            })());
          }
          return result1;
        })());
      }
      return result;
    })();
  }
};
