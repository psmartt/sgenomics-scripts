DROP TABLE IF EXISTS gene_staging;
CREATE TABLE IF NOT EXISTS gene_staging (
  ID int(11) NOT NULL,
  my_gene_ID int(11) DEFAULT NULL,
  my_illumina_gene varchar(20) DEFAULT NULL,
  my_chromosome tinyint(4) DEFAULT NULL,
  my_probe_name varchar(20) DEFAULT NULL,
  my_start_position int(11) DEFAULT NULL,
  prev_gene_ID1 int(11) DEFAULT NULL,
  prev_illumina_gene1 varchar(20) DEFAULT NULL,
  prev_chromosome1 tinyint(4) DEFAULT NULL,
  prev_probe_name1 varchar(20) DEFAULT NULL,
  prev_start_position1 int(11) DEFAULT NULL,
  prev_gene_ID2 int(11) DEFAULT NULL,
  prev_illumina_gene2 varchar(20) DEFAULT NULL,
  prev_chromosome2 tinyint(4) DEFAULT NULL,
  prev_probe_name2 varchar(20) DEFAULT NULL,
  prev_start_position2 int(11) DEFAULT NULL,
  hgncID varchar(20) DEFAULT NULL,
  approvedSymbol varchar(50) DEFAULT NULL,
  approvedName varchar(100) DEFAULT NULL,
  status varchar(20) DEFAULT NULL,
  locusGroup varchar(20) DEFAULT NULL,
  previousSymbols varchar(200) DEFAULT NULL,
  previousName varchar(200) DEFAULT NULL,
  synonyms varchar(200) DEFAULT NULL,
  cytogeneticLocation varchar(40) DEFAULT NULL,
  chromosomeStr varchar(20) DEFAULT NULL,
  chromosome int(11) DEFAULT NULL,
  start_position int(11) DEFAULT NULL,
  arm char(1) DEFAULT NULL,
  band double DEFAULT NULL,
  accessionNumbers varchar(20) DEFAULT NULL,
  entrezGeneID varchar(20) DEFAULT NULL,
  ensemblGeneID varchar(20) DEFAULT NULL,
  pubmedIDs varchar(20) DEFAULT NULL,
  refSeqIDs varchar(20) DEFAULT NULL,
  withdrawnSymbol varchar(50) DEFAULT NULL,
  withdrawnReplacements varchar(100) DEFAULT NULL,
  withdrawnReplacement1 varchar(20) DEFAULT NULL,
  withdrawnReplacement2 varchar(20) DEFAULT NULL,
  withdrawnReplacement3 varchar(20) DEFAULT NULL,
  withdrawnReplacement4 varchar(20) DEFAULT NULL,
  withdrawnReplacement5 varchar(20) DEFAULT NULL,
  withdrawnReplacement6 varchar(20) DEFAULT NULL,
  withdrawnReplacement7 varchar(20) DEFAULT NULL,
  withdrawnReplacement8 varchar(20) DEFAULT NULL,
  replacees varchar(100) DEFAULT 'xxx',
  replacee1 varchar(20) DEFAULT NULL,
  replacee2 varchar(20) DEFAULT NULL,
  alias1 varchar(20) DEFAULT NULL,
  alias2 varchar(20) DEFAULT NULL,
  alias3 varchar(20) DEFAULT NULL,
  alias4 varchar(20) DEFAULT NULL,
  alias5 varchar(20) DEFAULT NULL,
  alias6 varchar(20) DEFAULT NULL,
  alias7 varchar(20) DEFAULT NULL,
  alias8 varchar(20) DEFAULT NULL,
  alias9 varchar(20) DEFAULT NULL,
  alias10 varchar(20) DEFAULT NULL,
  alias11 varchar(20) DEFAULT NULL,
  alias12 varchar(20) DEFAULT NULL,
  alias13 varchar(20) DEFAULT NULL,
  alias14 varchar(20) DEFAULT NULL,
  alias15 varchar(20) DEFAULT NULL,
  alias16 varchar(20) DEFAULT NULL,
  alias17 varchar(20) DEFAULT NULL,
  alias18 varchar(20) DEFAULT NULL,
  alias19 varchar(20) DEFAULT NULL,
  alias20 varchar(20) DEFAULT NULL,
  prev1 varchar(20) DEFAULT NULL,
  prev2 varchar(20) DEFAULT NULL,
  prev3 varchar(20) DEFAULT NULL,
  prev4 varchar(20) DEFAULT NULL,
  prev5 varchar(20) DEFAULT NULL,
  prev6 varchar(20) DEFAULT NULL,
  prev7 varchar(20) DEFAULT NULL,
  prev8 varchar(20) DEFAULT NULL,
  prev9 varchar(20) DEFAULT NULL,
  prev10 varchar(20) DEFAULT NULL,
  prev11 varchar(20) DEFAULT NULL,
  prev12 varchar(20) DEFAULT NULL,
  prev13 varchar(20) DEFAULT NULL,
  prev14 varchar(20) DEFAULT NULL,
  prev15 varchar(20) DEFAULT NULL,
  prev16 varchar(20) DEFAULT NULL,
  prev17 varchar(20) DEFAULT NULL,
  prev18 varchar(20) DEFAULT NULL,
  prev19 varchar(20) DEFAULT NULL,
  prev20 varchar(20) DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';


ALTER TABLE gene_staging
  ADD PRIMARY KEY (ID)
  ,ADD KEY my_gene_ID (my_gene_ID)
  ,ADD KEY my_illumina_gene (my_illumina_gene)
  ,ADD KEY prev1 (prev1)
  ,ADD KEY prev2 (prev2)
  ,ADD KEY prev3 (prev3)
  ,ADD KEY approvedSymbol (approvedSymbol)
  ,ADD KEY withdrawnSymbol (withdrawnSymbol)
  ,ADD KEY withdrawnReplacements (withdrawnReplacements)
  ;
ALTER TABLE gene_staging MODIFY ID INT(11) NOT NULL AUTO_INCREMENT;
LOAD DATA INFILE '/mysql_setup/annotation/genenames.txt' INTO TABLE gene_staging
 FIELDS TERMINATED BY "\t" LINES TERMINATED BY "\n" IGNORE 1 LINES
 (hgncID,approvedSymbol,approvedName,status,locusGroup,previousSymbols,previousName,synonyms,cytogeneticLocation,
 accessionNumbers,entrezGeneID,ensemblGeneID,pubmedIDs,refSeqIDs );

UPDATE gene_staging SET chromosomeStr = TRIM(SPLIT_STR(SPLIT_STR(cytogeneticLocation, 'q', 1), 'p', 1));
UPDATE gene_staging SET chromosome = chromosomeStr WHERE chromosomeStr BETWEEN 1 AND 22;
UPDATE gene_staging SET chromosome = 23 WHERE chromosomeStr = 'X';
UPDATE gene_staging SET chromosome = 24 WHERE chromosomeStr = 'Y';
UPDATE gene_staging SET arm = 'q', band = TRIM(SPLIT_STR(cytogeneticLocation, 'q', 2)) WHERE cytogeneticLocation LIKE '%q%';
UPDATE gene_staging SET arm = 'p', band = TRIM(SPLIT_STR(cytogeneticLocation, 'p', 2)) WHERE cytogeneticLocation LIKE '%p%';
-- UPDATE gene_staging SET band = NULL WHERE band = '';

UPDATE gene_staging SET withdrawnSymbol = TRIM(SPLIT_STR(approvedSymbol, '~', 1)) WHERE approvedSymbol LIKE '%withdraw%';
UPDATE gene_staging SET withdrawnReplacements = TRIM(SPLIT_STR(approvedName, ', see ', 2));
UPDATE gene_staging SET withdrawnReplacements = REPLACE(withdrawnReplacements, ' and ', ',');
UPDATE gene_staging SET withdrawnReplacement1 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 1))
,withdrawnReplacement2 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 2))
,withdrawnReplacement3 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 3))
,withdrawnReplacement4 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 4))
,withdrawnReplacement5 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 5))
,withdrawnReplacement6 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 6))
,withdrawnReplacement7 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 7))
,withdrawnReplacement8 = TRIM(SPLIT_STR(withdrawnReplacements, ',', 8));

-- UPDATE gene_staging SET withdrawnReplacements = NULL WHERE withdrawnReplacements = '';
-- UPDATE gene_staging SET withdrawnReplacement1 = NULL WHERE withdrawnReplacement1 = '';
-- UPDATE gene_staging SET withdrawnReplacement2 = NULL WHERE withdrawnReplacement2 = '';
-- UPDATE gene_staging SET withdrawnReplacement3 = NULL WHERE withdrawnReplacement3 = '';
-- UPDATE gene_staging SET withdrawnReplacement4 = NULL WHERE withdrawnReplacement4 = '';
-- UPDATE gene_staging SET withdrawnReplacement5 = NULL WHERE withdrawnReplacement5 = '';
-- UPDATE gene_staging SET withdrawnReplacement6 = NULL WHERE withdrawnReplacement6 = '';
-- UPDATE gene_staging SET withdrawnReplacement7 = NULL WHERE withdrawnReplacement7 = '';

UPDATE gene_staging SET alias1 = TRIM(SPLIT_STR(synonyms, ',', 1))
,alias2 = TRIM(SPLIT_STR(synonyms, ',', 2))
,alias3 = TRIM(SPLIT_STR(synonyms, ',', 3))
,alias4 = TRIM(SPLIT_STR(synonyms, ',', 4))
,alias5 = TRIM(SPLIT_STR(synonyms, ',', 5))
,alias6 = TRIM(SPLIT_STR(synonyms, ',', 6))
,alias7 = TRIM(SPLIT_STR(synonyms, ',', 7))
,alias8 = TRIM(SPLIT_STR(synonyms, ',', 8))
,alias9 = TRIM(SPLIT_STR(synonyms, ',', 9))
,alias10 = TRIM(SPLIT_STR(synonyms, ',', 10))
,alias11 = TRIM(SPLIT_STR(synonyms, ',', 11))
,alias12 = TRIM(SPLIT_STR(synonyms, ',', 12))
,alias13 = TRIM(SPLIT_STR(synonyms, ',', 13))
,alias14 = TRIM(SPLIT_STR(synonyms, ',', 14))
,alias15 = TRIM(SPLIT_STR(synonyms, ',', 15))
,alias16 = TRIM(SPLIT_STR(synonyms, ',', 16))
,alias17 = TRIM(SPLIT_STR(synonyms, ',', 17))
,alias18 = TRIM(SPLIT_STR(synonyms, ',', 18))
,alias19 = TRIM(SPLIT_STR(synonyms, ',', 19))
,alias20 = TRIM(SPLIT_STR(synonyms, ',', 20));
 
UPDATE gene_staging SET prev1 = TRIM(SPLIT_STR(previousSymbols, ',', 1))
,prev2 = TRIM(SPLIT_STR(previousSymbols, ',', 2))
,prev3 = TRIM(SPLIT_STR(previousSymbols, ',', 3))
,prev4 = TRIM(SPLIT_STR(previousSymbols, ',', 4))
,prev5 = TRIM(SPLIT_STR(previousSymbols, ',', 5))
,prev6 = TRIM(SPLIT_STR(previousSymbols, ',', 6))
,prev7 = TRIM(SPLIT_STR(previousSymbols, ',', 7))
,prev8 = TRIM(SPLIT_STR(previousSymbols, ',', 8))
,prev9 = TRIM(SPLIT_STR(previousSymbols, ',', 9))
,prev10 = TRIM(SPLIT_STR(previousSymbols, ',', 10))
,prev11 = TRIM(SPLIT_STR(previousSymbols, ',', 11))
,prev12 = TRIM(SPLIT_STR(previousSymbols, ',', 12))
,prev13 = TRIM(SPLIT_STR(previousSymbols, ',', 13))
,prev14 = TRIM(SPLIT_STR(previousSymbols, ',', 14))
,prev15 = TRIM(SPLIT_STR(previousSymbols, ',', 15))
,prev16 = TRIM(SPLIT_STR(previousSymbols, ',', 16))
,prev17 = TRIM(SPLIT_STR(previousSymbols, ',', 17))
,prev18 = TRIM(SPLIT_STR(previousSymbols, ',', 18))
,prev19 = TRIM(SPLIT_STR(previousSymbols, ',', 19))
,prev20 = TRIM(SPLIT_STR(previousSymbols, ',', 20));
 
 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.approvedSymbol	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;

UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias1	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias2	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias3	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias4	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias5	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias6	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias7	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias8	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias9	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias10	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias11	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias12	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias13	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias14	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias15	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias16	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias17	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias18	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias19	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.alias20	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev1	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev2	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev3	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev4	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev5	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev6	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev7	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev8	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev9	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position; 
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev10	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev11	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev12	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev13	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev14	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev15	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev16	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev17	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev18	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev19	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.prev20	AND g.chromosome = gst.chromosome AND my_gene_ID IS NULL INNER JOIN probe p ON g.ID = p.geneID SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName, my_start_position = p.start_position;

UPDATE gene_staging gst
	INNER JOIN gene g ON g.illumina_gene = gst.withdrawnSymbol AND my_gene_ID IS NULL
	INNER JOIN probe p ON g.ID = p.geneID
	SET my_gene_ID = g.ID, my_illumina_gene = g.illumina_gene, my_chromosome = g.chromosome, my_probe_name = p.probeName,
	my_start_position = p.start_position;


INSERT INTO gene_staging (my_gene_ID, my_illumina_gene, my_chromosome, my_probe_name, my_start_position, chromosome)
 SELECT g.ID AS my_gene_ID, g.illumina_gene AS my_illumina_gene, g.chromosome AS my_chromosome, p.probeName AS my_probe_name, p.start_position AS my_start_position,
 g.chromosome AS chromosome FROM gene g 
 LEFT JOIN gene_staging gst ON g.illumina_gene = my_illumina_gene
 INNER JOIN probe p ON p.geneID = g.ID
 WHERE gst.my_gene_ID IS NULL;

UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement1 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement2 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement3 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement4 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement5 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement6 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement7 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));
UPDATE gene_staging gs1 INNER JOIN gene_staging gs2 ON gs1.approvedSymbol = gs2.withdrawnReplacement8 SET gs1.replacees = CONCAT(gs1.replacees,CONCAT(',',gs2.withdrawnSymbol));

UPDATE gene_staging SET replacees = NULL WHERE replacees = 'xxx';
UPDATE gene_staging SET replacees = REPLACE(replacees, 'xxx,', '');

UPDATE gene_staging SET replacee1 = TRIM(SPLIT_STR(replacees, ',', 1))
,replacee2 = TRIM(SPLIT_STR(replacees, ',', 2));

UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.replacee1 
	AND g.chromosome = gst.chromosome AND prev_gene_ID1 IS NULL INNER JOIN probe p ON g.ID = p.geneID
	SET prev_gene_ID1 = g.ID, prev_illumina_gene1 = g.illumina_gene, prev_chromosome1 = g.chromosome,
	prev_probe_name1 = p.probeName, prev_start_position1 = p.start_position;
UPDATE gene_staging gst INNER JOIN gene g ON g.illumina_gene = gst.replacee2
	AND g.chromosome = gst.chromosome AND prev_gene_ID2 IS NULL INNER JOIN probe p ON g.ID = p.geneID
	SET prev_gene_ID2 = g.ID, prev_illumina_gene2 = g.illumina_gene, prev_chromosome2 = g.chromosome,
	prev_probe_name2 = p.probeName, prev_start_position2 = p.start_position;



UPDATE gene_staging SET chromosome = my_chromosome WHERE chromosome IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band = cy.band SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band AND cy.band + 0.1 SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band AND cy.band + 0.2 SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band AND cy.band + 0.3 SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band AND cy.band + 0.4 SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band - 0.1 AND cy.band SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band - 0.2 AND cy.band SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band - 0.3 AND cy.band SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;
UPDATE gene_staging gs INNER JOIN cytoband cy ON gs.chromosome = cy.chromosomeID AND gs.arm = cy.arm AND gs.band BETWEEN cy.band - 0.4 AND cy.band SET gs.start_position = cy.start_pos WHERE gs.start_position IS NULL;

UPDATE gene_staging SET start_position = my_start_position WHERE my_start_position IS NOT NULL AND start_position IS NULL;

DROP TABLE IF EXISTS gene_staging2;
CREATE TABLE IF NOT EXISTS gene_staging2 LIKE gene_staging;

INSERT INTO gene_staging2 (
my_gene_ID
,my_illumina_gene
,my_chromosome
,my_probe_name
,my_start_position
,prev_gene_ID1
,prev_illumina_gene1
,prev_chromosome1
,prev_probe_name1
,prev_start_position1
,prev_gene_ID2
,prev_illumina_gene2
,prev_chromosome2
,prev_probe_name2
,prev_start_position2
,hgncID
,approvedSymbol
,approvedName
,status
,locusGroup
,previousSymbols
,previousName
,synonyms
,cytogeneticLocation
,chromosomeStr
,chromosome
,start_position
,arm
,band
,accessionNumbers
,entrezGeneID
,ensemblGeneID
,pubmedIDs
,refSeqIDs
,withdrawnSymbol
,withdrawnReplacements
,withdrawnReplacement1
,withdrawnReplacement2
,withdrawnReplacement3
,withdrawnReplacement4
,withdrawnReplacement5
,withdrawnReplacement6
,withdrawnReplacement7
,withdrawnReplacement8
,replacees
,replacee1
,replacee2
,alias1
,alias2
,alias3
,alias4
,alias5
,alias6
,alias7
,alias8
,alias9
,alias10
,alias11
,alias12
,alias13
,alias14
,alias15
,alias16
,alias17
,alias18
,alias19
,alias20
,prev1
,prev2
,prev3
,prev4
,prev5
,prev6
,prev7
,prev8
,prev9
,prev10
,prev11
,prev12
,prev13
,prev14
,prev15
,prev16
,prev17
,prev18
,prev19
,prev20
) SELECT 
my_gene_ID
,my_illumina_gene
,my_chromosome
,my_probe_name
,my_start_position
,prev_gene_ID1
,prev_illumina_gene1
,prev_chromosome1
,prev_probe_name1
,prev_start_position1
,prev_gene_ID2
,prev_illumina_gene2
,prev_chromosome2
,prev_probe_name2
,prev_start_position2
,hgncID
,approvedSymbol
,approvedName
,status
,locusGroup
,previousSymbols
,previousName
,synonyms
,cytogeneticLocation
,chromosomeStr
,chromosome
,start_position
,arm
,band
,accessionNumbers
,entrezGeneID
,ensemblGeneID
,pubmedIDs
,refSeqIDs
,withdrawnSymbol
,withdrawnReplacements
,withdrawnReplacement1
,withdrawnReplacement2
,withdrawnReplacement3
,withdrawnReplacement4
,withdrawnReplacement5
,withdrawnReplacement6
,withdrawnReplacement7
,withdrawnReplacement8
,replacees
,replacee1
,replacee2
,alias1
,alias2
,alias3
,alias4
,alias5
,alias6
,alias7
,alias8
,alias9
,alias10
,alias11
,alias12
,alias13
,alias14
,alias15
,alias16
,alias17
,alias18
,alias19
,alias20
,prev1
,prev2
,prev3
,prev4
,prev5
,prev6
,prev7
,prev8
,prev9
,prev10
,prev11
,prev12
,prev13
,prev14
,prev15
,prev16
,prev17
,prev18
,prev19
,prev20 FROM gene_staging WHERE approvedName NOT LIKE '%withdraw%' AND locusGroup <> 'phenotype' ORDER BY chromosome ASC, start_position ASC;

DROP TABLE IF EXISTS geneAlias;
CREATE TABLE IF NOT EXISTS geneAlias (
  ID int(11) NOT NULL,
  my_illumina_gene varchar(20) DEFAULT NULL,
  approvedSymbol varchar(50) DEFAULT NULL,
  selectedSymbol varchar(50) DEFAULT NULL,
  displayString varchar(100) DEFAULT NULL,
  geneID int(11) NOT NULL,
  chromosome tinyint(4) NULL,
  start_position int(11) NULL,
  symbolType tinyint(4) NOT NULL COMMENT '1=Approved symbol,\n2=synonym,\n3=previous symbol,\n4=withdrawn symbol\n5=not found in current release',
  isDuplicate bit
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';

ALTER TABLE geneAlias
  ADD PRIMARY KEY (ID),
  ADD KEY my_illumina_gene (my_illumina_gene),
  ADD KEY approvedSymbol (approvedSymbol),
  ADD KEY selectedSymbol (selectedSymbol),
  ADD KEY geneID (geneID);

ALTER TABLE geneAlias
  MODIFY ID int(11) NOT NULL AUTO_INCREMENT;

-- We will do a two-pass system - load up the geneAlias table the first time to allow us to easily discover any illumina genes that 
-- are not found anywhere in the geneCodes data.  Then we will at those extra genes straight onto the geneCodes table, and do the
-- whole process as a second pass.
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, approvedSymbol, ID, 1 FROM gene_staging2 WHERE approvedSymbol IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias1 , ID, 2 FROM gene_staging2 WHERE alias1  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias2 , ID, 2 FROM gene_staging2 WHERE alias2  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias3 , ID, 2 FROM gene_staging2 WHERE alias3  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias4 , ID, 2 FROM gene_staging2 WHERE alias4  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias5 , ID, 2 FROM gene_staging2 WHERE alias5  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias6 , ID, 2 FROM gene_staging2 WHERE alias6  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias7 , ID, 2 FROM gene_staging2 WHERE alias7  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias8 , ID, 2 FROM gene_staging2 WHERE alias8  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias9 , ID, 2 FROM gene_staging2 WHERE alias9  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias10, ID, 2 FROM gene_staging2 WHERE alias10 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias11, ID, 2 FROM gene_staging2 WHERE alias11 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias12, ID, 2 FROM gene_staging2 WHERE alias12 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias13, ID, 2 FROM gene_staging2 WHERE alias13 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias14, ID, 2 FROM gene_staging2 WHERE alias14 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias15, ID, 2 FROM gene_staging2 WHERE alias15 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias16, ID, 2 FROM gene_staging2 WHERE alias16 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias17, ID, 2 FROM gene_staging2 WHERE alias17 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias18, ID, 2 FROM gene_staging2 WHERE alias18 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias19, ID, 2 FROM gene_staging2 WHERE alias19 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, alias20, ID, 2 FROM gene_staging2 WHERE alias20 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev1 , ID, 3 FROM gene_staging2 WHERE prev1  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev2 , ID, 3 FROM gene_staging2 WHERE prev2  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev3 , ID, 3 FROM gene_staging2 WHERE prev3  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev4 , ID, 3 FROM gene_staging2 WHERE prev4  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev5 , ID, 3 FROM gene_staging2 WHERE prev5  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev6 , ID, 3 FROM gene_staging2 WHERE prev6  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev7 , ID, 3 FROM gene_staging2 WHERE prev7  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev8 , ID, 3 FROM gene_staging2 WHERE prev8  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev9 , ID, 3 FROM gene_staging2 WHERE prev9  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev10, ID, 3 FROM gene_staging2 WHERE prev10 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev11, ID, 3 FROM gene_staging2 WHERE prev11 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev12, ID, 3 FROM gene_staging2 WHERE prev12 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev13, ID, 3 FROM gene_staging2 WHERE prev13 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev14, ID, 3 FROM gene_staging2 WHERE prev14 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev15, ID, 3 FROM gene_staging2 WHERE prev15 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev16, ID, 3 FROM gene_staging2 WHERE prev16 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev17, ID, 3 FROM gene_staging2 WHERE prev17 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev18, ID, 3 FROM gene_staging2 WHERE prev18 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev19, ID, 3 FROM gene_staging2 WHERE prev19 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev20, ID, 3 FROM gene_staging2 WHERE prev20 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, replacee1, ID, 4 FROM gene_staging2 WHERE replacee1 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, replacee2, ID, 4 FROM gene_staging2 WHERE replacee2 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev_illumina_gene1, ID, 5 FROM gene_staging2 WHERE prev_illumina_gene1 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, symbolType) SELECT my_illumina_gene, approvedSymbol, prev_illumina_gene2, ID, 5 FROM gene_staging2 WHERE prev_illumina_gene2 IS NOT NULL;

INSERT INTO gene_staging2 (my_gene_ID, my_illumina_gene, my_chromosome, my_probe_name, my_start_position)
	SELECT g.ID, g.illumina_gene, g.chromosome, p.probeName, p.start_position
	FROM gene g
	INNER JOIN probe p ON g.ID = p.ID
	LEFT JOIN geneAlias ga ON g.illumina_gene = ga.my_illumina_gene
	WHERE ga.geneID IS NULL;
	
-- second pass

TRUNCATE geneAlias;	
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, approvedSymbol,		ID, my_chromosome, my_start_position, 1 FROM gene_staging2 WHERE approvedSymbol IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias1 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias1  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias2 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias2  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias3 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias3  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias4 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias4  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias5 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias5  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias6 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias6  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias7 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias7  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias8 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias8  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias9 ,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias9  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias10,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias10 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias11,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias11 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias12,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias12 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias13,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias13 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias14,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias14 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias15,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias15 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias16,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias16 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias17,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias17 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias18,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias18 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias19,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias19 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, alias20,				ID, my_chromosome, my_start_position, 2 FROM gene_staging2 WHERE alias20 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev1 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev1  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev2 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev2  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev3 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev3  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev4 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev4  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev5 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev5  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev6 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev6  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev7 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev7  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev8 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev8  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev9 ,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev9  IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev10,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev10 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev11,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev11 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev12,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev12 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev13,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev13 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev14,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev14 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev15,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev15 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev16,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev16 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev17,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev17 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev18,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev18 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev19,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev19 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev20,				ID, my_chromosome, my_start_position, 3 FROM gene_staging2 WHERE prev20 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, replacee1,			ID, my_chromosome, my_start_position, 4 FROM gene_staging2 WHERE replacee1 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, replacee2,			ID, my_chromosome, my_start_position, 4 FROM gene_staging2 WHERE replacee2 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev_illumina_gene1,	ID, my_chromosome, my_start_position, 5 FROM gene_staging2 WHERE prev_illumina_gene1 IS NOT NULL;
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, start_position, symbolType) SELECT my_illumina_gene, approvedSymbol, prev_illumina_gene2,	ID, my_chromosome, my_start_position, 5 FROM gene_staging2 WHERE prev_illumina_gene2 IS NOT NULL;






ALTER TABLE gene_staging2
  DROP chromosomeStr,
  DROP arm,
  DROP band,
  DROP withdrawnSymbol,
  DROP withdrawnReplacements,
  DROP withdrawnReplacement1,
  DROP withdrawnReplacement2,
  DROP withdrawnReplacement3,
  DROP withdrawnReplacement4,
  DROP withdrawnReplacement5,
  DROP withdrawnReplacement6,
  DROP withdrawnReplacement7,
  DROP withdrawnReplacement8,
  DROP replacees,
  DROP replacee1,
  DROP replacee2,
  DROP alias1,
  DROP alias2,
  DROP alias3,
  DROP alias4,
  DROP alias5,
  DROP alias6,
  DROP alias7,
  DROP alias8,
  DROP alias9,
  DROP alias10,
  DROP alias11,
  DROP alias12,
  DROP alias13,
  DROP alias14,
  DROP alias15,
  DROP alias16,
  DROP alias17,
  DROP alias18,
  DROP alias19,
  DROP alias20,
  DROP prev1,
  DROP prev2,
  DROP prev3,
  DROP prev4,
  DROP prev5,
  DROP prev6,
  DROP prev7,
  DROP prev8,
  DROP prev9,
  DROP prev10,
  DROP prev11,
  DROP prev12,
  DROP prev13,
  DROP prev14,
  DROP prev15,
  DROP prev16,
  DROP prev17,
  DROP prev18,
  DROP prev19,
  DROP prev20;


UPDATE geneAlias ga1 INNER JOIN geneAlias ga2 ON ga1.geneID = ga2.geneID AND ga1.selectedSymbol = ga2.selectedSymbol AND ga1.ID < ga2.ID SET ga2.isDuplicate = 1;
DELETE FROM geneAlias WHERE isDuplicate = 1;
UPDATE geneAlias ga1 INNER JOIN geneAlias ga2 ON ga1.selectedSymbol = ga2.selectedSymbol AND ga1.symbolType = 1 AND ga2.symbolType <> 1 SET ga2.isDuplicate = 1;
DELETE FROM geneAlias WHERE isDuplicate = 1;

-- If we can't tell which was the "correct" alias or previous symbol we need to delete all flavours.  It just means the users won't
-- be able to use it as an alias. AFAICT, this probably will not cause inconvenience. For instance, HOX1 used to be thought to be
-- one gene.  Now it is divided into HOX1A, HOX1B ... etc. If they start typing "HOX", they will get all these options in any case.

UPDATE geneAlias ga1 INNER JOIN geneAlias ga2 ON ga1.selectedSymbol = ga2.selectedSymbol AND ga1.ID < ga2.ID SET ga1.isDuplicate = 1, ga2.isDuplicate = 1;
DELETE FROM geneAlias WHERE isDuplicate = 1;
UPDATE geneAlias ga INNER JOIN gene_staging2 gs ON ga.approvedSymbol = gs.approvedSymbol AND ga.chromosome IS NULL SET ga.chromosome = gs.chromosome;
UPDATE geneAlias ga INNER JOIN gene_staging2 gs ON ga.approvedSymbol = gs.approvedSymbol AND ga.start_position IS NULL SET ga.start_position = gs.start_position;

DROP TABLE IF EXISTS geneCopy1;
CREATE TABLE IF NOT EXISTS geneCopy1 (
  ID smallint(6) NOT NULL,
  illumina_gene varchar(20) NOT NULL,
  approved_symbol varchar(20) NOT NULL,
  chromosome tinyint(4) DEFAULT NULL,
  start_position int,
  isDuplicate bit DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression='tokudb_zlib';


ALTER TABLE geneCopy1
  ADD PRIMARY KEY (ID),
  ADD UNIQUE KEY illumina_gene (illumina_gene),
  ADD KEY approved_symbol (approved_symbol);


ALTER TABLE geneCopy1
  MODIFY ID smallint(6) NOT NULL AUTO_INCREMENT;

INSERT INTO geneCopy1 (illumina_gene, approved_symbol, chromosome) SELECT illumina_gene, illumina_gene, chromosome FROM gene;
UPDATE geneCopy1 gc1 INNER JOIN geneAlias ga ON gc1.illumina_gene = ga.my_illumina_gene SET gc1.approved_symbol = ga.approvedSymbol, gc1.chromosome = ga.chromosome;
UPDATE geneCopy1 gc1 INNER JOIN geneAlias ga ON gc1.illumina_gene = ga.selectedSymbol SET gc1.approved_symbol = ga.approvedSymbol, gc1.chromosome = ga.chromosome;

UPDATE geneAlias ga LEFT JOIN geneCopy1 gc ON ga.approvedSymbol = gc.approved_symbol SET ga.isDuplicate = 1 WHERE gc.approved_symbol IS NULL;
DELETE FROM geneAlias WHERE isDuplicate = 1;

DROP TABLE IF EXISTS probeCopy;
CREATE TABLE IF NOT EXISTS probeCopy (
  ID int(20) NOT NULL,
  posIndex smallint(6) NOT NULL,
  probeName varchar(100) NOT NULL,
  geneID smallint(6) NOT NULL,
  newGeneSymbol varchar(20) NOT NULL,
  newGeneID smallint(6) NOT NULL,
  start_position int(11) DEFAULT NULL,
  minPValue double NOT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8 compression=TOKUDB_UNCOMPRESSED;


ALTER TABLE probeCopy
  ADD PRIMARY KEY (ID),
  ADD KEY probeID (probeName),
  ADD KEY start_position (start_position),
  ADD KEY geneID (geneID),
  ADD KEY posIndex (posIndex),
  ADD KEY newGeneID (newGeneID);


ALTER TABLE probeCopy
  MODIFY ID int(20) NOT NULL AUTO_INCREMENT;
  
INSERT INTO probeCopy (posIndex, probeName, geneID, start_position, minPValue)
	SELECT posIndex, probeName, geneID, start_position, minPValue FROM probe;
	
UPDATE geneCopy1 g1 INNER JOIN probeCopy pc ON pc.geneID = g1.ID SET pc.newGeneSymbol = g1.approved_symbol;
UPDATE geneCopy1 g1 INNER JOIN geneCopy1 g2 ON g1.approved_symbol = g2.approved_symbol AND g1.ID < g2.ID SET g2.isDuplicate = 1;

DROP TABLE IF EXISTS geneCopy2;
CREATE TABLE IF NOT EXISTS geneCopy2 LIKE gene;
INSERT INTO geneCopy2 (illumina_gene, chromosome) SELECT approved_symbol, chromosome FROM geneCopy1 WHERE isDuplicate IS NULL ORDER BY chromosome ASC, start_position ASC;
UPDATE geneCopy2 g2 INNER JOIN probeCopy pc ON pc.newGeneSymbol = g2.illumina_gene SET pc.newGeneID = g2.ID;

UPDATE geneAlias ga INNER JOIN geneCopy2 gc ON ga.approvedSymbol = gc.illumina_gene SET ga.geneID = gc.ID;

ALTER TABLE probeCopy
  DROP geneID,
  DROP newGeneSymbol;

  
ALTER TABLE probeCopy
  CHANGE newGeneID geneID SMALLINT(6) NOT NULL;
  
INSERT INTO geneAlias (my_illumina_gene, approvedSymbol, selectedSymbol, geneID, chromosome, symbolType)
	SELECT gc.illumina_gene, gc.illumina_gene, gc.illumina_gene, gc.ID, gc.chromosome, 5
	FROM geneCopy2 gc LEFT JOIN geneAlias ga2 ON gc.ID = ga2.geneID WHERE ga2.geneID IS NULL;
	
UPDATE geneAlias SET displayString = CONCAT('<b>', approvedSymbol, '</b> <i>(approved symbol)</i>') WHERE symbolType = 1;
UPDATE geneAlias SET displayString = CONCAT(selectedSymbol, '(<i>synonym for</i>) => <b>', approvedSymbol, '</b> <i>(approved symbol)</i>') WHERE symbolType = 2;
UPDATE geneAlias SET displayString = CONCAT(selectedSymbol, '(<i>previous symbol for</i>) => <b>', approvedSymbol, '</b> <i>(approved symbol)</i>') WHERE symbolType = 3;
UPDATE geneAlias SET displayString = CONCAT(selectedSymbol, '(<i>withdrawn, replaced by</i>) => <b>', approvedSymbol, '</b> <i>(approved symbol)</i>') WHERE symbolType = 4;
UPDATE geneAlias SET displayString = CONCAT('<b>', approvedSymbol, '</b> <i>(Illumina gene not in latest build)</i>') WHERE symbolType = 5;
  
SELECT * FROM probeCopy;

