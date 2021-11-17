CREATE TABLE `purchases` (
	`id` INT(10) NOT NULL AUTO_INCREMENT,
	`date` DATE NOT NULL,
	`number` INT(10) NOT NULL DEFAULT '0',
	`qty` INT(10) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE
)
ENGINE=InnoDB;


INSERT INTO `purchases` (`id`, `date`, `number`, `qty`) VALUES 
(1, '2018-10-07', 200, 5),
(2, '2018-12-01', 300, 10),
(3, '2019-02-03', 700, 12),
(4, '2019-03-07', 1000, 15);