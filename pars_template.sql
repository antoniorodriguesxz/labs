-- --------------------------------------------------------
-- Anfitrião:                    arodrigues.dynip.sapo.pt
-- Versão do servidor:           5.7.43 - MySQL Community Server (GPL)
-- SO do servidor:               Linux
-- HeidiSQL Versão:              12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- A despejar estrutura da base de dados para pars
CREATE DATABASE IF NOT EXISTS `pars` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `pars`;

-- A despejar estrutura para tabela pars.account
CREATE TABLE IF NOT EXISTS `account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_user_id_user_id` (`user_id`),
  CONSTRAINT `FK_user_id_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Relacao de contas por utilizador.';

-- A despejar dados para tabela pars.account: ~2 rows (aproximadamente)
INSERT INTO `account` (`id`, `user_id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Conta GGD de AR', 'Detalhe da Conta CGD de António Rodrigues', 1, '2015-07-28 05:05:17', NULL),
	(2, 1, 'Certificados Aforro Serie B de AR', 'Detalhe dos extratos dos CAf série B', 1, '2015-08-06 00:38:23', NULL);

-- A despejar estrutura para tabela pars.account_movement
CREATE TABLE IF NOT EXISTS `account_movement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `movement_type_id` int(11) DEFAULT NULL,
  `data_movimento` datetime DEFAULT NULL,
  `data_valor` datetime DEFAULT NULL,
  `descricao` varchar(150) DEFAULT NULL,
  `debito` decimal(10,3) DEFAULT NULL,
  `credito` decimal(10,3) DEFAULT NULL,
  `is_debt` tinyint(1) DEFAULT NULL,
  `is_credit` tinyint(1) DEFAULT NULL,
  `saldo_contabilistico` decimal(10,3) DEFAULT NULL,
  `saldo_disponivel` decimal(10,3) DEFAULT NULL,
  `categoria` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_accountMovement_user_id_User_user_id` (`user_id`),
  KEY `FK_accountMovement_accountId_account_id` (`account_id`),
  KEY `FK_accountMovement_movementTypeId_movementType_id` (`movement_type_id`),
  FULLTEXT KEY `IDX_descricao` (`descricao`),
  CONSTRAINT `FK_accountMovement_accountId_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_accountMovement_movementTypeId_movementType_id` FOREIGN KEY (`movement_type_id`) REFERENCES `account_movement_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_accountMovement_user_id_User_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Registo de movimentos de uma determinada conta (R_account).';

-- A despejar dados para tabela pars.account_movement: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.account_movement_csv
CREATE TABLE IF NOT EXISTS `account_movement_csv` (
  `id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `is_processed` tinyint(1) DEFAULT NULL,
  `is_error` tinyint(1) DEFAULT NULL,
  `data_movimento` date DEFAULT NULL,
  `data_valor` date DEFAULT NULL,
  `descricao` varchar(150) DEFAULT NULL,
  `categoria` varchar(150) DEFAULT NULL,
  `debito` decimal(10,3) DEFAULT NULL,
  `credito` decimal(10,3) DEFAULT NULL,
  `saldo_contabilistico` decimal(10,3) DEFAULT NULL,
  `saldo_disponivel` decimal(10,3) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- A despejar dados para tabela pars.account_movement_csv: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.account_movement_type
CREATE TABLE IF NOT EXISTS `account_movement_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `parent_type_id` int(11) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_MovementType_ParentTypeId_MovementType_Id` (`parent_type_id`),
  KEY `AccountId_Accoun_Id` (`account_id`) USING BTREE,
  CONSTRAINT `FK_AccountId_Account_Id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_MovementType_ParentTypeId_MovementType_Id` FOREIGN KEY (`parent_type_id`) REFERENCES `account_movement_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Aqui declarados os tipos de movimentos que uma conta pode ter';

-- A despejar dados para tabela pars.account_movement_type: ~9 rows (aproximadamente)
INSERT INTO `account_movement_type` (`id`, `account_id`, `parent_type_id`, `description`) VALUES
	(1, 1, NULL, 'Débito'),
	(2, 1, NULL, 'Crédito'),
	(3, 1, NULL, 'NA'),
	(4, 1, 1, 'Levantamento MB'),
	(5, 1, 2, 'Vencimento - Entidade patornal'),
	(6, 1, 1, 'Transferência - Débito'),
	(7, 1, 2, 'Transferência - Crédito'),
	(8, 1, 1, 'Compras'),
	(9, 1, 1, 'Transferência - BX Valor');

-- A despejar estrutura para tabela pars.blog
CREATE TABLE IF NOT EXISTS `blog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`) USING BTREE,
  CONSTRAINT `FK_blog_userid_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Blogs activos no modulo de B_Blog';

-- A despejar dados para tabela pars.blog: ~0 rows (aproximadamente)
INSERT INTO `blog` (`id`, `user_id`, `name`, `description`, `is_active`, `created_at`) VALUES
	(1, 1, 'Diário de ARodrigues', 'Aqui descrevo os meus acontecimentos diários. Informações uteis...', 1, '2015-07-28 04:52:19');

-- A despejar estrutura para tabela pars.category
CREATE TABLE IF NOT EXISTS `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_category_createdby_user_id` (`created_by`),
  KEY `FK_category_blogId_blog_id` (`blog_id`),
  CONSTRAINT `FK_category_blogId_blog_id` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`),
  CONSTRAINT `FK_category_createdby_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Para um determinado blog, poderão existir N categorias.';

-- A despejar dados para tabela pars.category: ~10 rows (aproximadamente)
INSERT INTO `category` (`id`, `blog_id`, `name`, `is_active`, `created_at`, `created_by`, `order`) VALUES
	(1, 1, 'Dia', 1, '2015-07-28 18:55:40', 1, 1),
	(2, 1, 'Familia', 1, '2015-07-28 18:56:27', 1, 5),
	(3, 1, 'Acontecimento', 1, '2015-07-28 18:56:27', 1, 4),
	(4, 1, 'Informação Util', 1, '2015-07-28 18:56:27', 1, 3),
	(5, 1, 'Love', 1, '2015-07-28 18:56:27', 1, 6),
	(6, 1, 'Reflexão', 1, '2015-07-28 18:56:27', 1, 7),
	(7, 1, 'Profissional', 1, '2015-07-28 18:55:40', 1, 2),
	(1000, 1, 'Carro', 1, '2018-01-22 01:24:15', 1, NULL),
	(1001, 1, 'Saúde', 1, '2019-01-12 23:41:41', 1, NULL);

-- A despejar estrutura para vista pars.creditvsdebtbyweekfromdate
-- A criar tabela temporária para vencer erros de dependências VIEW
CREATE TABLE `creditvsdebtbyweekfromdate` (
	`semana` INT(2) NULL,
	`ano` INT(4) NULL,
	`weekDates` VARCHAR(28) NULL COLLATE 'utf8mb4_general_ci',
	`credito` DECIMAL(32,3) NULL,
	`debito` DECIMAL(32,3) NULL
) ENGINE=MyISAM;

-- A despejar estrutura para vista pars.getlast13weeksexpenses
-- A criar tabela temporária para vencer erros de dependências VIEW
CREATE TABLE `getlast13weeksexpenses` (
	`semana` INT(2) NULL,
	`weekDates` VARCHAR(28) NULL COLLATE 'utf8mb4_general_ci',
	`credito` DECIMAL(32,3) NULL,
	`debito` DECIMAL(32,3) NULL
) ENGINE=MyISAM;

-- A despejar estrutura para vista pars.getmonthexpensesbyyear
-- A criar tabela temporária para vencer erros de dependências VIEW
CREATE TABLE `getmonthexpensesbyyear` (
	`month` VARCHAR(3) NULL COLLATE 'utf8mb4_general_ci',
	`credito` DECIMAL(32,3) NULL,
	`debito` DECIMAL(32,3) NULL
) ENGINE=MyISAM;

-- A despejar estrutura para procedimento pars.ImportCaixaGeralDepositosFromPARS
DELIMITER //
CREATE PROCEDURE `ImportCaixaGeralDepositosFromPARS`()
BEGIN
INSERT INTO account_movement (
    account_id,
    user_id,
    movement_type_id,
    data_movimento,
    data_valor,
    descricao,
    debito,
    credito,
    is_debt,
    is_credit,
    saldo_contabilistico,
    saldo_disponivel,
    categoria,
    created_at
)
SELECT
    r.account_id,
    r.user_id,
    r.movement_type_id,
    r.data_movimento,
    r.data_valor,
    r.descricao,
    r.debito,
    r.credito,
    r.is_debt,
    r.is_credit,
    r.saldo_contabilistico,
    r.saldo_disponivel,
    r.categoria,
    r.created_at
FROM pars.r_account_movement r
LEFT JOIN account_movement a ON a.data_movimento = r.data_movimento 
										AND a.credito = r.credito 
										AND a.debito = r.debito
										AND a.saldo_disponivel = r.saldo_disponivel
WHERE a.id IS NULL;

END//
DELIMITER ;

-- A despejar estrutura para procedimento pars.ImportViaVerdeFromPARS
DELIMITER //
CREATE PROCEDURE `ImportViaVerdeFromPARS`()
BEGIN
INSERT INTO viaverde
(user_id, identificador, matricula, referencia_mb, data_entrada, entrada, data_saida, saida, valor, valor_desconto, taxa_iva, operador, servico, data_pagamento, cartao_num, created_at)
SELECT
    rv.user_id,
    rv.identificador,
    rv.matricula,
    rv.referencia_mb,
    rv.data_entrada,
    rv.entrada,
    rv.data_saida,
    rv.saida,
    rv.valor,
    rv.valor_desconto,
    rv.taxa_iva,
    rv.operador,
    rv.servico,
    rv.data_pagamento,
    rv.cartao_num,
    rv.created_at
FROM pars.r_viaverde  rv
LEFT JOIN parsa.viaverde v ON rv.data_pagamento = v.data_pagamento AND rv.data_saida = v.data_saida AND rv.valor = v.valor
WHERE v.id IS NULL;

END//
DELIMITER ;

-- A despejar estrutura para tabela pars.post
CREATE TABLE IF NOT EXISTS `post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `blog_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `content` varchar(5000) DEFAULT NULL,
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_post_category_id_category_id` (`category_id`),
  KEY `FK_post_created_by_user_id` (`created_by`),
  KEY `FK_post_updated_by_user_id` (`updated_by`),
  KEY `IDX_post_blog_id` (`blog_id`),
  FULLTEXT KEY `IDX_Search` (`title`,`content`),
  CONSTRAINT `FK_post_blog_id_blog_id` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_post_category_id_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`),
  CONSTRAINT `FK_post_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FK_post_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Posts de um blog.';

-- A despejar dados para tabela pars.post: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.tag
CREATE TABLE IF NOT EXISTS `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_id` int(11) DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT '1',
  `tag` varchar(50) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_B_tag_blogid_blog_id` (`blog_id`),
  KEY `FK_tagXpost_createdby_user_id` (`created_by`),
  CONSTRAINT `FK_B_tag_blogid_blog_id` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`),
  CONSTRAINT `FK_tagXpost_createdby_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tags disponiveis para posts para determinado blog';

-- A despejar dados para tabela pars.tag: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.tagxpost
CREATE TABLE IF NOT EXISTS `tagxpost` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_tagXpost_postid_post_id` (`post_id`),
  KEY `FK_tagXpost_tagid_tag_id` (`tag_id`),
  KEY `FK_tagXpost_userid_user_id` (`created_by`),
  CONSTRAINT `FK_tagXpost_postid_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`),
  CONSTRAINT `FK_tagXpost_tagid_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`),
  CONSTRAINT `FK_tagXpost_userid_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Relaciona tags de um post';

-- A despejar dados para tabela pars.tagxpost: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `active_hash` varchar(255) DEFAULT NULL,
  `recover_hash` varchar(255) DEFAULT NULL,
  `remember_identifier` varchar(255) DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tabela de utilizadores, informacao de perfil.';

-- A despejar dados para tabela pars.users: ~3 rows (aproximadamente)
INSERT INTO `users` (`id`, `username`, `email`, `first_name`, `last_name`, `password`, `active`, `active_hash`, `recover_hash`, `remember_identifier`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, 'arodrigues', 'aj.rodrigues@outlook.pt', 'António', 'Rodrigues', '$2y$10$3U756v8Z1G9PfEWrUeqV1u.S1S9nakPqEe7XtPdc7uE/M/gc8Qa0q', 1, NULL, NULL, NULL, NULL, '2015-07-28 04:14:15', '2018-09-24 20:45:34'),
	(50, 'sksksk', 'toze@live.com', '', '', '$2y$10$K77Rzjvt2chYnrRMT0CX2.73/qU1RBzKkzX4kKnjF9qeUZ2Co.X5u', 1, NULL, NULL, NULL, NULL, '2015-08-24 00:43:10', '2015-08-24 00:44:19'),
	(51, 'attok', 'rodrigues.it@outlook.pt', '', '', '$2y$10$KKdLYfdM9Iat/R0m6GHRC.mEkwgPrYR1yWlYoSFfDZBE2YjrEKCli', 1, NULL, NULL, 'XOSkubv/4sR3x6Vo/XXe/A+i4ktvGKEHerWlSg2nMY15nXxFvLPO5Cn5yoG3YO8ZUBd4yPY9g+RZBtgq9Uf+buyX0l9GwQkrZ9M1H/O6pWinUs0jUiIoDw3R0JlYTzx3', 'c26471a7d8369e9342486ee23bef98c53730e9db98f08660c3a22ce219b27919', '2015-08-30 02:48:58', '2015-08-30 02:52:02');

-- A despejar estrutura para tabela pars.viaverde
CREATE TABLE IF NOT EXISTS `viaverde` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `identificador` varchar(150) DEFAULT NULL,
  `matricula` varchar(150) DEFAULT NULL,
  `referencia_mb` varchar(150) DEFAULT NULL,
  `data_entrada` datetime DEFAULT NULL,
  `entrada` varchar(150) DEFAULT NULL,
  `data_saida` datetime DEFAULT NULL,
  `saida` varchar(150) DEFAULT NULL,
  `valor` float DEFAULT NULL,
  `valor_desconto` float DEFAULT NULL,
  `taxa_iva` float DEFAULT NULL,
  `operador` varchar(150) DEFAULT NULL,
  `servico` varchar(150) DEFAULT NULL,
  `data_pagamento` datetime DEFAULT NULL,
  `cartao_num` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_viaverde_user_id_User_user_id` (`user_id`),
  CONSTRAINT `FK_viaverde_user_id_User_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Registo de actividades na via verde';

-- A despejar dados para tabela pars.viaverde: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.viaverde_csv
CREATE TABLE IF NOT EXISTS `viaverde_csv` (
  `id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `is_processed` tinyint(1) DEFAULT NULL,
  `is_error` tinyint(1) DEFAULT NULL,
  `identificador` varchar(150) DEFAULT NULL,
  `matricula` varchar(150) DEFAULT NULL,
  `referencia_mb` varchar(150) DEFAULT NULL,
  `data_entrada` date DEFAULT NULL,
  `hora_entrada` varchar(150) DEFAULT NULL,
  `entrada` varchar(150) DEFAULT NULL,
  `data_saida` date DEFAULT NULL,
  `hora_saida` varchar(150) DEFAULT NULL,
  `saida` varchar(150) DEFAULT NULL,
  `valor` decimal(10,3) DEFAULT NULL,
  `valor_desconto` decimal(10,3) DEFAULT NULL,
  `taxa_iva` varchar(150) DEFAULT NULL,
  `operador` varchar(150) DEFAULT NULL,
  `servico` varchar(150) DEFAULT NULL,
  `data_pagamento` date DEFAULT NULL,
  `cartao_num` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- A despejar dados para tabela pars.viaverde_csv: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.wallet
CREATE TABLE IF NOT EXISTS `wallet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- A despejar dados para tabela pars.wallet: ~0 rows (aproximadamente)
INSERT INTO `wallet` (`id`, `user_id`, `name`, `description`, `is_active`, `created_at`) VALUES
	(1, 1, 'Carteira AR', 'Movimentos de Carteira dia a dia', 1, '2015-07-28 04:54:10');

-- A despejar estrutura para tabela pars.wallet_movement
CREATE TABLE IF NOT EXISTS `wallet_movement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `parent_movement_id` int(11) DEFAULT NULL,
  `movementtype_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `local` varchar(100) DEFAULT NULL,
  `account_movement_id` int(11) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `paymenttype_id` int(11) DEFAULT NULL,
  `value` decimal(10,3) DEFAULT NULL,
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `temp_local` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_walletMovement_movementType_id_movementTypeId` (`movementtype_id`),
  KEY `FK_walletMovement_accountMovementId_AccountMovement_id` (`account_movement_id`),
  KEY `FK_walletMovement_postId_Post_Id` (`post_id`),
  KEY `FK_walletMovement_created_by_user_id` (`created_by`),
  KEY `FK_walletMovement_updated_by_user_id` (`updated_by`),
  KEY `FK_walletMovement_paymenttype_id` (`paymenttype_id`),
  KEY `FK_walletMovement_parentMovement_id_WMovement_id` (`parent_movement_id`),
  KEY `FK_WMovement_userid_user_id` (`user_id`) USING BTREE,
  KEY `IDX_wallet_id_Wallet_Id` (`wallet_id`) USING BTREE,
  FULLTEXT KEY `IDX_search` (`description`,`local`),
  CONSTRAINT `FK_WMovement_userid_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_walletMovement_accountMovementId_AccountMovement_id` FOREIGN KEY (`account_movement_id`) REFERENCES `account_movement` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_walletMovement_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FK_walletMovement_movementType_id_movementTypeId` FOREIGN KEY (`movementtype_id`) REFERENCES `wallet_movement_type` (`id`),
  CONSTRAINT `FK_walletMovement_parentMovement_id_WMovement_id` FOREIGN KEY (`parent_movement_id`) REFERENCES `wallet_movement` (`id`),
  CONSTRAINT `FK_walletMovement_paymenttype_id` FOREIGN KEY (`paymenttype_id`) REFERENCES `wallet_payment_type` (`id`),
  CONSTRAINT `FK_walletMovement_postId_Post_Id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`),
  CONSTRAINT `FK_walletMovement_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FK_wallet_id_wallet_id` FOREIGN KEY (`wallet_id`) REFERENCES `wallet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Movimentos de uma determinada carteira, com possivel associacao de B_post e R_account_movement.';

-- A despejar dados para tabela pars.wallet_movement: ~0 rows (aproximadamente)

-- A despejar estrutura para tabela pars.wallet_movement_type
CREATE TABLE IF NOT EXISTS `wallet_movement_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_wMovementType_walletId_wWallet_id` (`wallet_id`),
  KEY `FK_wMovementType_createdBy_user_id` (`created_by`),
  CONSTRAINT `FK_wMovementType_createdBy_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tipos de movimento que uma carteira pode ter e os destinos possiveis.';

-- A despejar dados para tabela pars.wallet_movement_type: ~41 rows (aproximadamente)
INSERT INTO `wallet_movement_type` (`id`, `wallet_id`, `parent_id`, `name`, `description`, `is_active`, `created_at`, `created_by`, `order`) VALUES
	(1, 1, NULL, 'Débito', 'Débito na carteira', 1, NULL, 1, NULL),
	(2, 1, NULL, 'Crédito', 'Crédito na carteira', 1, NULL, 1, NULL),
	(3, 1, NULL, 'NA', 'NA', 0, NULL, 1, 9),
	(5, 1, 1, 'Supermercado', 'Despesas com alimentação no supermercado', 1, NULL, 1, 2),
	(7, 1, 1, 'Saúde', 'Despesas gerais com Saúde', 1, NULL, 1, 6),
	(10, 1, 1, 'Farmácia', 'Desepesas com medicação', 1, NULL, 1, 1),
	(12, 1, 7, 'Seguro Saúde', 'Seguro de Saúde', 1, NULL, 1, 4),
	(14, 1, 1, 'Lazer', 'Gastos em lazer', 1, NULL, 1, 3),
	(15, 1, 14, 'Cinema', 'Gatos com ida a cinema', 1, NULL, 1, 3),
	(16, 1, 14, 'Capsulas Café', 'Gastos relacionados com saidas, bar, discoteca...', 1, NULL, 1, 2),
	(17, 1, 14, 'Jogos/Revistas', 'Relacionado com jogos ou revistas', 1, NULL, 1, 1),
	(19, 1, NULL, 'Telecomunicações', 'Internet, telemóveis, tv ...', 1, NULL, 1, 4),
	(22, 1, NULL, 'Gás', 'Despesas com Gás', 1, NULL, 1, 3),
	(23, 1, NULL, 'Empréstimo', 'Empréstimos que fiz a alguém, valores recebidos de alguém relativos a um empréstimo', 1, NULL, 1, 5),
	(24, 1, NULL, 'Renda', 'Renda Habitação', 1, NULL, 1, 6),
	(26, 1, 1, 'Impostos', 'Despesas relacionadas com Finanças/Cartorios/.. Estado.', 1, NULL, 1, 8),
	(27, 1, 1, 'Transportes Públicos', 'Despesas relacionadas com Transporte', 1, NULL, 1, 4),
	(28, 1, 27, 'Seguro Automovél', 'Seguro Automóvel', 1, NULL, 1, 3),
	(29, 1, 27, 'Combustível', 'Combustível', 1, NULL, 1, 1),
	(33, 1, 27, 'Reparações Automóvel', 'Oficina, peças, reparações', 1, NULL, 1, 2),
	(34, 1, 27, 'Imposto Automóvel', 'Imposto com automovel', 1, NULL, 1, 3),
	(35, 1, 27, 'Multas', 'Pagamento de infrações', 1, NULL, 1, 4),
	(38, 1, NULL, 'Mensalidade/Propinas', 'Propinas, gastos com o estabelicimento de ensino', 1, NULL, 1, 2),
	(39, 1, 1, 'Operações Financeiras', 'Movimentos relacionados com conta bancária', 1, NULL, 1, 1),
	(41, 1, 39, 'Levantamento MB', 'Levantamento MB', 1, NULL, 1, 1),
	(42, 1, 1, 'Obras Casa - Novo Materiais Casa Chamusca', 'Obras Casa', 1, NULL, 1, NULL),
	(43, 1, 1, 'Prendas', 'Prendas', 1, NULL, 1, NULL),
	(44, 1, 1, 'Vestuário', 'Rubrica dedicada à compra de roupas', 1, NULL, 1, 0),
	(45, 1, 1, 'Inspecção Automóvel', 'Usado quando na inspeção de um veiculo', 1, NULL, 1, 1),
	(46, 1, 1, 'Serviços', 'Serviços que contrato e que podem ser variados...', 1, '2018-01-07 01:36:53', 1, 1),
	(47, 1, 1, 'Assinaturas', 'Vale quotas, assinaturas de serviços de televisao por exemplo.. Básicamente, assinaturas de serviços ou bens', 1, '2018-01-07 01:48:19', 1, 1),
	(48, 1, 1, 'Restaurantes', 'Despesas com refeições em restaurantes, bars, pubs, comestiveis fora de casa', 1, '2018-01-07 01:50:42', 1, 1),
	(49, 1, 1, 'Carro', 'Despesas com material para o Carro/Reparações - NOVO', 1, '2018-01-18 23:53:16', 1, 1),
	(50, 1, 1, 'Objectos Materiais', 'Objectos Materiais para usar em casa e aplicados a coisas da ???? casa', 1, '2018-01-25 22:55:55', 1, 5),
	(51, 1, 2, 'BitCoin', '[NOVO] - Movimentos associados a Créditos na conta da CGD de movimentos da BitCoin', 0, '2018-02-10 16:44:41', 1, 1),
	(52, 1, 1, 'Animal de Estimação', 'Despesas com animais de estimação (Saúde, material, licenças...)', 1, '2018-12-27 22:11:39', 1, NULL),
	(53, 1, 1, 'Alojamento WEB', 'Despesas relacionadas com alojamento web', 1, '2018-12-27 22:38:39', 1, NULL),
	(54, 1, 1, 'TV / INTERNET / TLM', 'Gastos relacionados com comunicações, televisao e internet', 1, '2019-05-17 00:01:00', 1, 9),
	(55, 1, 1, 'Electricidade', 'Despesas relacionadas com a electricidade da casa', 1, '2019-06-02 22:45:54', 1, 1),
	(56, 1, 1, 'Agua', 'Despesas de agua', 1, '2019-07-08 19:30:35', 1, 1),
	(57, 1, 1, 'Vinho', 'Quando faço compras só de vinho', 1, '2020-04-25 14:06:55', 1, 1);

-- A despejar estrutura para tabela pars.wallet_payment_type
CREATE TABLE IF NOT EXISTS `wallet_payment_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_id` int(11) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_wPaymentType_userId_user_id` (`created_by`),
  KEY `FK_wPaymentType_walletId_wWallet_id` (`wallet_id`),
  CONSTRAINT `FK_wPaymentType_userId_user_id` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tipos de pagamento que um movimento de carteira pode assumir.';

-- A despejar dados para tabela pars.wallet_payment_type: ~7 rows (aproximadamente)
INSERT INTO `wallet_payment_type` (`id`, `wallet_id`, `description`, `is_active`, `created_at`, `created_by`, `order`) VALUES
	(1, 1, 'Dinheiro', 1, NULL, 1, NULL),
	(2, 1, 'Multibanco', 1, NULL, 1, NULL),
	(3, 1, 'Levantamento', 1, NULL, 1, NULL),
	(4, 1, 'Online', 1, NULL, 1, NULL),
	(5, 1, 'Cartão Ticket', 1, NULL, 1, NULL),
	(6, 1, 'MBWAY', 1, '2018-09-24 20:28:16', 1, 1),
	(7, 1, 'Revolut', 1, '2020-02-10 15:43:06', 1, 3);

-- A despejar estrutura para vista pars.creditvsdebtbyweekfromdate
-- A remover tabela temporária e a criar estrutura VIEW final
DROP TABLE IF EXISTS `creditvsdebtbyweekfromdate`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `creditvsdebtbyweekfromdate` AS select week(`a`.`data_movimento`,0) AS `semana`,year(`a`.`data_movimento`) AS `ano`,concat(dayofmonth((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' to ',concat(dayofmonth((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)))) AS `weekDates`,sum(`a`.`credito`) AS `credito`,sum(`a`.`debito`) AS `debito` from `account_movement` `a` where (`a`.`data_movimento` >= ('2023-10-21' - interval 2 year)) group by `semana`,`ano`,week(`a`.`data_movimento`,0),concat(dayofmonth((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' to ',concat(dayofmonth((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)))) order by `ano`,`semana`,`weekDates`;

-- A despejar estrutura para vista pars.getlast13weeksexpenses
-- A remover tabela temporária e a criar estrutura VIEW final
DROP TABLE IF EXISTS `getlast13weeksexpenses`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `getlast13weeksexpenses` AS select week(`a`.`data_movimento`,0) AS `semana`,concat(dayofmonth((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' to ',concat(dayofmonth((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)))) AS `weekDates`,sum(`a`.`credito`) AS `credito`,sum(`a`.`debito`) AS `debito` from `account_movement` `a` where (`a`.`data_movimento` >= ('2022-12-31' - interval 12 week)) group by `semana`,week(`a`.`data_movimento`,0),concat(dayofmonth((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (1 - dayofweek(`a`.`data_movimento`)) day)),' to ',concat(dayofmonth((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)),' ',monthname((`a`.`data_movimento` + interval (7 - dayofweek(`a`.`data_movimento`)) day)))) order by `semana` limit 13;

-- A despejar estrutura para vista pars.getmonthexpensesbyyear
-- A remover tabela temporária e a criar estrutura VIEW final
DROP TABLE IF EXISTS `getmonthexpensesbyyear`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `getmonthexpensesbyyear` AS select left(monthname(`a`.`data_movimento`),3) AS `month`,sum(`a`.`credito`) AS `credito`,sum(`a`.`debito`) AS `debito` from `account_movement` `a` where (year(`a`.`data_movimento`) = 2022) group by month(`a`.`data_movimento`),left(monthname(`a`.`data_movimento`),3);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
