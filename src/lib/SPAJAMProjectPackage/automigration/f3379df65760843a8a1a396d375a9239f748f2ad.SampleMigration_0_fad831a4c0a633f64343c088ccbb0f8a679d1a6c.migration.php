<?php

class SampleMigration_0_fad831a4c0a633f64343c088ccbb0f8a679d1a6c extends MigrationBase {

	public $migrationIdx = "0";

	public $tableName = "sample";
	public $tableComment = "サンプルテーブル";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "fad831a4c0a633f64343c088ccbb0f8a679d1a6c";

	public function __construct(){
		$this->describes = array();
		$this->describes["id"] = array();
		$this->describes["id"]["type"] = "int";
		$this->describes["id"]["null"] = FALSE;
		$this->describes["id"]["pkey"] = TRUE;
		$this->describes["id"]["length"] = "11";
		$this->describes["id"]["min-length"] = 1;
		$this->describes["id"]["autoincrement"] = TRUE;
		$this->describes["id"]["comment"] = "pkey";
		$this->describes["name"] = array();
		$this->describes["name"]["type"] = "string";
		$this->describes["name"]["null"] = TRUE;
		$this->describes["name"]["pkey"] = FALSE;
		$this->describes["name"]["length"] = "128";
		$this->describes["name"]["min-length"] = 1;
		$this->describes["name"]["autoincrement"] = FALSE;
		$this->describes["name"]["comment"] = "レコード名";
		$this->describes["owner_id"] = array();
		$this->describes["owner_id"]["type"] = "int";
		$this->describes["owner_id"]["null"] = FALSE;
		$this->describes["owner_id"]["pkey"] = FALSE;
		$this->describes["owner_id"]["length"] = "11";
		$this->describes["owner_id"]["min-length"] = 1;
		$this->describes["owner_id"]["autoincrement"] = FALSE;
		$this->describes["owner_id"]["comment"] = "レコードオーナー(userテーブルのPkey)";
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