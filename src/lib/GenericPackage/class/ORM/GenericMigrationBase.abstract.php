<?php

abstract class GenericMigrationBase {

	public static $migrationHash = '';
	public $tableName = '';
	public $describes = array();
	public $indexes = array();

	private function _getFieldPropatyQuery($argDescribe){
		// create文を生成する
		$fieldDef = '';
		$pkeyDef = '';
		// XXX まだMySQLにしか対応してません！ゴメンナサイ！！
		foreach($argDescribe as $field => $propaty){
			if(strlen($fieldDef) > 0){
				// 2行目以降は頭に「,」付ける
				$fieldDef .= ', ';
			}
			$fieldDef .= '`' . $field . '`';
			if('string' === $propaty['type'] && isset($propaty['min-length'])){
				$fieldDef .= ' VARCHAR(' . $propaty['length'] . ')';
			}
			elseif('string' === $propaty['type']){
				$fieldDef .= ' CHAR(' . $propaty['length'] . ')';
			}
			elseif('int' === $propaty['type']){
				if(FALSE !== strpos($propaty['length'], ',')){
					// 小数点が在る場合
					$fieldDef .= ' DECIMAL(' . $propaty['length'] . ')';
				}
				else{
					$fieldDef .= ' INT(' . $propaty['length'] . ')';
				}
			}
			elseif('date' === $propaty['type']){
				$fieldDef .= ' DATETIME';
			}
			else {
				$fieldDef .= ' '.$propaty['type'];
			}
			if(FALSE === $propaty['null']){
				$fieldDef .= ' NOT NULL';
			}
			if(isset($propaty['default'])){
				$default = '\'' . $propaty['default'] . '\'';
				if('FALSE' === $default){
					$default = '\'0\'';
				}
				elseif('TRUE' === $default) {
					$default = '\'1\'';
				}
				elseif('NULL' === $default) {
					$default = 'NULL';
				}
				$fieldDef .= ' DEFAULT ' . $default;
			}
			if(isset($propaty['autoincrement']) && TRUE === $propaty['autoincrement']){
				$fieldDef .= ' AUTO_INCREMENT';
			}
			if(isset($propaty['comment'])){
				$fieldDef .= ' COMMENT \''. $propaty['comment'] .'\' ';
			}
			if(isset($propaty['pkey']) && TRUE === $propaty['pkey']){
				$pkeyDef .= ', PRIMARY KEY(`' . $field . '`)';
			}
		}
		if(FALSE !== strpos($pkeyDef, '), PRIMARY KEY(')){
			// 複合主キーが設定されていたらそれに従う
			$pkeyDef = str_replace('), PRIMARY KEY(', ',', $pkeyDef);
		}
		return array('fieldDef'=>$fieldDef, 'pkeyDef'=>$pkeyDef);
	}

	private function _getIndexQueries($argIndex){
		$indexQueries = array();
		if(NULL !== $argIndex && is_array($argIndex) && 0 < count($argIndex)){
			foreach($argIndex as $keyname => $propaty){
				if(isset($propaty['alter']) && TRUE === ('MODIFY' === strtoupper($propaty['alter']) || 'DROP' === strtoupper($propaty['alter']))){
					$indexQueries[] = 'DROP INDEX `' . $keyname . '` ON `' . $this->tableName . '`';
				}
				if(TRUE !== (isset($propaty['alter']) && 'DROP' === strtoupper($propaty['alter']))){
					$unique = '';
					if (isset($propaty['Unique']) && 1 === (int)$propaty['Unique']) {
						$unique = 'UNIQUE ';
					}
					$sql = 'CREATE '.$unique.'INDEX `' . $keyname . '` ON `' . $this->tableName . '`(';
					for ($colIdx=0; $colIdx < count($propaty["Colums"]); $colIdx++){
						if (0 < $colIdx){
							$sql .= ', ';
						}
						$sql .= '`' . $propaty['Colums'][$colIdx] . '`';
					}
					$sql .= ') ';
					if(isset($propaty['Index_comment']) && 0 < strlen($propaty['Index_comment'])){
						$sql .= ' COMMENT \'' . $propaty['Index_comment'] . '\'';
					}
					$indexQueries[] = $sql;
				}
			}
		}
		return $indexQueries;
	}

	/**
	 * createのマイグレーションを適用する
	 * @param instance $argDBO
	 * @return boolean
	 */
	public function create($argDBO){
		$sql = '';
		$fielPropatyQueries = $this->_getFieldPropatyQuery($this->describes);
		$pkeyDef = $fielPropatyQueries['pkeyDef'];
		$fieldDef = $fielPropatyQueries['fieldDef'];
		if(strlen($fieldDef) > 0){
			$sql = 'CREATE TABLE IF NOT EXISTS `' . $this->tableName . '` (' . $fieldDef . $pkeyDef . ')';
			if(isset($this->tableEngine) && 0 < strlen($this->tableEngine)){
				$sql .= ' ENGINE='.$this->tableEngine;
			}
			if(isset($this->tableComment)){
				$sql .= ' COMMENT \''.$this->tableComment.'\'';
			}
			debug('migration create sql='.$sql);
			$argDBO->execute($sql);
			$argDBO->commit();
		}
		// インデックスを適用
		$indexQueries = $this->_getIndexQueries($this->indexes);
		for($idx=0; $idx < count($indexQueries); $idx++){
			$argDBO->execute($indexQueries[$idx]);
		}
		if(0 < $idx){
			$argDBO->commit();
		}
		return TRUE;
	}

	/**
	 * dropのマイグレーションを適用する
	 * @param instance $argDBO
	 * @return boolean
	 */
	public function drop($argDBO){
		$sql = 'DROP TABLE `' . $this->tableName . '`';
		$argDBO->execute($sql);
		$argDBO->commit();
		return TRUE;
	}

	/**
	 * alterのマイグレーションを適用する
	 * @param instance $argDBO
	 * @return boolean
	 */
	public function alter($argDBO, $argDescribes, $argIndex=NULL){
		$executed = FALSE;
		// ALTERは一行づつ処理
		foreach($argDescribes as $field => $propaty){
			$sql = '';
			if('__Comment__' === $field){
				$comment = $this->tableComment;
				if(isset($propaty['before'])){
					$comment = $propaty['before'];
				}
				$sql = 'ALTER TABLE `' . $this->tableName . '` Comment \'' . $comment . '\'';
			}
			elseif('__Engine__' === $field){
				$engine = $this->tableEngine;
				if(isset($propaty['before'])){
					$engine = $propaty['before'];
				}
				$sql = 'ALTER TABLE `' . $this->tableName . '` Engine ' . $engine;
			}
			elseif('DROP' === $propaty['alter']){
				$sql = 'ALTER TABLE `' . $this->tableName . '` DROP COLUMN `' . $field . '`';
			}
			elseif('RENAME' === $propaty['alter'] && isset($propaty['before'])){
				$sql = 'ALTER TABLE `' . $this->tableName . '` RENAME COLUMN `' . $field . '` TO `' . $propaty['before'] .'`';
			}
			else{
				$fielPropatyQueries = $this->_getFieldPropatyQuery(array($field => $propaty));
				$fieldDef = $fielPropatyQueries['fieldDef'];
				if(strlen($fieldDef) > 0){
					$sql = 'ALTER TABLE `' . $this->tableName . '` ' . $propaty['alter'] . ' COLUMN ' . $fieldDef;
					if(isset($propaty['first']) && TRUE === $propaty['first']){
						$sql .= ' FIRST ';
					}
					else if(isset($propaty['after']) && 0 < strlen($propaty['after'])){
						$sql .= ' AFTER `'.$propaty['after'].'`';
					}
				}
				// XXX プライマリーキーのALTERがねぇ！！！？ ・・・後で追加しますorz
			}
			if(strlen($sql) > 0){
				try {
					debug('migration alter sql='.$sql);
					$argDBO->execute($sql);
				}
				catch (Exception $Exception){
					// 一応失敗した事は取っておく
					logging($Exception->getMessage(), 'exception');
					// ALTERのADDは、2重実行でエラーになるので、ここでのExceptionは無視してModfyを実行してみる
					//$sql = str_replace('ALTER TABLE `' . $this->tableName . '` ' . $propaty['alter'] . ' COLUMN ', 'ALTER TABLE `' . $this->tableName . '` MODIFY COLUMN ', $sql);
					// MODIFYに変えて実行しなおし
					//$argDBO->execute($sql);
				}
				$executed = TRUE;
			}
		}
		// インデックスを適用
		$indexQueries = $this->_getIndexQueries($argIndex);
		for($idx=0; $idx < count($indexQueries); $idx++){
			try {
				debug('migration alter index='.$indexQueries[$idx]);
				$argDBO->execute($indexQueries[$idx]);
			}
			catch (Exception $Exception){
				// 一応失敗した事は取っておく
				logging($Exception->getMessage(), 'exception');
			}
			$executed = TRUE;
		}
		if(TRUE === $executed){
			$argDBO->commit();
		}
		return TRUE;
	}
}

?>