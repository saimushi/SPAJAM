<?php

class SessiondataMigration_0_38a5bfc2ddd9dbd75f8631f7a1d09fe5503faea9 extends MigrationBase {

	public $migrationIdx = "0";

	public $tableName = "sessiondata";
	public $tableComment = "セッションデータテーブル";
	public $tableEngine = "MyISAM";

	public static $migrationHash = "38a5bfc2ddd9dbd75f8631f7a1d09fe5503faea9";

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
		return $this->create($argDBO);
	}

	public function down($argDBO){
		return $this->drop($argDBO);
	}
}

?>