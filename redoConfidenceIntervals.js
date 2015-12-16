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
	connectionLimit		: 100,
	waitForConnections	: true
});

var blocks = [];
for (var i = 0; i < 324000000; i += 40000)
{
	blocks.push({
		start: i,
		end: i + 39999
	});
}

async.each(blocks, function(block, callback) {
	
	console.log(block.start + "-" + block.end + " waiting in pool");

	var staticCorrelationQuery = "UPDATE staticCorrelation SET "
	
		+ "nMinus3		= SQRT(1/(matchingCount-3)) "
		+ ",nMinus3_95  = 1.96  * nMinus3 "
		+ ",nMinus3_99  = 2.575 * nMinus3 "
		+ ",lowerZ99    = fishersZ - nMinus3_99 "
		+ ",lowerZ95    = fishersZ - nMinus3_95 "
		+ ",upperZ95    = fishersZ + nMinus3_95 "
		+ ",upperZ99    = fishersZ + nMinus3_99 "
		+ ",ci99l	    = (EXP(2 * lowerZ99) - 1)/(EXP(2 * lowerZ99) + 1) "
		+ ",ci95l	    = (EXP(2 * lowerZ95) - 1)/(EXP(2 * lowerZ95) + 1) "
		+ ",ci95u	    = (EXP(2 * upperZ95) - 1)/(EXP(2 * upperZ95) + 1) "
		+ ",ci99u	    = (EXP(2 * upperZ99) - 1)/(EXP(2 * upperZ99) + 1) "

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
	
	
 
	