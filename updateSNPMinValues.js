var async = require("async");

var pool = app.locals.settings.connectionPool;
var allIDsSent = false;
//Set up our queue
var queue = async.queue(function(snpID, callback) {
	pool.getConnection(function(err, connection) {
		connection.query(minPValueQuery, function(err, rows, fields) {
			if (err) {
				console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", minPValueQuery is " + minPValueQuery + "\n");
				throw err;
			}
			var minPValue;
			if (rows.length) {
				minPValue = rows[0].minPValue;
			} else {
				minPValue = -999;
			}
			var updateQuery = "UPDATE snp SET minPValue = " + minPValue + " WHERE ID = " + snpID + ";";
			connection.query(updateQuery, function(err, rows, fields) {
				if (err) {
					console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", updateQuery is " + updateQuery + "\n");
					throw err;
				}
				connection.release();
				if (snpID % 10000 == 0) {
					socket.send("Min for snpID " + snpID + " is " + minPValue);
				}
				callback();
			});
		});
	});
}, 200);

queue.drain = function() {
    if (queue.length() == 0 && listObjectsDone) {
        console.log('-- All done --');
    }

};


for (var snpID = 1; snpID <= 5496145; snpID++) {
	queue.push(snpID);
}

allIDsSent = true;
