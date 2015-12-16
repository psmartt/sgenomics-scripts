SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
CREATE DATABASE IF NOT EXISTS system_genomics DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE system_genomics;

DROP TABLE IF EXISTS chromosome;
CREATE TABLE IF NOT EXISTS chromosome (
  `ID` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS effect;
CREATE TABLE IF NOT EXISTS effect (
  `ID` bigint(20) NOT NULL,
  snpID int(11) NOT NULL,
  probeID int(11) NOT NULL,
  effect double NOT NULL,
  standard_error double NOT NULL,
  heritability double NOT NULL,
  log_odds_ratio double NOT NULL,
  p_value double NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression=TOKUDB_LZMA;

DROP TABLE IF EXISTS family;
CREATE TABLE IF NOT EXISTS family (
  `ID` int(11) NOT NULL,
  familyNum int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS gene;
CREATE TABLE IF NOT EXISTS gene (
  `ID` smallint(6) NOT NULL,
  illumina_gene varchar(20) NOT NULL,
  chromosome tinyint(4) DEFAULT NULL,
  hg18_start int(11) DEFAULT NULL,
  hg18_end int(11) DEFAULT NULL,
  hg19_start int(11) DEFAULT NULL,
  hg19_end int(11) DEFAULT NULL,
  hg38_start int(11) DEFAULT NULL,
  hg38_end int(11) DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS geneAlias;
CREATE TABLE IF NOT EXISTS geneAlias (
  `ID` int(11) NOT NULL,
  my_illumina_gene varchar(20) DEFAULT NULL,
  approvedSymbol varchar(50) DEFAULT NULL,
  selectedSymbol varchar(50) DEFAULT NULL,
  displayString varchar(100) DEFAULT NULL,
  geneID int(11) NOT NULL,
  chromosome tinyint(4) DEFAULT NULL,
  start_position int(11) DEFAULT NULL,
  symbolType tinyint(4) NOT NULL COMMENT '1=Approved symbol,\n2=synonym,\n3=previous symbol,\n4=withdrawn symbol\n5=not found in current release',
  isDuplicate bit(1) DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS individual;
CREATE TABLE IF NOT EXISTS individual (
  `ID` int(11) NOT NULL,
  familyID int(11) NOT NULL,
  individualNum int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS individualEffect;
CREATE TABLE IF NOT EXISTS individualEffect (
  `ID` int(11) NOT NULL,
  probeID int(11) NOT NULL,
  individualID int(11) NOT NULL,
  effect double DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS last_probe_added;
CREATE TABLE IF NOT EXISTS last_probe_added (
  `ID` int(11) NOT NULL,
  probeID int(11) NOT NULL,
  staticCorrelationProbeID int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS probe;
CREATE TABLE IF NOT EXISTS probe (
  `ID` int(20) NOT NULL,
  posIndex smallint(6) NOT NULL,
  probeName varchar(100) NOT NULL,
  geneID smallint(6) NOT NULL,
  start_position int(11) DEFAULT NULL,
  hg18pos int(11) DEFAULT NULL,
  hg19pos int(11) DEFAULT NULL,
  hg38pos int(11) DEFAULT NULL,
  minPValue double NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 COMMENT='The set of expression probes (short sequences within genes) from BSGS ' compression=TOKUDB_UNCOMPRESSED;

DROP TABLE IF EXISTS snp;
CREATE TABLE IF NOT EXISTS snp (
  `ID` bigint(20) NOT NULL,
  chromosome tinyint(4) NOT NULL,
  snp_name varchar(50) NOT NULL,
  position int(11) NOT NULL,
  hg18pos int(11) DEFAULT NULL,
  hg19pos int(11) DEFAULT NULL,
  hg38pos int(11) DEFAULT NULL,
  AL1 char(1) DEFAULT NULL,
  AL2 char(1) DEFAULT NULL,
  freq1 double DEFAULT NULL,
  minPValue double DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS standardPValue;
CREATE TABLE IF NOT EXISTS standardPValue (
  `ID` int(11) NOT NULL,
  correlation double NOT NULL,
  numSamples smallint(6) NOT NULL,
  pValue double NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

DROP TABLE IF EXISTS staticCorrelation;
CREATE TABLE IF NOT EXISTS staticCorrelation (
  `ID` int(11) NOT NULL,
  probe1ID int(11) NOT NULL,
  probe2ID int(11) NOT NULL,
  p1posIndex smallint(6) NOT NULL,
  p2posIndex smallint(6) NOT NULL,
  correlation double NOT NULL,
  ci95l double NOT NULL,
  ci95u double NOT NULL,
  ci99l double NOT NULL,
  ci99U double NOT NULL,
  matchingCount smallint(6) NOT NULL,
  pValue double NOT NULL,
  fishersZ double NOT NULL,
  standardError double NOT NULL,
  nMinus3 double DEFAULT NULL,
  nMinus3_95 double DEFAULT NULL,
  nMinus3_99 double DEFAULT NULL,
  lowerZ99 double DEFAULT NULL,
  lowerZ95 double DEFAULT NULL,
  upperZ95 double DEFAULT NULL,
  upperZ99 double DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';


ALTER TABLE chromosome
  ADD PRIMARY KEY (`ID`),
  ADD KEY `number` (`number`);

ALTER TABLE effect
  ADD PRIMARY KEY (`ID`) CLUSTERING=YES,
  ADD KEY snpID (snpID),
  ADD KEY probeID (probeID),
  ADD KEY snpClus (snpID) CLUSTERING=YES,
  ADD KEY probeClus (probeID) CLUSTERING=YES,
  ADD KEY p_value (p_value);

ALTER TABLE family
  ADD PRIMARY KEY (`ID`),
  ADD KEY familyNum (familyNum);

ALTER TABLE gene
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY illumina_gene (illumina_gene),
  ADD KEY chromosome (chromosome),
  ADD KEY hg18_start (hg18_start),
  ADD KEY hg19_start (hg19_start),
  ADD KEY hg38_start (hg38_start);

ALTER TABLE geneAlias
  ADD PRIMARY KEY (`ID`),
  ADD KEY my_illumina_gene (my_illumina_gene),
  ADD KEY approvedSymbol (approvedSymbol),
  ADD KEY selectedSymbol (selectedSymbol),
  ADD KEY geneID (geneID);

ALTER TABLE individual
  ADD PRIMARY KEY (`ID`),
  ADD KEY individualID (individualNum),
  ADD KEY individualNum (individualNum);

ALTER TABLE individualEffect
  ADD PRIMARY KEY (`ID`),
  ADD KEY probeID (probeID,individualID),
  ADD KEY effect (effect);

ALTER TABLE last_probe_added
  ADD PRIMARY KEY (`ID`);

ALTER TABLE probe
  ADD PRIMARY KEY (`ID`),
  ADD KEY probeID (probeName),
  ADD KEY start_position (start_position),
  ADD KEY posIndex (posIndex),
  ADD KEY newGeneID (geneID),
  ADD KEY geneID (geneID),
  ADD KEY hg18pos (hg18pos),
  ADD KEY hg38pos (hg38pos),
  ADD KEY hg19pos (hg19pos);

ALTER TABLE snp
  ADD PRIMARY KEY (`ID`),
  ADD KEY snp_name (snp_name),
  ADD KEY chromosome (chromosome,snp_name) CLUSTERING=YES,
  ADD KEY minPValue (minPValue),
  ADD KEY hg18pos (hg18pos),
  ADD KEY hg19pos (hg19pos),
  ADD KEY hg38pos (hg38pos);

ALTER TABLE standardPValue
  ADD PRIMARY KEY (`ID`),
  ADD KEY correlation (correlation,numSamples);

ALTER TABLE staticCorrelation
  ADD PRIMARY KEY (`ID`),
  ADD KEY probe1ID (probe1ID),
  ADD KEY correlation (correlation),
  ADD KEY pValue (standardError),
  ADD KEY bothProbesID (probe1ID,probe2ID),
  ADD KEY matchingCount (matchingCount),
  ADD KEY probe2ID (probe2ID),
  ADD KEY probe1Clus (probe1ID) CLUSTERING=YES,
  ADD KEY probe2Clus (probe2ID) CLUSTERING=YES,
  ADD KEY p1PosIndexClus (p1posIndex) CLUSTERING=YES,
  ADD KEY p2posIndexClus (p2posIndex) CLUSTERING=YES;


ALTER TABLE chromosome
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE effect
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT;
ALTER TABLE family
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE gene
  MODIFY `ID` smallint(6) NOT NULL AUTO_INCREMENT;
ALTER TABLE geneAlias
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE individual
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE individualEffect
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE last_probe_added
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE probe
  MODIFY `ID` int(20) NOT NULL AUTO_INCREMENT;
ALTER TABLE snp
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT;
ALTER TABLE standardPValue
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE staticCorrelation
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;