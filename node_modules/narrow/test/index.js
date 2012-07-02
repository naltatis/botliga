
require.paths.unshift(__dirname + '/../lib');

var Narrow = require('narrow'),
    Suite = require('test').Suite;

var suite = new Suite('Narrow testing');

['base'].forEach(function(test){
    suite.add(require('./' + test));
})

suite.run();