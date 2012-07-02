
# Introduction
node-narrow is a library which shrinks a given callback parallel execution in a limited number of threads, receiving the bunch of data (array of tasks).

Inspired from [node-async#queue](https://github.com/caolan/async#queue).

# Synopsis
Push a big bunch of data and handle it in maximum 5 simultaneous threads:

	var Narrow = require('narrow');
	
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

Will output:

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
	
Timeouts support

	todo: document
	
See more examples in [examples](https://github.com/0ctave/node-narrow/tree/master/examples) directory.

# Installation
	npm install narrow