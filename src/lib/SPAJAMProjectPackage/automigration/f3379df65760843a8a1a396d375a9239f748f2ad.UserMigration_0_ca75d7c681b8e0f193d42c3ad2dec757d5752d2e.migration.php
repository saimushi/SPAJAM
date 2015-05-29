<?php

class UserMigration_0_ca75d7c681b8e0f193d42c3ad2dec757d5752d2e extends MigrationBase {

	public $migrationIdx = "0";

	public $tableName = "user";
	public $tableComment = "ユーザーテーブル";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "ca75d7c681b8e0f193d42c3ad2dec757d5752d2e";

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
		$this->describes["name"]["comment"] = "ユーザー名称(ユーザー名)";
		$this->describes["uniq_name"] = array();
		$this->describes["uniq_name"]["type"] = "string";
		$this->describes["uniq_name"]["null"] = TRUE;
		$this->describes["uniq_name"]["pkey"] = FALSE;
		$this->describes["uniq_name"]["length"] = "128";
		$this->describes["uniq_name"]["min-length"] = 1;
		$this->describes["uniq_name"]["autoincrement"] = FALSE;
		$this->describes["uniq_name"]["comment"] = "user名(ユーザーID)";
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