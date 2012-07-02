
require.paths.unshift(__dirname + '/../lib');

var Narrow = require('narrow');

/**
 * in 1 thread
 */
var narrow = new Narrow(function(str, callback){
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

    SOMETHING0 after 1002ms
    SOMETHING1 after 2012ms
    SOMETHING2 after 3012ms
    SOMETHING3 after 4012ms
    SOMETHING4 after 5012ms
    SOMETHING5 after 6016ms
    SOMETHING6 after 7016ms
    SOMETHING7 after 8016ms
    SOMETHING8 after 9016ms
    SOMETHING9 after 10016ms
*/