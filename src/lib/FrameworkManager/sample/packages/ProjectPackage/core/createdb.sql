-- MySQL --
CREATE DATABASE IF NOT EXISTS `project` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON `project`.* TO 'projectuser'@'localhost' IDENTIFIED BY 'projectpass'; 
