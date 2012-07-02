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
 * Simple test module 
 */

var assert = require('assert');

function Test(name, module) {
    this.queue = [];
    this.name = name;
    this.current = null;
    for (var test in module) {
        this.queue.push({
            name : test,
            fn : module[test]
        });
    }
    
    this.assert = {};
    Object.keys(assert).forEach(function(fn){
        this.assert[fn] = function(){
            try {
                assert[fn].apply(assert, arguments);
            }
            catch (err) {
                console.error('test "%s" FAILED: %s', this.current.name, err.stack || err);
            }
        }.bind(this)
    }.bind(this));
}

Test.prototype.run = function(callback) {
    console.log('------------------------------------')
    console.log('running "%s":', this.name);
    this._next(function(){
        console.log('done "%s"', this.name);
        if (callback) callback();
    }.bind(this));
}

Test.prototype._next = function(callback) {
    if (this.queue.length) {
        this.current = this.queue.shift();
        console.log('test "%s"', this.current.name);
        try {
            this.current.fn(this.assert, function(){
                this._next(callback);
            }.bind(this));
            if (this.current.fn.length < 2) {
                this._next(callback);
            }
        }
        catch (err) {
            console.error('test "%s" FAILED: %s', this.current.name, err.stack || err);
        }
    }
    else {
        callback();
    }
}

function Suite(name) {
    this.tests = [];
    this.name = name;
    this.current = null;
}

Suite.prototype.add = function(test) {
    this.tests.push(test);
}

Suite.prototype.run = function(callback) {
    console.log('Running suite "%s"', this.name);
    this._next(function(){
        console.log('done "%s"!', this.name);
        if (callback) callback();
    }.bind(this));
}

Suite.prototype._next = function(callback) {
    if (this.tests.length) {
        this.current = this.tests.shift();
        this.current.run(function(){
            this._next(callback);
        }.bind(this));
    }
    else {
        callback();
    }
}

module.exports.Test = Test;
module.exports.Suite = Suite;