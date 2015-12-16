<?php
$probeName = $argv[1];
echo "PROBE: $probeName\n";
echo "finding file paths ...\n";
$path = "/ibscratch/josephP/BSGS/Imputed/Var_eQTL/data/Output_Z/$probeName/*.tbl";
echo "Path is $path\n";
$files = glob($path);
echo "found file paths\n"; 
$mysqli = mysqli_connect(ini_get("mysqli.default_host")'updatescriptuser','NOT_THE_REAL_PASSWORD');
echo "<pre>"; print_r($files); echo "</pre>"; 
$mysqli->select_db('system_genomics');

try
{
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
	$probeName = $row['ID'];

	echo "probeName is $probeName\n";

	// if (!$mysqli->query("CREATE TEMPORARY TABLE allSNPs 
	if (!$mysqli->query("CREATE TABLE allSNPs 
		(
			snpName varchar(50),
			AL1 char(1) NOT NULL,
			AL2 char(1) NOT NULL,
			freq1 double NOT NULL,
			effect double NOT NULL,
			standard_error double NOT NULL,
			heritability double NOT NULL,
			log_odds_ratio double NOT NULL,
			p_value double NOT NULL,
			KEY (snpName))ENGINE=MEMORY "))
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
    			(@ignore, snpName, AL1, AL2, freq1, @ignore, effect, standard_error, heritability, log_odds_ratio, p_value)"))
		{
			echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
		}
	}
	
	echo "At line ". __LINE__ .", rows affected = ". $mysqli->affected_rows . "\n";
	// // if (!$mysqli->query("CREATE TEMPORARY TABLE filteredSNPs 
	// if (!$mysqli->query("CREATE TABLE filteredSNPs 
		// (
			// snpID int NOT NULL AUTO_INCREMENT,
			// AL1 char(1) NOT NULL,
			// AL2 char(1) NOT NULL,
			// freq1 double NOT NULL,
			// effect double NOT NULL,
			// standard_error double NOT NULL,
			// heritability double NOT NULL,
			// log_odds_ratio double NOT NULL,
			// p_value double NOT NULL,
			// PRIMARY KEY (snpID),
			// KEY (effect))ENGINE=MEMORY"))
	// {
		// echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	// }
	
	// echo "At line ". __LINE__ ."\n";
	// if (!$mysqli->query("INSERT INTO filteredSNPs
		// (AL1, AL2, freq1, effect, standard_error, heritability, log_odds_ratio, p_value)
		// (SELECT AL1, AL2, freq1, effect, standard_error, heritability, log_odds_ratio, p_value FROM allSNPs WHERE standard_error <= 1.0)"))
	// {
		// echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	// }

	echo "At line ". __LINE__ .", rows affected = ". $mysqli->affected_rows . "\n";
	if (!$mysqli->query("UPDATE snp s INNER JOIN allSNPs e ON s.snp_name = e.snpName
		SET s.AL1 = e.AL1, s.AL2 = e.AL2, s.freq1 = e.freq1 "))
	{
		echo "At line ". __LINE__ ." query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	echo "At line ". __LINE__ .", rows affected = ". $mysqli->affected_rows . "\n";
}
catch (Exception $e)
{
	echo "query crashed\n"; printr_r($e); die();
}
echo "-------Done---------";
$mysqli->close();
?>