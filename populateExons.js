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
	waitForConnections	: true,
	connectTimeout		: 60000000,
	acquireTimeout		: 60000000
});

// A convenient way to run queries where we are not expecting any data back, but we need a callback when we are done
function asyncSimpleQuery(simpleQuery, callback) {
	pool.getConnection(function(err, connection) {
		if (err) {
			console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", simpleQuery is " + simpleQuery + "\n");
			console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", err is " + err + "\n");
			throw err;
		}
		connection.query(simpleQuery, function(err, result) {
			if (err) {
				console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", simpleQuery is " + simpleQuery + "\n");
				throw err;
			}
			connection.destroy();
			callback();
		});
	})
}

// This is like a primary key - it keeps the exons pointing to the right gene range while gene ranges and exons
// are still being loaded, but still enables them to be loaded in bulk in any order

async.series([
	function(mainCallback) {
		async.parallel([
			function(truncateDoneCallback) {
				asyncSimpleQuery("TRUNCATE TABLE ucscExon;", truncateDoneCallback);
			},
			function(truncateDoneCallback) {
				asyncSimpleQuery("TRUNCATE TABLE ucscGeneRange;", truncateDoneCallback);
			}
		],function(){
			var blocks = [];
			for (var i = 0; i < 350000; i += 500) {
				blocks.push({
					start: i,
					end: i + 499
				});
			}

			var transcripts = {};

			async.each(blocks, function(block, blockDoneCallback) {
				
				console.log(block.start + "-" + block.end + " waiting in pool");

				pool.getConnection(function(err, connection1) {
					if (err) {
						console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", err is " + err + "\n");
						throw err;
					}
					console.log(block.start + "-" + block.end + " starting");
					var blockQuery = "SELECT ID, build_ID, ucscGene_ID, transcript_key, chromosome, "
						+ "start, end, exon_starts, exon_ends FROM ucscGeneExonWithBuild WHERE ID BETWEEN " + block.start + " AND " + block.end + ";";
					
					connection1.query(blockQuery, function(err, rows) {
						if (err) {
							console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", blockQuery is " + blockQuery + "\n");
							throw err;
						}
						// connection1.destroy();
						var ucscGeneRangeValues = '';
						var exonInsertValues = '';
						
						for (var j = 0; j < rows.length; j++) {
							var row = rows[j];
							if (!transcripts[row.transcript_key]) {
								transcripts[row.transcript_key] = 1;
							} else {
								transcripts[row.transcript_key]++;
							}
							row.transcriptNum = transcripts[row['transcript_key']];
							
							if (row.transcriptNum == 1) {
								if (ucscGeneRangeValues) {
									ucscGeneRangeValues += ",";
								}
								// We only want one gene range entry for each unique transcript key
								ucscGeneRangeValues += "(" + row.ucscGene_ID + ", '" + row.transcript_key + "', "
								+ row.build_ID + ", " + row.chromosome + ", " + row.start + ", " + row.end + ")";
							}
							var startsArray = row.exon_starts.split(",").filter(Boolean);
							var endsArray = row.exon_ends.split(",").filter(Boolean);

							for (var i = 0; i < startsArray.length; i++) {
								if (exonInsertValues) {
									exonInsertValues += ",";
								}
								exonInsertValues += "('" + row.transcript_key + "', " + row.transcriptNum + ", " + startsArray[i] + ", " + endsArray[i] + ")";
							}
						}
						if (exonInsertValues){
							async.waterfall(
							[
								function(rowDoneCallback) {
									var geneRangeQuery = "INSERT INTO ucscGeneRange (ucscGene_ID, transcript_key, build_ID, chromosome, start, end) VALUES "
										+ ucscGeneRangeValues + ";";
									connection1.query(geneRangeQuery, function(err, result) {
										if (err) {
											console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", geneRangeQuery is " + geneRangeQuery + "\n");
											throw err;
										}
										rowDoneCallback();
									});
								},
								function(rowDoneCallback, insertId) {
									var exonQuery = "INSERT INTO ucscExon (transcript_key, transcript_num, start, end) VALUES " + exonInsertValues;
									connection1.query(exonQuery, function(err, result) {
										if (err) {
											console.log("\nAt file " + __FILE__ + ", line " + __LINE__ + ", exonQuery is " + exonQuery + "\n");
											throw err;
										}
										connection1.destroy();
										rowDoneCallback();
									});
								}
							],
							function() {
								console.log(block.start + "-" + block.end + " done");
								blockDoneCallback();
							});
						} else {
							console.log("No records found for " + block.start + "-" + block.end + ". Does this make sense?");
							blockDoneCallback();
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
					mainCallback();
				}
			});
		});
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscGeneRange DROP IF EXISTS `ID`;", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscGeneRange ADD `ID` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`ID`) CLUSTERING='YES'", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscGeneRange ADD INDEX(transcript_key), ADD INDEX(ucscGene_ID)", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscExon DROP IF EXISTS `ID`;", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscExon ADD `ID` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`ID`) CLUSTERING='YES'", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("ALTER TABLE ucscExon ADD INDEX(transcript_key), ADD INDEX(ucscGene_ID)", mainCallback);
	},
	function(mainCallback) {
		asyncSimpleQuery("UPDATE ucscExon x INNER JOIN ucscGeneRange r ON x.transcript_key = r.transcript_key "
		+ " SET x.ucscGeneRange_ID = r.ID", mainCallback);
	},
],
function() {
	console.log("everything done");
	process.exit(0);
});
