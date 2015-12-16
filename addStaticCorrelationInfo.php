 <?php
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

	for ($i = $lastProbe + 1; $i <= $numProbes; $i++)
	{
		echo "probeID is $i\n";
		
		$matchingCountQuery = "INSERT into staticCorrelationNew (probe1ID, probe2ID, matchingCount)
(SELECT ie1.probeID AS probe1ID, ie2.probeID AS probe2ID, count(*) as matchingCount FROM `individualEffect_MEM_noNULL` ie1
INNER JOIN individualEffect_MEM_noNULL ie2 ON ie1.individualID = ie2.individualID WHERE ie1.probeID = $i GROUP BY ie2.probeID)";
		$matchingCountResult = $mysqli->query($matchingCountQuery);
		if ($matchingCountResult == null)
		{
			echo "Query failed near line ".__LINE__ .": $matchingCountQuery";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
		
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