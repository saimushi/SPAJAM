-- MySQL --
-- Create DB --
CREATE DATABASE IF NOT EXISTS `fwm` CHARACTER SET utf8 COLLATE utf8_general_ci;
-- GRANT --
GRANT ALL ON `fwm`.* TO 'fwmuser'@'localhost' IDENTIFIED BY 'fwmpass'; 
