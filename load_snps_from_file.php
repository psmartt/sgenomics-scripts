<?php
echo "finding file paths ...\n";
$file = '/ibscratch/josephP/BSGS/Imputed/Var_eQTL/data/data_files/bsgs_imputed_R2_80_cleaned_stage2_chr_all_SNP_info.txt';
echo "found file paths\n"; 
$mysqli = mysqli_connect(ini_get("mysqli.default_host"),'updatescriptuser','NOT_THE_REAL_PASSWORD');
$mysqli->select_db('system_genomics');


try
{
	if (!$mysqli->query("DROP TABLE IF EXISTS `snp`;"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	if (!$mysqli->query("CREATE TABLE IF NOT EXISTS `snp` (
	  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
	  `chromosome` tinyint(4) NOT NULL,
	  `snp_name` varchar(50) NOT NULL,
	  `position` int(11) NOT NULL,
	  `AL1` char(1) DEFAULT NULL,
	  `AL2` char(1) DEFAULT NULL,
	  `freq1` double DEFAULT NULL,
	  PRIMARY KEY (`ID`)
	) ENGINE=TokuDB `compression`='tokudb_zlib' ;"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	if (!$mysqli->query("ALTER TABLE  `snp` ADD INDEX (  `snp_name` );"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	if (!$mysqli->query("ALTER TABLE  `snp` ADD INDEX ( `chromosome`, `snp_name` ) CLUSTERING=YES;
	"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	echo $file."\n";
	
	
	if (!$mysqli->query("CREATE TEMPORARY TABLE temp (
	  `chromosome` tinyint(4) NOT NULL,
	  `snp_name` varchar(50) NOT NULL,
	  `position` int(11) NOT NULL,
	  `AL1` char(1) DEFAULT NULL,
	  `AL2` char(1) DEFAULT NULL,
	  `freq1` double DEFAULT NULL);"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	
	if (!$mysqli->query("LOAD DATA LOCAL INFILE '$file'
		INTO TABLE temp
		FIELDS TERMINATED BY \" \"
		LINES TERMINATED BY \"\n\"
		IGNORE 1 LINES
			(`chromosome`, `snp_name`,`position`)"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	echo "at line ". __LINE__ ." affected rows is ".$mysqli->affected_rows."\n";
	if (!$mysqli->query("INSERT INTO snp (chromosome, snp_name, position) (SELECT chromosome, snp_name, position FROM temp WHERE snp_name like 'r%')"))
	{
		echo "At line ". __LINE__ ." Query did not work. Error is :\n\t\t". $mysqli->error. "\n"; die();
	}
	echo "at line ". __LINE__ ." affected rows is ".$mysqli->affected_rows."\n";
}
catch (Exception $e)
{
	echo "query crashed\n"; printr_r($e); die();
}
echo "-------Done---------\n";
$mysqli->close();
?>