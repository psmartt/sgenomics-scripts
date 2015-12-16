 <?php
	require_once("/var/www/html/ajax/statsFunctions.php");
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	
	$lastProbeQuery = "SELECT staticCorrelationProbeID FROM last_probe_added;";
	$lastProbeResult = $mysqli->query($lastProbeQuery);
	if ($lastProbeResult == null)
	{
		echo "Query failed near line ".__LINE__ .": $lastProbeQuery";
		echo "<br />Error is ".$mysqli->error;
		exit();
	}
	
	if ($row = $lastProbeResult->fetch_assoc())
	{
		$lastProbe = $row["staticCorrelationProbeID"];
	}
	$probeIDQuery = "SELECT p.ID FROM probe p WHERE p.ID > $lastProbe;";
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
	$numProbes = count($probes) + $lastProbe;
	echo "Number of probes is $numProbes.\n";
	$correlationEngine = new CorrelationEngine();
	for ($i = $lastProbe + 1; $i <= $numProbes; $i++)
	{
		echo "probeID is $i\n";
		
		// Truncate the correlation memory table
		$truncateCorrelationMemQuery = "TRUNCATE TABLE staticCorrelation_MEM;";
		$truncateResult = $mysqli->query($truncateCorrelationMemQuery);
		if ($truncateResult == null || $mysqli->error)
		{
			echo "Query failed near line ".__LINE__ .": $truncateCorrelationMemQuery";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}

		$set1 = array();
		$set1Query = "SELECT effect FROM individualEffect_MEM WHERE probeID = $i ORDER BY individualID";
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

		for ($j = 1; $j <= $numProbes; $j++)
		{
			$set2 = array();
			$set2Query = "SELECT effect FROM individualEffect_MEM WHERE probeID = $j ORDER BY individualID";
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
			// $knownCorrelationQuery = "SELECT correlation FROM staticCorrelation WHERE probe1ID = $i AND probe2ID = $j;";
			// $knownCorrelationResult = $mysqli->query($knownCorrelationQuery);
			// if ($knownCorrelationResult == null)
			// {
				// echo "Query failed near line ".__LINE__ .": $knownCorrelationQuery";
				// echo "<br />Error is ".$mysqli->error;
				// exit();
			// }
			// if ($row = $knownCorrelationResult->fetch_assoc())
			// {
				// $correlation = $row['correlation'];
			// }
			// $correlationEngine->Correlation($set1, $set2, correlation);
			
			
			


			// echo "<pre>"; print_r($set1); echo "</pre>\n<pre>"; print_r($set2); echo "</pre>\n<pre>"; print_r($correlationEngine); echo "</pre>\ncorrelation is $correlation"; die();
			if ($i == $j)
			{
				// We would still like to know the count
				$insertCorrelationMemQuery = "INSERT INTO staticCorrelation_MEM (probe1ID, probe2ID, correlation, roundedCorrelation, ci95l, ci95u, ci99l, ci99u, matchingCount, pValue)
VALUES ($i, $j, 1, 1, 1, 1, 1, 1, ".$correlationEngine->usableCount.", 0);";
			}
			else if ($correlationEngine->usableCount >= 4)
			{
				$insertCorrelationMemQuery = "INSERT INTO staticCorrelation_MEM (probe1ID, probe2ID, correlation, roundedCorrelation, ci95l, ci95u, ci99l, ci99u, matchingCount)
VALUES ($i, $j, $correlation, ".round($correlation, 3).",
$correlationEngine->lower95,
$correlationEngine->upper95,
$correlationEngine->lower99,
$correlationEngine->upper99,
$correlationEngine->usableCount);";
			}
			else
			{
				$insertCorrelationMemQuery = "INSERT INTO staticCorrelation_MEM (probe1ID, probe2ID, correlation, roundedCorrelation, ci95l, ci95u, ci99l, ci99u, matchingCount, pValue)
VALUES ($i, $j, 0, 0, 0, 0, 0, 0, ".$correlationEngine->usableCount.", 1);";
			}
			$insertMemResult = $mysqli->query($insertCorrelationMemQuery);
			if ($insertMemResult == null || $mysqli->affected_rows != 1 || $mysqli->error)
			{
				echo "Query failed near line ".__LINE__ .": $insertCorrelationMemQuery";
				echo "<br />Error is ".$mysqli->error;
				exit();
			}
		}
		// Now dump this whole probe into the staticCorrelation table.  This makes it easy to stop and restart the script, and it might even be a bit faster
		$insertCorrelationQuery = "INSERT INTO staticCorrelation (probe1ID, probe2ID, correlation, ci95l, ci95u, ci99l, ci99u, matchingCount )
SELECT probe1ID, probe2ID, correlation, ci95l, ci95u, ci99l, ci99u, matchingCount FROM staticCorrelation_MEM;";
		$insertResult = $mysqli->query($insertCorrelationQuery);
		if ($insertResult == null || $mysqli->error)
		{
			echo "Query failed near line ".__LINE__ .": $insertCorrelationQuery";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
		// Now dump this whole probe into the staticCorrelation table.  This makes it easy to stop and restart the script, and it might even be a bit faster
		$updateLastIDQuery = "UPDATE last_probe_added SET staticCorrelationProbeID=$i;";
		$updateResult = $mysqli->query($updateLastIDQuery);
		if ($updateResult == null || $mysqli->affected_rows != 1 || $mysqli->error)
		{
			echo "Query failed near line ".__LINE__ .": $updateLastIDQuery";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
	}
	echo " --- finished ---";