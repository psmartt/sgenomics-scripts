var async = require('async');
var mysql = require('mysql');



// Help with debugging
Object.defineProperty(global, '__STACK__', {
	get: function(){
		var orig = Error.prepareStackTrace;
		Error.prepareStackTrace = function(_, stack){ return stack; };
		var err = new Error;
		Error.captureStackTrace(err, arguments.callee);
		var stack = err.stack;
		Error.prepareStackTrace = orig;
		return stack;
	}
});

Object.defineProperty(global, '__LINE__', {
	get: function(){
		return __STACK__[1].getLineNumber();
	}
});

Object.defineProperty(global, '__FILE__', {
	get: function(){
		return __STACK__[1].getFileName().split('/').slice(-1)[0];
	}
});



var pool  = mysql.createPool({
	hostname			: "localhost",
	user				: "updatescriptuser",
	password			: "NOT_THE_REAL_PASSWORD",
	database			: "system_genomics",
	connectionLimit		: 72,
	waitForConnections	: true
});
var blocks = [];
for (var i = 0; i < 324000000; i += 100000)
{
	blocks.push({
		start: i,
		end: i + 99999
	});
}


async.each(blocks, function(block, callback) {
	
	console.log(block.start + "-" + block.end + " waiting in pool");

	var staticCorrelationQuery = "UPDATE staticCorrelation SET fishersZ = 0.5 * LOG((1 + correlation)/(1 - correlation)) "
		+ " WHERE ID BETWEEN " + block.start + " AND " + block.end + ";";
	pool.getConnection(function(err, connection) {

		console.log(block.start + "-" + block.end + " starting");

		connection.query(staticCorrelationQuery, function(err, rows, fields) {
			if (err) {
				console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", staticCorrelationQuery is " + staticCorrelationQuery + "\n");
				console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", err is ");
				console.log(err);
				console.log("\n");
				callback(err);
			} else {
				console.log(block.start + "-" + block.end + " done");
				connection.destroy();
				callback();
			}
		});
	});

},
function(err) {
	if (err) {
		console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", err is ");
		console.log(err);
		console.log("\n");
	} else {
		console.log("all blocks done");
	}
});
	
	
 
	