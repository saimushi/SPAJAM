<?php
/*
 * Generated configuration file
 * Generated by: phpMyAdmin 4.0.4 setup script
 * Date: Sun, 30 Jun 2013 12:37:28 +0000
 */

/* Servers configuration */
$i = 0;

/* Server: localhost [1] */
//$cfg['Servers'][$i]['AllowRoot'] = false;

// $i++;
// $cfg['Servers'][$i]['verbose'] = 'KANOKARE-DEVELOPMENT';
// $cfg['Servers'][$i]['host'] = '10.0.100.7';
// $cfg['Servers'][$i]['port'] = '';
// $cfg['Servers'][$i]['socket'] = '';
// $cfg['Servers'][$i]['connect_type'] = 'tcp';
// $cfg['Servers'][$i]['extension'] = 'mysqli';
// $cfg['Servers'][$i]['auth_type'] = 'cookie';
// $cfg['Servers'][$i]['user'] = '';
// $cfg['Servers'][$i]['password'] = '';

$i++;
$cfg['Servers'][$i]['verbose'] = 'KANOKARE-PRODUCTION';
$cfg['Servers'][$i]['host'] = 'kanokare-master.cqjv8bn42brd.ap-northeast-1.rds.amazonaws.com';
$cfg['Servers'][$i]['port'] = '';
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['user'] = '';
$cfg['Servers'][$i]['password'] = '';

$i++;
$cfg['Servers'][$i]['verbose'] = 'KANOKARE-DEVELOPMENT';
$cfg['Servers'][$i]['host'] = 'kanokare-testdb.cqjv8bn42brd.ap-northeast-1.rds.amazonaws.com';
$cfg['Servers'][$i]['port'] = '';
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['user'] = '';
$cfg['Servers'][$i]['password'] = '';

$i++;
$cfg['Servers'][$i]['verbose'] = 'KANOKARE-TOOL(このサーバー)';
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['port'] = '';
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['user'] = '';
$cfg['Servers'][$i]['password'] = '';

/* End of servers configuration */

$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
$cfg['LoginCookieValidity'] = 3600;
$cfg['blowfish_secret'] = '6dYSUnsAZXcSxKpJ';
//$cfg['ForceSSL'] = true;
$cfg['DefaultLang'] = 'ja';
$cfg['ServerDefault'] = 1;
$cfg['ShowPhpInfo'] = true;
$cfg['ShowDbStructureCreation'] = true;
$cfg['ShowDbStructureLastUpdate'] = true;
$cfg['ShowDbStructureLastCheck'] = true;
$cfg['HideStructureActions'] = false;

?>
