-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 28, 2014 at 01:05 PM
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
-- Table structure for table `snp`
--

DROP TABLE IF EXISTS `snp`;
CREATE TABLE IF NOT EXISTS `snp` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `chromosome` tinyint(4) NOT NULL,
  `snp_name` varchar(100) NOT NULL,
  `position` bigint(20) NOT NULL,
  `AL1` char(1) DEFAULT NULL,
  `AL2` char(1) DEFAULT NULL,
  `freq1` double DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `snp_name` (`snp_name`),
  KEY `chromosome_2` (`chromosome`) USING BTREE,
  KEY `chromosome_3` (`chromosome`,`position`)
) ENGINE=MEMORY  DEFAULT CHARSET=latin1 `compression`='tokudb_zlib' AUTO_INCREMENT=77170 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
