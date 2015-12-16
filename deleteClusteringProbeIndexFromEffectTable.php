 <?php
 echo "started\n";
	$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
	$mysqli->select_db('system_genomics');
	$query = "ALTER TABLE effect DROP INDEX probeClus;";
	echo $query;
	$result = $mysqli->query($query);
	if ($result == null)
	{
		echo "Query failed near line ".__LINE__ .": $query";
		echo "<br />Error is ".$mysqli->error;
		exit();
	}
echo " --- finished ---";