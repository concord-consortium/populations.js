// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const stylus = require('./node_modules/stylus');

exports.config = {
  // See http://brunch.io/#documentation for docs.
  paths: {
    watched: ['app','examples','vendor']
  },
  files: {
    javascripts: {
      joinTo: {
        'js/app.js': /^app/,
        'js/vendor.js': /^(bower_components)/
      }
    },

    stylesheets: {
      joinTo: {
        'css/app.css' : /^(app|vendor)/
      }
    }
  },

  modules: {
    nameCleaner(path) {
      return path.replace(/^app\//, '');
    }
  },

  conventions: {
    assets: /examples(\/|\\)/
  },

  plugins: {
    afterBrunch: [
      'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete',
      'echo -n "Building examples..." && coffee --compile --output public examples/',
      'echo -n "Cleaning ui assets..." && rm -rf public/ui'
    ],
    stylus: {
      defines: {
        url: stylus.url()
      },
      paths: [
        './app/assets/ui'
      ]
    }
  },

  overrides: {
    production: {
      plugins: {
        afterBrunch: [
          'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete',
          'echo -n "Building examples and digesting..." && node_modules/.bin/coffee --compile --output public examples/ && ./bin/digest',
          'echo -n "Cleaning ui assets..." && rm -rf public/ui'
        ]
      }
    }
  }
};
