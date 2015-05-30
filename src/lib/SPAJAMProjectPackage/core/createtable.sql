-- MySQL --
-- Session --
CREATE TABLE IF NOT EXISTS `session` (`token` VARCHAR(255) NOT NULL COMMENT 'ワンタイムトークン', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'トークン作成日時', PRIMARY KEY(`token`)) ENGINE = MYISAM COMMENT='セッションテーブル';
CREATE TABLE IF NOT EXISTS `sessiondata` (`identifier` VARCHAR(96) NOT NULL COMMENT 'deviceテーブルのPkey', `data` TEXT DEFAULT NULL COMMENT 'jsonシリアライズされたセッションデータ', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '変更日時', PRIMARY KEY(`identifier`)) ENGINE = MYISAM COMMENT='セッションデータテーブル';
-- User --
CREATE TABLE IF NOT EXISTS `device` (`udid` CHAR(36) NOT NULL COMMENT 'udid(pkey)', `owner_id` int(11) NOT NULL DEFAULT 0 COMMENT 'レコードオーナー(userテーブルのPkey)', `type` VARCHAR(10) NOT NULL DEFAULT 'PC' COMMENT 'デバイスタイプ(PC,iPhone,Android...)', `version_name` VARCHAR(10) COMMENT '表示バージョン', `version_code` VARCHAR(10) COMMENT '内部バージョン', `device_token` CHAR(255) DEFAULT NULL COMMENT 'デバイストークン', `sandbox_enabled` char(1) NOT NULL DEFAULT '0' COMMENT 'iOS SANDBOX環境APNS用フラグ', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '作成日時', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新日時', `available` CHAR(1) NOT NULL DEFAULT '1' COMMENT 'レコード有効状態(0:無効 1:有効)', PRIMARY KEY(`udid`)) ENGINE=InnoDB COMMENT='デバイステーブル';
CREATE TABLE IF NOT EXISTS `user` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'pkey', `name` VARCHAR(128) DEFAULT NULL COMMENT 'ユーザー名称(ユーザー名)', `uniq_name` VARCHAR(128) DEFAULT NULL COMMENT 'user名(ユーザーID)', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '作成日時', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新日時', `available` CHAR(1) NOT NULL DEFAULT '1' COMMENT 'レコード有効状態(0:無効 1:有効)', PRIMARY KEY(`id`)) ENGINE=InnoDB COMMENT='ユーザーテーブル';
-- admin operator --
CREATE TABLE IF NOT EXISTS `operator` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'pkey', `name` varchar(1024) NOT NULL COMMENT 'オペレーター名', `mail` varchar(1024) NOT NULL COMMENT 'メールアドレス', `pass` varchar(64) NOT NULL COMMENT 'パスワード(SHA256)', `permission` char(1) NOT NULL DEFAULT '9' COMMENT 'アクセス権限(0:管理者)', PRIMARY KEY (`id`)) ENGINE=InnoDB COMMENT='管理ツールオペレーター管理';

-- Sample --
CREATE TABLE IF NOT EXISTS `sample` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'pkey', `name` VARCHAR(128) DEFAULT NULL COMMENT 'レコード名', `owner_id` int(11) NOT NULL COMMENT 'レコードオーナー(userテーブルのPkey)', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '作成日時', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新日時', `available` CHAR(1) NOT NULL DEFAULT '1' COMMENT 'レコード有効状態(0:無効 1:有効)', PRIMARY KEY(`id`)) ENGINE=InnoDB COMMENT='サンプルテーブル';
INSERT INTO `sample` (`name`, `owner_id`, `created`, `modified`) VALUES ('テスト', 1, '2015-05-25 10:12:34', '2015-05-26 11:23:45');
INSERT INTO `sample` (`name`, `owner_id`, `created`, `modified`) VALUES ('SPAJAM', 1, '2015-05-29 10:12:34', '2015-05-29 11:23:45');

-- SPAJAM --
CREATE TABLE IF NOT EXISTS `activity` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'pkey', `log` text DEFAULT NULL COMMENT 'やった事', `user_id` int(11) NOT NULL COMMENT 'レコードオーナー(userテーブルのPkey)', `good` char(1) NOT NULL DEFAULT '0' COMMENT 'Good', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '作成日時', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新日時', `available` CHAR(1) NOT NULL DEFAULT '1' COMMENT 'レコード有効状態(0:無効 1:有効)', PRIMARY KEY(`id`)) ENGINE=InnoDB COMMENT='やったこと一覧';
CREATE TABLE IF NOT EXISTS `familiar` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'pkey', `name` varchar(128) DEFAULT NULL COMMENT '名前', `info` text DEFAULT NULL COMMENT '概要', `god_id` int(11) DEFAULT NULL COMMENT 'ネ申ID(userテーブルのPkey)', `created` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '作成日時', `modified` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新日時', `available` CHAR(1) NOT NULL DEFAULT '1' COMMENT 'レコード有効状態(0:無効 1:有効)', PRIMARY KEY(`id`)) ENGINE=InnoDB COMMENT='ファミリア';
