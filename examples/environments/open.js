// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Environment = require('models/environment');
const Rule        = require('models/rule');

const env = new Environment({
  columns:  50,
  rows:     50,
  imgPath: "images/environments/green2.png",
  barriers: [],
  wrapEastWest: false,
  wrapNorthSouth: false
});

require.register("environments/open", (exports, require, module) => module.exports = env);
