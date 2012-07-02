
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

var tasks = [];
for (var i = 0; i < 10; i++) {
    tasks.push('something' + i);
}

var start = new Date;

narrow.on('complete', function(result){
    console.log('%s after %dms', result, new Date - start);
});

narrow.pushAll(tasks, function(){
    console.log('done');
})

/* output:

    SOMETHING0 after 1003ms
    SOMETHING1 after 2013ms
    SOMETHING2 after 3013ms
    SOMETHING3 after 4013ms
    SOMETHING4 after 5013ms
    SOMETHING5 after 6013ms
    SOMETHING6 after 7017ms
    SOMETHING7 after 8017ms
    SOMETHING8 after 9017ms
    SOMETHING9 after 10017ms
    done
*/