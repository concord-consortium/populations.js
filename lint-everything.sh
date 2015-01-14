#!/bin/sh

find app -name '*.coffee' | xargs coffeelint
find examples -name '*.coffee' | xargs coffeelint
find test -name '*.coffee' | xargs coffeelint

