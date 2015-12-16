 <?php
	require_once("/var/www/html/ajax/statsFunctions.php");
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	
	$probes = array();
	$probeIDQuery = "SELECT ID FROM probe;";
	$probeResult = $mysqli->query($probeIDQuery);
	if ($probeResult == null)
	{
		echo "Query failed near line ".__LINE__ .": $probeIDQuery";
		echo "<br />Error is ".$mysqli->error;
		exit();
	}
	
	while ($row = $probeResult->fetch_assoc())
	{
		$probes[] = $row["ID"];
	}
	$numProbes = count($probes);
	echo "Number of probes is $numProbes.\n";
	$correlationEngine = new CorrelationEngine();
	for ($i = 0; $i < $numProbes; $i++)
	{
		echo "$i. probeID is ".$probes[$i]."\n";
		$set1 = array();
		$set1Query = "SELECT effect FROM individualEffect WHERE probeID = '".$probes[$i]."' ORDER BY individualID";
		$set1Result = $mysqli->query($set1Query);
		if ($set1Result == null)
		{
			echo "Query failed near line ".__LINE__ .": $set1Query";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
		
		while ($row = $set1Result->fetch_assoc())
		{
			$set1[] = $row['effect'];
		}

		for ($j = 0; $j < $numProbes; $j++)
		{
			$set2 = array();
			$set2Query = "SELECT effect FROM individualEffect WHERE probeID = ".$probes[$j]." ORDER BY individualID";
			$set2Result = $mysqli->query($set2Query);
			if ($set2Result == null)
			{
				echo "Query failed near line ".__LINE__ .": $set2Query";
				echo "<br />Error is ".$mysqli->error;
				exit();
			}
		
			while ($row = $set2Result->fetch_assoc())
			{
				$set2[] = $row['effect'];
			}
			$correlation = $correlationEngine->Correlation($set1, $set2);
			// echo "<pre>"; print_r($set1); echo "</pre>\n<pre>"; print_r($set2); echo "</pre>\ncorrelation is $correlation"; die();
			$insertCorrelationQuery = "INSERT INTO staticCorrelation (probe1ID, probe2ID, correlation) VALUES (".$probes[$i].", ".$probes[$j].", $correlation);";
			$insertResult = $mysqli->query($insertCorrelationQuery);
			if ($insertResult == null || $mysqli->affected_rows != 1 || $mysqli->error)
			{
				echo "Query failed near line ".__LINE__ .": $insertCorrelationQuery";
				echo "<br />Error is ".$mysqli->error;
				exit();
			}
		}
	}
	echo " --- finished ---";