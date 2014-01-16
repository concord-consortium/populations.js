exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/app.js': /^(app)/
        'js/vendor.js': /^vendor/

    stylesheets:
      joinTo:
        'css/app.css' : /^(app|vendor)/

  modules:
    nameCleaner: (path) ->
      path.replace(/^app\/scripts\//, '')