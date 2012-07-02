
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

    SOMETHING0 after 1002ms
    SOMETHING1 after 1012ms
    SOMETHING2 after 1012ms
    SOMETHING3 after 1012ms
    SOMETHING4 after 1012ms
    SOMETHING5 after 2012ms
    SOMETHING6 after 2012ms
    SOMETHING7 after 2013ms
    SOMETHING8 after 2016ms
    SOMETHING9 after 2016ms
    done
*/