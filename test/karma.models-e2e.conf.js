// Karma configuration

module.exports = function(karma) {
  karma.set({

    // base path, that will be used to resolve files and exclude
    basePath: '../',


    // frameworks to use
    frameworks: ['ng-scenario'],


    // list of files / patterns to load in the browser
    files: [
        'test/models/**/*.coffee',
        {pattern: 'public/**/*.css', included: false},
        {pattern: 'public/**/*.js', included: false},
        {pattern: 'public/**/*.html', included: false}
    ],

    // list of files to exclude
    exclude: [
        // 'vendor/angular-mocks/angular-mocks.min.js',
    ],

    preprocessors: {
      '**/*.coffee': 'coffee'
    },

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: true
      }
    },


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],


    // web server port
    port: 9876,


    // cli runner port
    runnerPort: 9100,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: karma.LOG_DISABLE || karma.LOG_ERROR || karma.LOG_WARN || karma.LOG_INFO || karma.LOG_DEBUG
    logLevel: karma.LOG_INFO,


    urlRoot: '/__karma/',


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['Chrome'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Plugins to load
    plugins: [
        'karma-ng-scenario',
        'karma-coffee-preprocessor',
        'karma-chrome-launcher'
    ],


    proxies: {
      '/': 'http://localhost:3333/'
    },

    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
