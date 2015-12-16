-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 28, 2014 at 01:23 PM
-- Server version: 10.1.0-MariaDB-1~trusty
-- PHP Version: 5.5.9-1ubuntu4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `system_genomics`
--

-- --------------------------------------------------------

--
-- Table structure for table `effect`
--

DROP TABLE IF EXISTS `effect`;
CREATE TABLE IF NOT EXISTS `effect` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `snpID` bigint(20) DEFAULT NULL,
  `probeID` int(11) DEFAULT NULL,
  `effect` double NOT NULL,
  `standard_error` double NOT NULL,
  `heritability` double NOT NULL,
  `log_odds_ratio` double NOT NULL,
  `p_value` double NOT NULL,
  PRIMARY KEY (`ID`) `CLUSTERING`=YES,
  KEY `snpID` (`snpID`),
  KEY `probeID` (`probeID`),
  KEY `snp_clust` (`snpID`) `clustering`=yes
) ENGINE=TokuDB  DEFAULT CHARSET=latin1 `COMPRESSION`=TOKUDB_LZMA AUTO_INCREMENT=2358604651 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
