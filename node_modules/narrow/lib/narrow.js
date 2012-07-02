/*
  Copyright 2011 Yuriy Bogdanov <chinsay@gmail.com>

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/

/**
 * Narrow construct
 *
 * usage:
 *      
 *      // 1 thread (default)
 *      var narrow = new Narrow(function(task, callback){})
 *      // 10 threads
 *      var narrow = new Narrow(10, function(task, callback){})
 *      
 *
 */
var Narrow = function(threads, body) {
    
    if (arguments.length < 2) {
        body = threads;
        threads = 1;
    }
    
    this.body = body;
    this.threads = threads;
    
    this._running = true;
    this._timeout = 0;
    this._buffer = [];
    this._inprog = 0;
    this._complete = 0;
    this._total = 0;
    
    // Process new tasks when free
    this.on('free', this._process.bind(this));
}

// Inherits from process.EventEmitter
Narrow.prototype.__proto__ = process.EventEmitter.prototype;

/**
 * Starts narrow execution
 */
Narrow.prototype.start = function() {
    this._running = true;
    this._checkFree();
}

/**
 * Stops execution, no new tasks will be spawned after this call
 * Tasks which are in progress, will finish the exection in a normally
 *
 */
Narrow.prototype.stop = function() {
    this._running = false;
}

/**
 * Pushes one task to a buffer
 * Will execute callback with error/result when task will be completed
 *
 */
Narrow.prototype.push = function(data, callback) {
    this._push(data, callback);
    this._checkFree();
}

/**
 * Pushes a bunch of tasks to a buffer
 * Will execute callback with error/results when all task will be completed
 *
 */
Narrow.prototype.pushAll = function(tasks, callback) {
    
    if (!tasks instanceof Array) {
        throw new Error("tasks list should be instance of Array");
    }
    
    if (callback) {
        var done = 0, data = [], cb = function(err, d){
            if (d !== undefined) data.push(d);
            if (++done >= tasks.length) callback(null, data.length ? data : null);
        }
    }
    
    for (var i = 0; i < tasks.length; i++) {
        this._push(tasks[i], cb);
    }
    
    this._checkFree();
}

/**
 * Sets 'total' number of tasks. Useful when you push tasks one by one, using Narrow.push()
 */
Narrow.prototype.__defineSetter__('total', function(total) {
    this._total = total;
})
Narrow.prototype.__defineGetter__('total', function() {
    return this._total;
})

/**
 * Sets 'timeout' (millis) for a single task
 * If the task timed out, error will be thrown to a callback and 'error' event of Narrow
 *
 */
Narrow.prototype.__defineSetter__('timeout', function(timeout) {
    this._timeout = timeout;
})
Narrow.prototype.__defineGetter__('timeout', function() {
    return this._timeout;
})

/**
 * (private) Internal push
 */
Narrow.prototype._push = function(data, callback) {
    this._buffer.push({
        data : data,
        callback : callback
    })
}

/**
 * (private) Checks if there are some free workers, emits 'free' event
 */
Narrow.prototype._checkFree = function() {
    var self = this;
    if (this._inprog < this.threads) {
        self.emit('free');
    }
}

/**
 * (private)
 * This function executes in each tick of Narrow
 * It checks if there are free workers, than push the tasks from buffer
 *
 */
Narrow.prototype._process = function() {
    
    // Eat the buffer until maxium threads reached
    while (this._buffer.length) {
        if (!this._running) return;
        if (this._inprog >= this.threads) return;
        if (this._total && this._inprog >= this._total) return;
        this._doTask(this._buffer.shift());
    }
}

/**
 * (private)
 * Executes a given task
 *
 */
Narrow.prototype._doTask = function(task) {
    var self = this;
    
    this._inprog++;
    var called = false, t = null;
    
    function taskDone(err) {
        // call this func only once
        if (called) return;
        called = true;
        
        // clear timeout
        if (t) clearTimeout(t);
        // check if pipe is running
        if (!self._inprog) return;
        
        // counters
        self._inprog--;
        self._complete++;
        
        // Emit 'complete' event, pass task itself and the result to it
        // emit('complete', resultArg1, resultArg2, task.data)
        if (!err) {
            var args = Array.prototype.slice.call(arguments, 1);
            args.unshift('complete');
            args.push(task.data);
            self.emit.apply(self, args);
        }
        
        // execute task binded callback
        if (task.callback) {
            task.callback.apply(null, arguments);
        }
        
        if (err) {
            self.emit('error', err, task.data);
        }
        
        // if the total specified and number of complete tasks + tasks in progress reached total value
        if (self._total && self._complete + self._inprog >= self._total) {
            // try to stop the execution if there are some tasks in progress
            self.stop();
            // if there are no tasks in progress left, just emit 'end'
            if (!self._inprog) {
                self.emit('end');
            }
        }
        
        // emit drain event
        if (self._inprog + self._buffer.length == 0) {
            self.emit('drain');
        }
        
        self.emit('free');
    }
    
    process.nextTick(function(){
        try {
            // If per-task timeout specified, init the timer
            if (self._timeout) {
                t = setTimeout(function(){
                    taskDone(new Error('Timeout'))
                }, self._timeout);
            }
            // Execute task body
            self.body(task.data, taskDone);
        }
        catch (e) {
            // Same callback but with catched error
            taskDone(e);
        }
    })
}

module.exports = Narrow;