
require.paths.unshift(__dirname + '/../lib');

var Narrow = require('narrow');

/**
 * in 5 threads
 */
var narrow = new Narrow(5, function(str, callback){
    setTimeout(function(){
        callback(null, str.toUpperCase());
    }, 1000)
})

var start = new Date;
for (var i = 0; i < 10; i++) {
    narrow.push('something' + i, function(err, result){
        console.log('%s after %dms', result, new Date - start);
    });
}

/* output:

    SOMETHING0 after 1001ms
    SOMETHING1 after 1012ms
    SOMETHING2 after 1012ms
    SOMETHING3 after 1012ms
    SOMETHING4 after 1012ms
    SOMETHING5 after 2016ms
    SOMETHING6 after 2017ms
    SOMETHING7 after 2017ms
    SOMETHING8 after 2017ms
    SOMETHING9 after 2017ms
*/