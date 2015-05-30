<?php

class UserMigration_3_8413217e71e1d0a5bf602907c4b23acf7c4b7010 extends MigrationBase {

	public $migrationIdx = "3";

	public $tableName = "user";
	public $tableComment = "ユーザーテーブル";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "8413217e71e1d0a5bf602907c4b23acf7c4b7010";

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
		$this->describes["familiar_id"] = array();
		$this->describes["familiar_id"]["type"] = "int";
		$this->describes["familiar_id"]["null"] = FALSE;
		$this->describes["familiar_id"]["pkey"] = FALSE;
		$this->describes["familiar_id"]["length"] = "11";
		$this->describes["familiar_id"]["min-length"] = 1;
		$this->describes["familiar_id"]["autoincrement"] = FALSE;
		$this->describes["familiar_id"]["comment"] = "";
		$this->describes["familiar_count"] = array();
		$this->describes["familiar_count"]["type"] = "int";
		$this->describes["familiar_count"]["null"] = FALSE;
		$this->describes["familiar_count"]["pkey"] = FALSE;
		$this->describes["familiar_count"]["length"] = "5";
		$this->describes["familiar_count"]["min-length"] = 1;
		$this->describes["familiar_count"]["autoincrement"] = FALSE;
		$this->describes["familiar_count"]["comment"] = "ファミリアの所属人数";
		$this->describes["exp"] = array();
		$this->describes["exp"]["type"] = "int";
		$this->describes["exp"]["null"] = FALSE;
		$this->describes["exp"]["pkey"] = FALSE;
		$this->describes["exp"]["length"] = "11";
		$this->describes["exp"]["min-length"] = 1;
		$this->describes["exp"]["autoincrement"] = FALSE;
		$this->describes["exp"]["comment"] = "";
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
		$alter["exp"] = array();
		$alter["exp"]["type"] = "int";
		$alter["exp"]["null"] = FALSE;
		$alter["exp"]["pkey"] = FALSE;
		$alter["exp"]["length"] = "11";
		$alter["exp"]["min-length"] = 1;
		$alter["exp"]["autoincrement"] = FALSE;
		$alter["exp"]["comment"] = "";
		$alter["exp"]["alter"] = "ADD";
		$alter["exp"]["after"] = "familiar_count";
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}

	public function down($argDBO){
		$alter = array();
		$alter["exp"] = array();
		$alter["exp"]["alter"] = "DROP";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}
}

?>