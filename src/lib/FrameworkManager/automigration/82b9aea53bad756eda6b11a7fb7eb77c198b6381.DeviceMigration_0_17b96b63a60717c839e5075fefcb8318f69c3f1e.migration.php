<?php

class DeviceMigration_0_17b96b63a60717c839e5075fefcb8318f69c3f1e extends MigrationBase {

	public $migrationIdx = "0";

	public $tableName = "device";
	public $tableComment = "デバイステーブル";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "17b96b63a60717c839e5075fefcb8318f69c3f1e";

	public function __construct(){
		$this->describes = array();
		$this->describes["udid"] = array();
		$this->describes["udid"]["type"] = "string";
		$this->describes["udid"]["null"] = FALSE;
		$this->describes["udid"]["pkey"] = TRUE;
		$this->describes["udid"]["length"] = "36";
		$this->describes["udid"]["autoincrement"] = FALSE;
		$this->describes["udid"]["comment"] = "udid(pkey)";
		$this->describes["owner_id"] = array();
		$this->describes["owner_id"]["type"] = "int";
		$this->describes["owner_id"]["default"] = 0;
		$this->describes["owner_id"]["null"] = FALSE;
		$this->describes["owner_id"]["pkey"] = FALSE;
		$this->describes["owner_id"]["length"] = "11";
		$this->describes["owner_id"]["min-length"] = 1;
		$this->describes["owner_id"]["autoincrement"] = FALSE;
		$this->describes["owner_id"]["comment"] = "レコードオーナー(userテーブルのPkey)";
		$this->describes["type"] = array();
		$this->describes["type"]["type"] = "string";
		$this->describes["type"]["default"] = "PC";
		$this->describes["type"]["null"] = FALSE;
		$this->describes["type"]["pkey"] = FALSE;
		$this->describes["type"]["length"] = "10";
		$this->describes["type"]["min-length"] = 1;
		$this->describes["type"]["autoincrement"] = FALSE;
		$this->describes["type"]["comment"] = "デバイスタイプ(PC,iPhone,Android...)";
		$this->describes["version_name"] = array();
		$this->describes["version_name"]["type"] = "string";
		$this->describes["version_name"]["null"] = TRUE;
		$this->describes["version_name"]["pkey"] = FALSE;
		$this->describes["version_name"]["length"] = "10";
		$this->describes["version_name"]["min-length"] = 1;
		$this->describes["version_name"]["autoincrement"] = FALSE;
		$this->describes["version_name"]["comment"] = "表示バージョン";
		$this->describes["version_code"] = array();
		$this->describes["version_code"]["type"] = "string";
		$this->describes["version_code"]["null"] = TRUE;
		$this->describes["version_code"]["pkey"] = FALSE;
		$this->describes["version_code"]["length"] = "10";
		$this->describes["version_code"]["min-length"] = 1;
		$this->describes["version_code"]["autoincrement"] = FALSE;
		$this->describes["version_code"]["comment"] = "内部バージョン";
		$this->describes["device_token"] = array();
		$this->describes["device_token"]["type"] = "string";
		$this->describes["device_token"]["null"] = TRUE;
		$this->describes["device_token"]["pkey"] = FALSE;
		$this->describes["device_token"]["length"] = "255";
		$this->describes["device_token"]["autoincrement"] = FALSE;
		$this->describes["device_token"]["comment"] = "デバイストークン";
		$this->describes["sandbox_enabled"] = array();
		$this->describes["sandbox_enabled"]["type"] = "string";
		$this->describes["sandbox_enabled"]["default"] = "0";
		$this->describes["sandbox_enabled"]["null"] = FALSE;
		$this->describes["sandbox_enabled"]["pkey"] = FALSE;
		$this->describes["sandbox_enabled"]["length"] = "1";
		$this->describes["sandbox_enabled"]["autoincrement"] = FALSE;
		$this->describes["sandbox_enabled"]["comment"] = "iOS SANDBOX環境APNS用フラグ";
		$this->describes["created"] = array();
		$this->describes["created"]["type"] = "date";
		$this->describes["created"]["null"] = FALSE;
		$this->describes["created"]["pkey"] = FALSE;
		$this->describes["created"]["min-length"] = 1;
		$this->describes["created"]["autoincrement"] = FALSE;
		$this->describes["created"]["comment"] = "作成日時";
		$this->describes["modified"] = array();
		$this->describes["modified"]["type"] = "date";
		$this->describes["modified"]["null"] = FALSE;
		$this->describes["modified"]["pkey"] = FALSE;
		$this->describes["modified"]["min-length"] = 1;
		$this->describes["modified"]["autoincrement"] = FALSE;
		$this->describes["modified"]["comment"] = "更新日時";
		$this->describes["available"] = array();
		$this->describes["available"]["type"] = "string";
		$this->describes["available"]["default"] = "1";
		$this->describes["available"]["null"] = FALSE;
		$this->describes["available"]["pkey"] = FALSE;
		$this->describes["available"]["length"] = "1";
		$this->describes["available"]["autoincrement"] = FALSE;
		$this->describes["available"]["comment"] = "レコード有効状態(0:無効 1:有効)";
		
		return;
	}

	public function up($argDBO){
		return $this->create($argDBO);
	}

	public function down($argDBO){
		return $this->drop($argDBO);
	}
}

?>