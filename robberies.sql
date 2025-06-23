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
	`anim` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  `drops` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

