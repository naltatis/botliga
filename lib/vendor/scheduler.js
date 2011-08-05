/**
 * scheduler.js
 * ---
 * VERSION 0.1
 * ---
 * @author Enrico Rubboli 
 * ---
 * Dual licensed under the MIT and GPL licenses.
 *    - http://www.opensource.org/licenses/mit-license.php
 *    - http://www.gnu.org/copyleft/gpl.html
 */
Scheduler = function(){ 

	var _events = []

	function _checkEvents(){ 
		var toBeRemoved=[]; 
		for (var i = -1, l = _events.length; ++i < l; ) { 
			if (typeof _events[i].event === 'function' &&
					Math.ceil(_events[i].datetime/1000) <= Math.ceil(new Date()/1000) ){ 
				_events[i].event(); 
				toBeRemoved.push(i) 
			} 
		} 
	
		for (var i=0; i<toBeRemoved.length; i++) {
			_events.splice(i,1); 
		} 
	}

	function _eventLoop(){ 
		setTimeout(function(){ 
			_checkEvents(); 
			_eventLoop(); 
		}, 1000); 
	}

 	var addJob = function(_datetime, _event){ 
		_events.push({ datetime:_datetime, event:_event }); 
	}

 	var init = function(){ 
		_eventLoop(); 
	}

 return { addJob:addJob, init:init } 

}