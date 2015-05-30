<?php

class SessiondataMigration_1_23930f1238cca214ef1b42b08ef528d563e9267f extends MigrationBase {

	public $migrationIdx = "1";

	public $tableName = "sessiondata";
	public $tableComment = "";
	public $tableEngine = "MyISAM";

	public static $migrationHash = "23930f1238cca214ef1b42b08ef528d563e9267f";

	public function __construct(){
		$this->describes = array();
		$this->describes["identifier"] = array();
		$this->describes["identifier"]["type"] = "string";
		$this->describes["identifier"]["null"] = FALSE;
		$this->describes["identifier"]["pkey"] = TRUE;
		$this->describes["identifier"]["length"] = "96";
		$this->describes["identifier"]["min-length"] = 1;
		$this->describes["identifier"]["autoincrement"] = FALSE;
		$this->describes["identifier"]["comment"] = "deviceテーブルのPkey";
		$this->describes["data"] = array();
		$this->describes["data"]["type"] = "text";
		$this->describes["data"]["null"] = TRUE;
		$this->describes["data"]["pkey"] = FALSE;
		$this->describes["data"]["length"] = "65535";
		$this->describes["data"]["min-length"] = 1;
		$this->describes["data"]["autoincrement"] = FALSE;
		$this->describes["data"]["comment"] = "jsonシリアライズされたセッションデータ";
		$this->describes["modified"] = array();
		$this->describes["modified"]["type"] = "date";
		$this->describes["modified"]["null"] = FALSE;
		$this->describes["modified"]["pkey"] = FALSE;
		$this->describes["modified"]["min-length"] = 1;
		$this->describes["modified"]["autoincrement"] = FALSE;
		$this->describes["modified"]["comment"] = "変更日時";
		
		return;
	}

	public function up($argDBO){
		$alter = array();
		$alter["__Comment__"]["alter"] = "MODIFY";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}

	public function down($argDBO){
		$alter = array();
		$alter["__Comment__"]["before"] = "セッションデータテーブル";
		$alter["__Comment__"]["alter"] = "MODIFY";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}
}

?>