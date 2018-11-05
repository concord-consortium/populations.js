/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Environment = require('models/environment');
const Rule        = require('models/rule');

const env = new Environment({
  columns:  45,
  rows:     45,
  imgPath: "images/environments/snow.png",
  wrapEastWest: false,
  wrapNorthSouth: false
});

require.register("environments/snow", (exports, require, module) => module.exports = env);
