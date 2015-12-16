<?php
$lastTimeCheck = microtime(true);
$startTime = $lastTimeCheck;

function timeCheck($lineNum)
{
	global $lastTimeCheck, $startTime;
	$now = microtime(true);
	echo "At line "; echo $lineNum ; echo ", time since start = "; echo $now - $startTime; echo ", time since last check = "; echo $now - $lastTimeCheck; echo "\n";
	$lastTimeCheck = $now;
}

$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
$mysqli->select_db('system_genomics');
$directoryPath = "/ibscratch/josephP/BSGS/Imputed/Var_eQTL/data/Output_Z/ILMN_*";
$directories = glob($directoryPath);

// Get the probe we got up to last time so we don't need to do it all again from scratch
$query = "SELECT probeID FROM last_probe_added;";
$result = $mysqli->query($query); 
if (!$result)
{
	echo "At line ". __LINE__ ." query did not work. Query is :\n\t\t$query\n Error is :\n\t\t". $mysqli->error. "\n"; die();
}
$row = $result->fetch_assoc();
if (!$row)
{
	echo "Query did not return anything near line " .__LINE__ . ": $query";
	die();
}
$lastProbeAdded = "ILMN_".$row['probeID'];
echo "last probe was $lastProbeAdded\n";

foreach ($directories as $directory)
{
	
	try
	{
		$probeName = str_replace("/ibscratch/josephP/BSGS/Imputed/Var_eQTL/data/Output_Z/", "", $directory);
		echo "PROBE: $probeName\n";
		if ($probeName <= $lastProbeAdded)
		{
		echo $probeName ." <= ". $lastProbeAdded."\n";
			continue;
		}
		echo "finding file paths ...\n";
		// $path = "/ibscratch/wrayvisscher/josephP/BSGS/Imputed/Var_eQTL/data/Output_Z/$probeName/*.tbl";
		// echo "Path is $path\n";
		$files = glob($directory."/*");
		
		$query = "SELECT ID FROM probe WHERE probeName = '$probeName';";
		$result = $mysqli->query($query); 
		if (!$result)
		{
			echo "At line ". __LINE__ ." query did not work. Query is :\n\t\t$query\n Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
		$row = $result->fetch_assoc();
		if (!$row)
		{
			echo "Query did not return anything near line " .__LINE__ . ": $query";
			die();
		}
		$probeID = $row['ID'];

		echo "probeID is $probeID\n";

		if (!$mysqli->query("TRUNCATE TABLE allSNPs"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}

		foreach($files as $file){
			echo $file."\n";
			if (!$mysqli->query("LOAD DATA INFILE '$file'
				INTO TABLE allSNPs
				FIELDS TERMINATED BY \"\t\"
				LINES TERMINATED BY \"\n\"
				IGNORE 1 LINES
					(@ignore, @ignore, @ignore, @ignore, @ignore, @ignore, effect, standard_error, heritability, log_odds_ratio, p_value)"))
			{
				echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
			}
		}
		$lineNum = __LINE__ ; timeCheck( $lineNum );
		if (!$mysqli->query("TRUNCATE TABLE filteredSNPs"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
		
		$lineNum = __LINE__ ; timeCheck( $lineNum );
		if (!$mysqli->query("INSERT INTO filteredSNPs
			(effect, standard_error,heritability, log_odds_ratio,p_value)
			(SELECT effect, standard_error, heritability, log_odds_ratio, p_value FROM allSNPs WHERE standard_error <= 1.0)"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}

		$lineNum = __LINE__ ; timeCheck( $lineNum );

		if (!$mysqli->query("LOCK TABLES filteredSNPs WRITE, effect WRITE"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}

		$lineNum = __LINE__ ; timeCheck( $lineNum );

		if (!$mysqli->query("INSERT INTO effect
			(snpID, probeID, effect, standard_error,heritability, log_odds_ratio,p_value)
			SELECT snpID, $probeID, effect, standard_error,heritability, log_odds_ratio,p_value FROM filteredSNPs"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}

		$lineNum = __LINE__ ; timeCheck( $lineNum );

		if (!$mysqli->query("UNLOCK TABLES"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
		
		$lineNum = __LINE__ ; timeCheck( $lineNum );
		if (!$mysqli->query("UPDATE last_probe_added SET probeID = ".str_replace("ILMN_", "", $probeName).";"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
	}
	catch (Exception $e)
	{
		if (!$mysqli->query("UNLOCK TABLES"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
		echo "query crashed\n"; printr_r($e); die();
	}
}
echo "-------Done---------";
$mysqli->close();
?>