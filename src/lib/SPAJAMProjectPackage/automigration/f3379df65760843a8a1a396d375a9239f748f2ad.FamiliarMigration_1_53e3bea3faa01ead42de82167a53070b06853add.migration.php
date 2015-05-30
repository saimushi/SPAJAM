<?php

class FamiliarMigration_1_53e3bea3faa01ead42de82167a53070b06853add extends MigrationBase {

	public $migrationIdx = "1";

	public $tableName = "familiar";
	public $tableComment = "ファミリア";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "53e3bea3faa01ead42de82167a53070b06853add";

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
		$this->describes["name"]["comment"] = "名前";
		$this->describes["info"] = array();
		$this->describes["info"]["type"] = "text";
		$this->describes["info"]["null"] = TRUE;
		$this->describes["info"]["pkey"] = FALSE;
		$this->describes["info"]["length"] = "65535";
		$this->describes["info"]["min-length"] = 1;
		$this->describes["info"]["autoincrement"] = FALSE;
		$this->describes["info"]["comment"] = "概要";
		$this->describes["god_id"] = array();
		$this->describes["god_id"]["type"] = "int";
		$this->describes["god_id"]["null"] = TRUE;
		$this->describes["god_id"]["pkey"] = FALSE;
		$this->describes["god_id"]["length"] = "11";
		$this->describes["god_id"]["min-length"] = 1;
		$this->describes["god_id"]["autoincrement"] = FALSE;
		$this->describes["god_id"]["comment"] = "ネ申ID(userテーブルのPkey)";
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
		$alter["familiar_count"]["after"] = "god_id";
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