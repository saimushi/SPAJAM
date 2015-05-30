<?php

class ActivityMigration_1_57b9ba3fd3136d5402d81df56ee61c907cbfac23 extends MigrationBase {

	public $migrationIdx = "1";

	public $tableName = "activity";
	public $tableComment = "やったこと一覧";
	public $tableEngine = "InnoDB";

	public static $migrationHash = "57b9ba3fd3136d5402d81df56ee61c907cbfac23";

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
		$this->describes["log"] = array();
		$this->describes["log"]["type"] = "text";
		$this->describes["log"]["null"] = TRUE;
		$this->describes["log"]["pkey"] = FALSE;
		$this->describes["log"]["length"] = "65535";
		$this->describes["log"]["min-length"] = 1;
		$this->describes["log"]["autoincrement"] = FALSE;
		$this->describes["log"]["comment"] = "やった事";
		$this->describes["user_id"] = array();
		$this->describes["user_id"]["type"] = "int";
		$this->describes["user_id"]["null"] = FALSE;
		$this->describes["user_id"]["pkey"] = FALSE;
		$this->describes["user_id"]["length"] = "11";
		$this->describes["user_id"]["min-length"] = 1;
		$this->describes["user_id"]["autoincrement"] = FALSE;
		$this->describes["user_id"]["comment"] = "レコードオーナー(userテーブルのPkey)";
		$this->describes["time"] = array();
		$this->describes["time"]["type"] = "int";
		$this->describes["time"]["default"] = 1;
		$this->describes["time"]["null"] = FALSE;
		$this->describes["time"]["pkey"] = FALSE;
		$this->describes["time"]["length"] = "2";
		$this->describes["time"]["min-length"] = 1;
		$this->describes["time"]["autoincrement"] = FALSE;
		$this->describes["time"]["comment"] = "作業時間";
		$this->describes["good"] = array();
		$this->describes["good"]["type"] = "string";
		$this->describes["good"]["default"] = "0";
		$this->describes["good"]["null"] = FALSE;
		$this->describes["good"]["pkey"] = FALSE;
		$this->describes["good"]["length"] = "1";
		$this->describes["good"]["autoincrement"] = FALSE;
		$this->describes["good"]["comment"] = "Good";
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
		$alter["time"] = array();
		$alter["time"]["type"] = "int";
		$alter["time"]["default"] = 1;
		$alter["time"]["null"] = FALSE;
		$alter["time"]["pkey"] = FALSE;
		$alter["time"]["length"] = "2";
		$alter["time"]["min-length"] = 1;
		$alter["time"]["autoincrement"] = FALSE;
		$alter["time"]["comment"] = "作業時間";
		$alter["time"]["alter"] = "ADD";
		$alter["time"]["after"] = "user_id";
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}

	public function down($argDBO){
		$alter = array();
		$alter["time"] = array();
		$alter["time"]["alter"] = "DROP";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}
}

?>