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
      'find public/ -type f -name "*.coffee" -delete'
      'coffee --compile --output public interactives/'
    ]
    jaded:
      jade:
        pretty: true
      staticPatterns: /^(app|interactives)(\/|\\)(.+)\.jade$/
