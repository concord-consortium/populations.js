# [Populations.js](https://github.com/concord-consortium/populations.js)

This library originally evolved from the [Evolution Readiness](http://concord.org/projects/evolution-readiness) project created by
the [Concord Consortium](http://www.concord.org/)

## Using the Populations library

In the browser

```
  <html>
    <head>
      <script src="path/to/populations.js"></script>
      <script>
        var mySpecies = new Populations.Species(...);
        var env = new Populations.Environment(...);
        var interactive = new Populations.Interactive(...);
      </script>
    </head>
    <body>
      <div id="environment" />
    </body>
  </html>
```

Or imported via NPM

`npm install populations.js`

```
import {Species, Environment, Interactive} from 'populations.js';

var mySpecies = new Species(...);
var env = new Environment(...);
var interactive = new Interactive(...);
```


## Building and Running the project

Install global dependencies

* [Node](http://nodejs.org/) [Download an installer](http://nodejs.org/download/) or run `brew install node`
* [Bower](http://bower.io/) Run `npm install -g bower`

Install local dependencies

```
  npm install
  bower install
```

Build the project

```
  npm run build
```

This builds the JS in dist/ and also copies the examples/ and build library into public/

View public/ using something like

```
  live-server public
```

### Running the tests

Run this command:

```
  npm test
```

A new Chrome window will open, and the results of the tests will be shown in your console.

If you have the server running (`npm start`) then any time you update a file the tests will
be re-run.

## License

Populations.js is Copyright 2014 (c) by the Concord Consortium and is distributed under
any of the following licenses:

- [Simplified BSD](http://www.opensource.org/licenses/BSD-2-Clause),
- [MIT](http://www.opensource.org/licenses/MIT), or
- [Apache 2.0](http://www.opensource.org/licenses/Apache-2.0).
