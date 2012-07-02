
require.paths.unshift(__dirname + '/../lib');

var Narrow = require('narrow'),
    Test = require('test').Test;

var test = module.exports = new Test('Base', {
    
    'test single push' : function(assert, done) {
        
        var taskValue = 'some task';
        
        var narrow = new Narrow(function(task, callback){
            assert.strictEqual(task, taskValue);
            process.nextTick(function(){
                callback(null, task.toUpperCase());
            })
        })
        
        narrow.push(taskValue, function(err, result){
            assert.ok(!err);
            assert.strictEqual(result, taskValue.toUpperCase());
            done();
        })
    },
    
    'test single push error' : function(assert, done) {
        
        var taskValue = 'some task',
            errorValue = 'something went wrong';
        
        var narrow = new Narrow(function(task, callback){
            process.nextTick(function(){
                callback(errorValue);
            })
        })
        
        var i = 0, done2 = function(){
            if (++i == 2) done();
        }
        
        narrow.on('error', function(err, task){
            assert.strictEqual(task, taskValue);
            assert.strictEqual(err, errorValue);
            done2();
        })
        
        narrow.push(taskValue, function(err){
            assert.strictEqual(err, errorValue);
            done2();
        })
    },
    
    'test single push emit complete' : function(assert, done) {
        
        var taskValue = 'some task';
        
        var narrow = new Narrow(function(task, callback){
            assert.strictEqual(task, taskValue);
            process.nextTick(function(){
                callback(null, task.toUpperCase());
            })
        })
        
        narrow.push(taskValue);
        
        narrow.on('complete', function(result, task){
            assert.strictEqual(result, taskValue.toUpperCase());
            assert.strictEqual(task, taskValue);
            done();
        })
    },
    
    'test pushAll' : function(assert, done) {
        
        var tasks = ['foo', 'bar', 'baz'];
        
        var narrow = new Narrow(function(task, callback){
            process.nextTick(function(){
                callback(null, task.toUpperCase());
            })
        })
        
        narrow.pushAll(tasks, function(err, result){
            assert.ok(!err);
            assert.deepEqual(result, ['FOO', 'BAR', 'BAZ']);
            done();
        })
    },
    
    'test pushAll error' : function(assert, done) {
        
        var tasks = ['foo', 'bar', 'baz'],
            errorValue = 'something went wrong';
        
        var narrow = new Narrow(function(task, callback){
            process.nextTick(function(){
                if (task == 'bar') {
                    callback(errorValue);
                }
                else {
                    callback(null, task.toUpperCase());
                }
            })
        })
        
        var i = 0, done2 = function(){
            if (++i == 2) done();
        }
        
        narrow.on('error', function(err){
            assert.strictEqual(err, errorValue);
            done2();
        })
        
        narrow.pushAll(tasks, function(err, result){
            assert.ok(!err);
            assert.deepEqual(result, ['FOO', 'BAZ']);
            done2();
        })
    }
    
})

if (!module.parent) {
    test.run();
}