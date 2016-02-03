DROP TABLE IF EXISTS hg18snp_unsorted;
DROP TABLE IF EXISTS hg19snp_unsorted;
DROP TABLE IF EXISTS hg38snp_unsorted;
DROP TABLE IF EXISTS hg18probe_unsorted;
DROP TABLE IF EXISTS hg19probe_unsorted;
DROP TABLE IF EXISTS hg38probe_unsorted;
CREATE TABLE IF NOT EXISTS hg18snp_unsorted (
  `ID` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  chromosome int(11) NOT NULL,
  `start` int(11) NOT NULL,
  `end` int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE hg18snp_unsorted
  ADD PRIMARY KEY (`ID`),
  ADD KEY `name` (`name`);
  
ALTER TABLE hg18snp_unsorted
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
  
CREATE TABLE hg19snp_unsorted LIKE hg18snp_unsorted;
CREATE TABLE hg38snp_unsorted LIKE hg18snp_unsorted;
CREATE TABLE hg18probe_unsorted LIKE hg18snp_unsorted;
CREATE TABLE hg19probe_unsorted LIKE hg18snp_unsorted;
CREATE TABLE hg38probe_unsorted LIKE hg18snp_unsorted;


LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg18SNPs'
	INTO TABLE hg18snp_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg19SNPs'
	INTO TABLE hg19snp_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg38SNPs'
	INTO TABLE hg38snp_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
	
	
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg18_probes'
	INTO TABLE hg18probe_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg19_probes'
	INTO TABLE hg19probe_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg38_probes'
	INTO TABLE hg38probe_unsorted
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(name,chromosome,start,end);
	
DROP TABLE IF EXISTS hg18snp;
DROP TABLE IF EXISTS hg19snp;
DROP TABLE IF EXISTS hg38snp;
DROP TABLE IF EXISTS hg18probe;
DROP TABLE IF EXISTS hg19probe;
DROP TABLE IF EXISTS hg38probe;

CREATE TABLE hg18snp LIKE hg18snp_unsorted;
CREATE TABLE hg19snp LIKE hg18snp_unsorted;
CREATE TABLE hg38snp LIKE hg18snp_unsorted;	
CREATE TABLE hg18probe LIKE hg18snp_unsorted;	
CREATE TABLE hg19probe LIKE hg18snp_unsorted;	
CREATE TABLE hg38probe LIKE hg18snp_unsorted;	
	
INSERT INTO hg18snp (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg18snp_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
INSERT INTO hg19snp (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg19snp_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
INSERT INTO hg38snp (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg38snp_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
INSERT INTO hg18probe (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg18probe_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
INSERT INTO hg19probe (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg19probe_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
INSERT INTO hg38probe (name,chromosome,start,end) SELECT name,chromosome,start,end FROM hg38probe_unsorted ORDER BY chromosome ASC, start ASC, end ASC;
	
UPDATE snp s
	INNER JOIN hg18snp h18 ON s.snp_name = h18.name
	SET s.hg18pos = h18.start;
UPDATE snp s
	INNER JOIN hg19snp h19 ON s.snp_name = h19.name
	SET s.hg19pos = h19.start;
UPDATE snp s
	INNER JOIN hg38snp h38 ON s.snp_name = h38.name
	SET s.hg38pos = h38.start;

	
	
	
	
	
	
	
	
	
	
	
	
DROP TABLE IF EXISTS ucscGeneExon;
CREATE TABLE IF NOT EXISTS ucscGeneExon (
  IDucscGeneExon int(11) NOT NULL,
  ucscGene_ID int(11) DEFAULT NULL,
  gene_symbol varchar(100) NOT NULL,
  chromosome tinyint(4) DEFAULT NULL,
  gene_alias_ID int(11) DEFAULT NULL,
  gene_ID int(11) DEFAULT NULL,
  hg18_start int(11) DEFAULT NULL,
  hg18_end int(11) DEFAULT NULL,
  hg18_exon_starts longtext,
  hg18_exon_ends longtext,
  hg19_start int(11) DEFAULT NULL,
  hg19_end int(11) DEFAULT NULL,
  hg19_exon_starts longtext,
  hg19_exon_ends longtext,
  hg38_start int(11) DEFAULT NULL,
  hg38_end int(11) DEFAULT NULL,
  hg38_exon_starts longtext,
  hg38_exon_ends longtext
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';


ALTER TABLE ucscGeneExon
  ADD PRIMARY KEY (IDucscGeneExon),
  ADD KEY gene_symbol (gene_symbol),
  ADD KEY gene_ID (gene_ID),
  ADD KEY gene_symbol_2 (gene_symbol),
  ADD KEY ucscGene_ID (ucscGene_ID);


ALTER TABLE ucscGeneExon
  MODIFY IDucscGeneExon int(11) NOT NULL AUTO_INCREMENT;


LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg18Genes'
	INTO TABLE ucscGeneExon
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(gene_symbol,chromosome,hg18_start,hg18_end,hg18_exon_starts,hg18_exon_ends);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg19Genes'
	INTO TABLE ucscGeneExon
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(gene_symbol,chromosome,hg19_start,hg19_end,hg19_exon_starts,hg19_exon_ends);
LOAD DATA INFILE '/mysql_setup/scripts/ucsc_output/hg38Genes'
	INTO TABLE ucscGeneExon
	FIELDS TERMINATED BY "\t"
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(gene_symbol,chromosome,hg38_start,hg38_end,hg38_exon_starts,hg38_exon_ends);

UPDATE ucscGeneExon ugx INNER JOIN geneAlias ga ON ugx.gene_symbol = ga.selectedSymbol SET ugx.gene_alias_ID = ga.ID, ugx.gene_ID = ga.geneID;


DROP TABLE IF EXISTS ucscBuild;
CREATE TABLE IF NOT EXISTS ucscBuild (
  build_ID int(11) NOT NULL,
  build_name varchar(50) NOT NULL,
  build_pos_col varchar(50) NOT NULL
) ENGINE=TokuDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE ucscBuild
  ADD PRIMARY KEY (build_ID);

ALTER TABLE ucscBuild
  MODIFY build_ID int(11) NOT NULL AUTO_INCREMENT;

INSERT INTO ucscBuild (build_ID, build_name, build_pos_col) VALUES
(1, 'hg18', 'hg18pos'),
(2, 'hg19', 'hg19pos'),
(3, 'hg38', 'hg38pos');

SET default_storage_engine = TOKUDB;
DROP TABLE IF EXISTS ucscGeneExonWithBuild;
CREATE TABLE ucscGeneExonWithBuild (SELECT * FROM ucscBuild b CROSS JOIN ucscGeneExon x);


ALTER TABLE `ucscGeneExonWithBuild` ADD `transcript` INT NULL AFTER `gene_ID`, ADD `transcript_key` VARCHAR(200) NULL AFTER `transcript`, ADD `start` INT NULL AFTER `transcript_key`, ADD `end` INT NULL AFTER `start`, ADD `exon_starts` LONGTEXT NULL AFTER `end`, ADD `exon_ends` LONGTEXT NULL AFTER `exon_starts`;

UPDATE ucscGeneExonWithBuild SET `start`=hg18_start, `end`=hg18_end, exon_starts=hg18_exon_starts, exon_ends=hg18_exon_ends WHERE build_name='hg18';
UPDATE ucscGeneExonWithBuild SET `start`=hg19_start, `end`=hg19_end, exon_starts=hg19_exon_starts, exon_ends=hg19_exon_ends WHERE build_name='hg19';
UPDATE ucscGeneExonWithBuild SET `start`=hg38_start, `end`=hg38_end, exon_starts=hg38_exon_starts, exon_ends=hg38_exon_ends WHERE build_name='hg38';

DELETE FROM ucscGeneExonWithBuild WHERE `start` IS NULL AND `end` IS NULL;
UPDATE ucscGeneExonWithBuild SET `transcript_key`=CONCAT(build_name, '-', gene_symbol, '-', start, '-', end);
ALTER TABLE ucscGeneExonWithBuild DROP IF EXISTS `ID`, ADD `ID` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`ID`), ADD KEY gene_symbol (gene_symbol), ADD KEY chromosome (chromosome);

-- -- This step is needed because there are a lot of wierd geney thingies scattered all over the genome, with the same name (for example,
-- -- Metazoa_SRP occurs all over the place). So we need to give them all unique names if they are on different chromosomes.

-- CREATE TEMPORARY TABLE distinctGeneSymbol AS (SELECT DISTINCT(gene_symbol) FROM
-- (SELECT x1.ID AS ID1, x2.ID AS ID2, x1.build_name, x1.gene_symbol, x1.chromosome AS chr1, x2.chromosome AS chr2, x1.start AS start1, x2.start AS start2 FROM `ucscGeneExonWithBuild` x1 INNER JOIN ucscGeneExonWithBuild x2 ON x1.gene_symbol = x2.gene_symbol AND x1.build_ID = x2.build_ID WHERE x1.chromosome < x2.chromosome) a);

-- ALTER TABLE distinctGeneSymbol DROP IF EXISTS `ID`, ADD `ID` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`ID`), ADD KEY gene_symbol (gene_symbol);

-- UPDATE ucscGeneExonWithBuild x INNER JOIN distinctGeneSymbol g ON x.gene_symbol = g.gene_symbol SET x.gene_symbol=CONCAT(x.gene_symbol, '(chr', x.chromosome, ')');

DROP TABLE IF EXISTS ucscGene;
CREATE TABLE IF NOT EXISTS ucscGene (
  `ID` int(11) NOT NULL,
  gene_symbol varchar(100) NOT NULL,
  chromosome int(11) DEFAULT NULL,
  hg18_start int(11) DEFAULT NULL,
  hg18_end int(11) DEFAULT NULL,
  hg19_start int(11) DEFAULT NULL,
  hg19_end int(11) DEFAULT NULL,
  hg38_start int(11) DEFAULT NULL,
  hg38_end int(11) DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE ucscGene
  ADD PRIMARY KEY (`ID`),
  ADD KEY gene_symbol (gene_symbol);

ALTER TABLE ucscGene
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
  
INSERT INTO ucscGene (gene_symbol, chromosome)
	SELECT DISTINCT(gene_symbol), chromosome FROM ucscGeneExonWithBuild
	ORDER BY chromosome ASC, start ASC;
	
UPDATE ucscGene g INNER JOIN ucscGeneExonWithBuild x ON g.gene_symbol = x.gene_symbol
	SET x.ucscGene_ID = g.ID;



DROP TABLE IF EXISTS ucscExon;
CREATE TABLE IF NOT EXISTS ucscExon (
  `ID` int(11) NOT NULL,
  ucscGeneRange_ID int(11) NOT NULL,
  transcript_key VARCHAR(200) NULL,
  transcript_num int(11) NOT NULL,
  start int(11) NOT NULL,
  end int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE ucscExon
  ADD PRIMARY KEY (`ID`) CLUSTERING='YES',
  ADD INDEX (ucscGeneRange_ID),
  ADD INDEX (transcript_key);
  
ALTER TABLE ucscExon
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

DROP TABLE IF EXISTS ucscGeneRange;
CREATE TABLE IF NOT EXISTS ucscGeneRange (
  `ID` int(11) NOT NULL,
  ucscGene_ID int(11) NOT NULL,
  transcript_key VARCHAR(200) NULL,
  build_ID int(11) NOT NULL,
  chromosome int(11) NOT NULL,
  start int(11) NOT NULL,
  end int(11) NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE ucscGeneRange
  ADD INDEX(transcript_key),
  ADD INDEX(ucscGene_ID);



-- Then you will need to run populateExons.js - the logic is too complicated to easily implement it in SQL.






-- -- The following was used to add some chromosome values to genes where the chromosome value was previously NULL.
-- -- This required the probe position indexes to be recalibrated.
-- UPDATE gene g INNER JOIN ucscGeneExon a ON g.ID = a.gene_ID SET g.chromosome = a.chromosome WHERE g.chromosome IS NULL AND a.chromosome IS NOT NULL;

-- UPDATE gene g INNER JOIN ucscGeneExon a ON g.ID = a.gene_ID SET g.hg18_start = a.hg18_start, g.hg18_end = a.hg18_end WHERE a.hg18_start IS NOT NULL AND a.hg18_end IS NOT NULL;
-- UPDATE gene g INNER JOIN ucscGeneExon a ON g.ID = a.gene_ID SET g.hg19_start = a.hg19_start, g.hg19_end = a.hg19_end WHERE a.hg19_start IS NOT NULL AND a.hg19_end IS NOT NULL;
-- UPDATE gene g INNER JOIN ucscGeneExon a ON g.ID = a.gene_ID SET g.hg38_start = a.hg38_start, g.hg38_end = a.hg38_end WHERE a.hg38_start IS NOT NULL AND a.hg38_end IS NOT NULL;

-- UPDATE gene SET startPos = NULL;
-- UPDATE gene SET startPos = hg19_start WHERE startPos IS NULL;
-- UPDATE gene SET startPos = hg38_start WHERE startPos IS NULL;
-- UPDATE gene SET startPos = hg18_start WHERE startPos IS NULL;

-- DROP TABLE IF EXISTS gene_new;
-- CREATE TABLE IF NOT EXISTS gene_new (
  -- `ID` smallint(6) NOT NULL,
  -- illumina_gene varchar(20) NOT NULL,
  -- chromosome tinyint(4) DEFAULT NULL,
  -- old_gene_ID int(11) NOT NULL,
  -- start_pos int(11) NOT NULL,
  -- hg18_start int(11) DEFAULT NULL,
  -- hg18_end int(11) DEFAULT NULL,
  -- hg19_start int(11) DEFAULT NULL,
  -- hg19_end int(11) DEFAULT NULL,
  -- hg38_start int(11) DEFAULT NULL,
  -- hg38_end int(11) DEFAULT NULL
-- ) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';


-- ALTER TABLE gene_new
  -- ADD PRIMARY KEY (`ID`),
  -- ADD UNIQUE KEY illumina_gene (illumina_gene),
  -- ADD KEY chromosome (chromosome),
  -- ADD KEY hg18_start (hg18_start),
  -- ADD KEY hg19_start (hg19_start),
  -- ADD KEY hg38_start (hg38_start),
  -- ADD KEY old_gene_ID (old_gene_ID),
  -- ADD KEY start_pos (start_pos);


-- ALTER TABLE gene_new
  -- MODIFY `ID` smallint(6) NOT NULL AUTO_INCREMENT;

-- INSERT INTO geneNew (
-- illumina_gene
-- ,chromosome
-- ,old_gene_ID
-- ,start_pos
-- ,hg18_start
-- ,hg18_end
-- ,hg19_start
-- ,hg19_end
-- ,hg38_start
-- ,hg38_end)
-- SELECT (
-- illumina_gene
-- ,chromosome
-- ,ID
-- ,start_pos
-- ,hg18_start
-- ,hg18_end
-- ,hg19_start
-- ,hg19_end
-- ,hg38_start
-- ,hg38_end) FROM gene ORDER BY chromosome ASC, startPos ASC;



-- INSERT INTO probe_new (
-- old_ID,
-- probeName,
-- geneID,
-- start_position,
-- hg18pos,
-- hg18endpos,
-- hg19pos,
-- hg19endpos,
-- hg38pos,
-- hg38endpos,
-- minPValue)
-- SELECT `ID`,
-- probeName,
-- geneID,
-- start_position,
-- hg18pos,
-- hg18endpos,
-- hg19pos,
-- hg19endpos,
-- hg38pos,
-- hg38endpos,
-- minPValue FROM probe ORDER BY geneID ASC, start_position ASC;

-- UPDATE probe p INNER JOIN probe_new pn ON p.ID = pn.old_ID SET p.posIndex = pn.ID;