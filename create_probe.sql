-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 28, 2014 at 01:22 PM
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
-- Table structure for table `probe`
--

DROP TABLE IF EXISTS `probe`;
CREATE TABLE IF NOT EXISTS `probe` (
  `ID` int(20) NOT NULL AUTO_INCREMENT,
  `illumina_gene` varchar(100) NOT NULL,
  `probeID` varchar(100) NOT NULL,
  `chromosome` tinyint(4) DEFAULT NULL,
  `start_position` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `illumina_gene` (`illumina_gene`),
  KEY `probeID` (`probeID`),
  KEY `start_position` (`start_position`),
  KEY `chromosome` (`chromosome`,`start_position`),
  KEY `chromosome_3` (`chromosome`) USING BTREE
) ENGINE=MEMORY  DEFAULT CHARSET=latin1 `compression`=TOKUDB_UNCOMPRESSED AUTO_INCREMENT=17996 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
