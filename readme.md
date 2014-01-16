# [Populations.js](https://github.com/concord-consortium/populations.js)

This library originally evolved from the [Evolution Readiness](http://concord.org/projects/evolution-readiness) project created by
the [Concord Consortium](http://www.concord.org/)

## Compiling Coffeecript

The library is written in CoffeeScript, with JavaScript compiled to the /dist folder. To compile the src
code, first install coffeescript via Node. This should also install cake. Then

    cd populationsjs
    cake compile

This will concatenate the source code and convert it to JS, and place the single file populations.js in the dist folder.

To compile and minify in one step

    cake build

This will place both populations.js and populations.min.js in the dist folder.

## License

Populations.js is Copyright 2014 (c) by the Concord Consortium and is distributed under
any of the following licenses:

- [Simplified BSD](http://www.opensource.org/licenses/BSD-2-Clause),
- [MIT](http://www.opensource.org/licenses/MIT), or
- [Apache 2.0](http://www.opensource.org/licenses/Apache-2.0).