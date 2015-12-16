 <?php
	require_once("fasterCorrelation.php");
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	
	$probes = array();
	$probeIDQuery = "SELECT ID, indMean, indSSMeanDevn FROM probeTest;";
	$probeResult = $mysqli->query($probeIDQuery);
	if ($probeResult == null)
	{
		echo "Query failed near line ".__LINE__ .": $probeIDQuery";
		echo "<br />Error is ".$mysqli->error;
		exit();
	}
	
	while ($row = $probeResult->fetch_assoc())
	{
		$probes[] = $row;
	}
	$numProbes = count($probes);
	echo "Number of probes is $numProbes.\n";
	$correlationEngine = new CorrelationEngine();
	for ($i = 0; $i < $numProbes; $i++)
	{
		echo "probeID ".$probes[$i]['ID']."\n";
		$set1 = array();
		$set1Query = "SELECT effect FROM individualEffect WHERE probeID = '".$probes[$i]['ID']."' ORDER BY individualID";
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

		$updateCorrelationQuery = "UPDATE staticCorrelationTest SET correlation = 1 WHERE probe1ID = ".$probes[$i]['ID']." AND probe2ID = ".$probes[$i]['ID'].";";
		$updateResult = $mysqli->query($updateCorrelationQuery);
		if ($updateResult == null || $mysqli->error)
		{
			echo "Query failed near line ".__LINE__ .": $updateCorrelationQuery";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
		
		for ($j = $i + 1; $j < $numProbes; $j++)
		{
			$set2 = array();
			$set2Query = "SELECT effect FROM individualEffect WHERE probeID = ".$probes[$j]['ID']." ORDER BY individualID";
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
			$correlation = $correlationEngine->Correlation($set1, $set2, $probes[$i]['indMean'], $probes[$j]['indMean'], $probes[$i]['indSSMeanDevn'], $probes[$j]['indSSMeanDevn']);
			// echo "<pre>"; print_r($set1); echo "</pre>\n<pre>"; print_r($set2); echo "</pre>\ncorrelation is $correlation"; die();
			$updateCorrelationQuery = "UPDATE staticCorrelationTest SET correlation = $correlation
				WHERE probe1ID = ".$probes[$i]['ID']." AND probe2ID = ".$probes[$j]['ID']
				." OR probe1ID = ".$probes[$j]['ID']." AND probe2ID = ".$probes[$i]['ID'].";";
			$updateResult = $mysqli->query($updateCorrelationQuery);
			if ($updateResult == null || $mysqli->error)
			{
				echo "Query failed near line ".__LINE__ .": $updateCorrelationQuery";
				echo "<br />Error is ".$mysqli->error;
				exit();
			}
		}
	}
	echo " --- finished ---\n";