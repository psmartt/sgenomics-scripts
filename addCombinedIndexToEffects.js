

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





var mysql = require('mysql');
var pool  = mysql.createPool({
        hostname                : "localhost",
        user                    : "updatescriptuser",
        password                : "NOT_THE_REAL_PASSWORD",
        database                : "system_genomics",
        connectionLimit         : 72,
        waitForConnections      : true
});

pool.getConnection(function(err, connection) {
	var updateQuery = "ALTER TABLE effect ADD KEY p_valueAndSnp (p_value, snpID), LOCK=SHARED;";
	connection.query(updateQuery, function(err, rows, fields) {
		if (err) {
			console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", updateQuery is " + updateQuery + "\n");
			throw err;
		}
	});
	connection.release();
});
