-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.32-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para qbox_5006ba
CREATE DATABASE IF NOT EXISTS `qbox_5006ba` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci */;
USE `qbox_5006ba`;

-- Copiando estrutura para tabela qbox_5006ba.robberies
CREATE TABLE IF NOT EXISTS `robberies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(64) DEFAULT NULL,
  `coords` text DEFAULT NULL,
  `heading` float DEFAULT NULL,
  `prop` varchar(64) DEFAULT NULL,
  `propOffset` text DEFAULT NULL,
  `useTarget` tinyint(1) DEFAULT NULL,
  `cooldown` int(11) DEFAULT NULL,
  `requiredItem` varchar(64) DEFAULT NULL,
  `policeCall` tinyint(1) DEFAULT NULL,
  `anim` varchar(64) DEFAULT NULL,
  `anim_clip` varchar(64) DEFAULT NULL,
  `anim_dict` int(11) DEFAULT NULL,
  `drops` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportação de dados foi desmarcado.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
