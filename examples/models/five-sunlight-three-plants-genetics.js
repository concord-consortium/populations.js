// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const plantSpecies = window.VariedPlantsWithGeneticsSpecies;

window.model = {
  run() {
    plantSpecies.defs.CAN_SEED = false;

    this.interactive = new Populations.Interactive({
      environment: env,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png",
          traits: [
            new Populations.Trait({name: "size", default: "a:L1,b:L1", isGenetic: true, isNumeric: true}),
            new Populations.Trait({name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true})
          ],
          limit: 20
        },
        {
          species: plantSpecies,
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png",
          traits: [
            new Populations.Trait({name: "size", default: "a:L1,b:L4", isGenetic: true, isNumeric: true}),
            new Populations.Trait({name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true})
          ],
          limit: 20
        },
        {
          species: plantSpecies,
          imagePath: "images/agents/varied-plants/buttons/seedpack_2.png",
          traits: [
            new Populations.Trait({name: "size", default: "a:L3,b:L4", isGenetic: true, isNumeric: true}),
            new Populations.Trait({name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true})
          ],
          limit: 20
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.env = env;
    return this.plantSpecies = plantSpecies;
  },

  preload: [
    "images/agents/varied-plants/buttons/seedpack_2.png",
    "images/agents/varied-plants/buttons/seedpack_6.png",
    "images/agents/varied-plants/buttons/seedpack_10.png"
  ]
};

window.onload = () =>
Populations.helpers.preload([model, env, plantSpecies], () => model.run())
;
