<?php

class SessionMigration_1_7992a13523aacc745f675559dd1cb3fa338241a0 extends MigrationBase {

	public $migrationIdx = "1";

	public $tableName = "session";
	public $tableComment = "";
	public $tableEngine = "MyISAM";

	public static $migrationHash = "7992a13523aacc745f675559dd1cb3fa338241a0";

	public function __construct(){
		$this->describes = array();
		$this->describes["token"] = array();
		$this->describes["token"]["type"] = "string";
		$this->describes["token"]["null"] = FALSE;
		$this->describes["token"]["pkey"] = TRUE;
		$this->describes["token"]["length"] = "255";
		$this->describes["token"]["min-length"] = 1;
		$this->describes["token"]["autoincrement"] = FALSE;
		$this->describes["token"]["comment"] = "ワンタイムトークン";
		$this->describes["created"] = array();
		$this->describes["created"]["type"] = "date";
		$this->describes["created"]["null"] = FALSE;
		$this->describes["created"]["pkey"] = FALSE;
		$this->describes["created"]["min-length"] = 1;
		$this->describes["created"]["autoincrement"] = FALSE;
		$this->describes["created"]["comment"] = "トークン作成日時";
		
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
		$alter["__Comment__"]["before"] = "セッションテーブル";
		$alter["__Comment__"]["alter"] = "MODIFY";
		
		$index = array();
		
		return $this->alter($argDBO, $alter, $index);
	}
}

?>