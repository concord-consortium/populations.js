exports.config =
  # See http://brunch.io/#documentation for docs.
  paths:
    watched: ['app','interactives','vendor']
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app(\/|\\)framework/
        'js/vendor.js': /^(bower_components)/

    stylesheets:
      joinTo:
        'css/app.css' : /^(app|vendor)/

  modules:
    nameCleaner: (path) ->
      path.replace(/^app\/framework\//, '')

  conventions:
    assets: /assets(\/|\\)/

  plugins:
    afterBrunch: [
      'find public/ -type f -name "*.coffee" -delete'
      'coffee --compile --output public interactives/'
    ]
