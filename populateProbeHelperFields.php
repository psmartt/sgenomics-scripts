 <?php
	require_once("/var/www/html/ajax/statsFunctions.php");
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	
	$probes = array();
	$probeIDQuery = "SELECT ID FROM probeTest;";
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
		echo "probeID ".$probes[$i]."\n";
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
		
		// $set1 = $set1Result->fetch_array(MYSQLI_NUM);
		
		// echo "<pre>"; print_r($set1); echo "</pre>"; die();
		// Quick and dirty way to initialise the object - all we need here is the sum of squares and the average
		$correlation = $correlationEngine->Correlation($set1, $set1);
		$sumSquareMeanDeviation = $correlationEngine->SumSquareMeanDeviation(0);
		$indAverage = $correlationEngine->arraySets[0]->average;
		if ($indAverage != NULL)
		{
			// echo "<pre>"; print_r($set1); echo "</pre>\n<pre>"; print_r($set2); echo "</pre>\ncorrelation is $correlation"; die();
			$updateProbeSSQuery = "UPDATE probeTest SET indSumSquareMeanDeviation = $sumSquareMeanDeviation, indAverage = $indAverage WHERE ID = ".$probes[$i].";";
			$updateResult = $mysqli->query($updateProbeSSQuery);
			if ($updateResult == null || $mysqli->error)
			{
				echo "Query failed near line ".__LINE__ .": $updateProbeSSQuery";
				echo "<br />Error is ".$mysqli->error;
				exit();
			}
		}
	}
	echo " --- finished ---";