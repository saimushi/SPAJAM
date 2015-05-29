<?php

class SessionMigration_0_0905edb90e44fc7b9dd3f568a51747bf0f3e8ad6 extends MigrationBase {

	public $migrationIdx = "0";

	public $tableName = "session";
	public $tableComment = "セッションテーブル";
	public $tableEngine = "MyISAM";

	public static $migrationHash = "0905edb90e44fc7b9dd3f568a51747bf0f3e8ad6";

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
		return $this->create($argDBO);
	}

	public function down($argDBO){
		return $this->drop($argDBO);
	}
}

?>