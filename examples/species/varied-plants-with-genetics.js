// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.VariedPlantsWithGeneticsSpecies = new Populations.Species({
  speciesName: "varied plants (genetics)",
  agentClass: Populations.BasicPlant,
  geneticSpecies: window.VariedPlantsGeneticSpecies,
  defs: {
    MAX_AGE: 10000,
    MAX_HEALTH: 1,
    SPROUT_AGE: 10,
    MATURITY_AGE: 25,
    CAN_SEED: true,
    IS_ANNUAL: true,
    CHANCE_OF_SEEDING: 0.6,
    CHANCE_OF_MUTATION: 0.2,
    INFO_VIEW_PROPERTIES: {
      "Leaf Size: ": 'size',
      "Root Size: ": 'root size'
    }
  },
  traits: [
    new Populations.Trait({name: "size", possibleValues: ['a:L1,b:L1','a:L1,b:L2','a:L2,b:L1','a:L1,b:L3','a:L3,b:L1','a:L2,b:L2','a:L1,b:L4','a:L4,b:L1','a:L2,b:L3','a:L3,b:L2','a:L2,b:L4','a:L4,b:L2','a:L3,b:L3','a:L3,b:L4','a:L4,b:L3','a:L4,b:L4'], mutatable: true, isGenetic: true, isNumeric: true}),
    new Populations.Trait({name: "root size", possibleValues: ['a:R1,b:R1','a:R1,b:R2','a:R2,b:R1','a:R1,b:R3','a:R3,b:R1','a:R2,b:R2','a:R1,b:R4','a:R4,b:R1','a:R2,b:R3','a:R3,b:R2','a:R2,b:R4','a:R4,b:R2','a:R3,b:R3','a:R3,b:R4','a:R4,b:R3','a:R4,b:R4'], mutatable: true, isGenetic: true, isNumeric: true})
  ],
  imageRules: [
    {
      name: 'plant',
      contexts: ['environment','info-tool','carry-tool'],
      rules: [
        {
          image: {
            path: "images/agents/varied-plants/seed.png"
          },
          useIf(agent) { return agent.get('age') < this.defs.SPROUT_AGE; }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves10.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 1) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted10.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 1) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves9.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 2) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted9.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 2) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves8.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 3) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted8.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 3) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves7.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 4) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted7.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 4) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves6.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 5) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted6.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 5) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves5.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 6) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted5.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 6) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves4.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 7) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted4.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 7) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves3.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 8) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted3.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 8) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves2.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 9) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted2.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 9) && (agent.get('health') <= 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves1.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 10) && (agent.get('health') > 0.99); }
        },
        {
          image: {
            path: "images/agents/varied-plants/leaves_wilted1.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent) { return (agent.get('size') === 10) && (agent.get('health') <= 0.99); }
        }
      ]
    },
    {
      name: 'roots',
      contexts: ['info-tool','carry-tool'],
      rules: [
        {
          image: {
            path: "images/agents/varied-plants/roots10.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 10); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots9.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 9); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots5.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 5); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots8.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 8); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots7.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 7); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots6.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 6); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots5.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 5); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots4.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 4); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots3.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 3); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots2.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 2); }
        },
        {
          image: {
            path: "images/agents/varied-plants/roots1.png",
            scale: 0.2,
            anchor: {
              x: 0.5,
              y: 0
            },
            position: {
              y: -2
            }
          },
          useIf(agent) { return (agent.get('age') >= this.defs.SPROUT_AGE) && (agent.get('root size') === 1); }
        }
      ]
    },
    {
      name: "flower",
      contexts: ['environment','info-tool','carry-tool'],
      rules: [
        {
          image: {
            path: "images/agents/varied-plants/flower1.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 10) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower2.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 9) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower3.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 8) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower4.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 7) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower5.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 6) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower6.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 5) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower7.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 4) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower8.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 3) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower9.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 2) && agent.get('has flowers'); }
        },
        {
          image: {
            path: "images/agents/varied-plants/flower10.png",
            scale: 0.2,
            position: {
              x: -3,
              y: -51
            }
          },
          useIf(agent) { return (agent.get('size') === 1) && agent.get('has flowers'); }
        }
      ]
    }
]});