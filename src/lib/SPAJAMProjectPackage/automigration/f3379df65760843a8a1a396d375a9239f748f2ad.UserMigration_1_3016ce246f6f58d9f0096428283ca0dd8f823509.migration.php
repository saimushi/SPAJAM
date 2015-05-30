<?php

class UserMigration_1_3016ce246f6f58d9f0096428283ca0dd8f823509 extends MigrationBase {

	public $migrationIdx = "1";

	public $tableName = "user";
	public $tableComment = "ユーザーテーブル";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "3016ce246f6f58d9f0096428283ca0dd8f823509";

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
		$this->describes["familiar_count"] = array();
		$this->describes["familiar_count"]["type"] = "int";
		$this->describes["familiar_count"]["null"] = FALSE;
		$this->describes["familiar_count"]["pkey"] = FALSE;
		$this->describes["familiar_count"]["length"] = "5";
		$this->describes["familiar_count"]["min-length"] = 1;
		$this->describes["familiar_count"]["autoincrement"] = FALSE;
		$this->describes["familiar_count"]["comment"] = "ファミリアの所属人数";
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
		$alter = array();
		$alter["familiar_count"] = array();
		$alter["familiar_count"]["type"] = "int";
		$alter["familiar_count"]["null"] = FALSE;
		$alter["familiar_count"]["pkey"] = FALSE;
		$alter["familiar_count"]["length"] = "5";
		$alter["familiar_count"]["min-length"] = 1;
		$alter["familiar_count"]["autoincrement"] = FALSE;
		$alter["familiar_count"]["comment"] = "ファミリアの所属人数";
		$alter["familiar_count"]["alter"] = "ADD";
		$alter["familiar_count"]["after"] = "uniq_name";
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}

	public function down($argDBO){
		$alter = array();
		$alter["familiar_count"] = array();
		$alter["familiar_count"]["alter"] = "DROP";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}
}

?>