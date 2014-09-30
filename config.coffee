stylus = require './node_modules/stylus-brunch/node_modules/stylus'

exports.config =
  # See http://brunch.io/#documentation for docs.
  paths:
    watched: ['app','interactives','vendor']
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(bower_components)/

    stylesheets:
      joinTo:
        'css/app.css' : /^(app|vendor)/

  modules:
    nameCleaner: (path) ->
      path.replace(/^app\//, '')

  conventions:
    assets: /assets(\/|\\)/

  plugins:
    afterBrunch: [
      'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete'
      'echo -n "Building interactives..." && coffee --compile --output public interactives/'
    ]
    jaded:
      jade:
        pretty: true
      staticPatterns: /^(app|interactives)(\/|\\)(.+)\.jade$/
    stylus:
      defines:
        url: stylus.url()
      paths: [
        './app/assets/ui'
      ]

  overrides:
    production:
      plugins:
        afterBrunch: [
          'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete'
          'echo -n "Building interactives and digesting..." && coffee --compile --output public interactives/ && ./bin/digest'
        ]
