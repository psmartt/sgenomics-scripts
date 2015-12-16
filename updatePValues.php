 <?php
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	for ($correlationInt = -1000; $correlationInt <= 1000; $correlationInt++)
	{
		$correlation = $correlationInt / 1000;
		echo $correlation.".";
		$query = "UPDATE staticCorrelation sc FORCE INDEX (roundedAndCount)
	INNER JOIN `standardPValue_MEM` pv force index (correlation)
	ON pv.correlation = $correlation AND sc.roundedCorrelation = pv.correlation and sc.matchingCount = pv.numSamples
	SET sc.pValue = pv.pValue;";
		$result = $mysqli->query($query);
		if ($result == null)
		{
			echo "Query failed near line ".__LINE__ .": $query";
			echo "<br />Error is ".$mysqli->error;
			exit();
		}
	}
echo " --- finished ---";