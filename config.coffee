exports.config =
  # See http://brunch.io/#documentation for docs.
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
    assets: /(interactives|assets)(\/|\\)/

  plugins:
    afterBrunch: [
      'find public/ -type f -name "*.coffee" -delete'
      'coffee --compile --output public app/interactives/'
    ]
