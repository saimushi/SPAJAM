<?php

/**
 * Sessionデータクラス(PECL:Memcache版(非PECL:Memcached))
 * @author saimushi
 */
abstract class SessionDataMemcache {

	protected static $_initialized = FALSE;
	protected static $_expiredtime = 3600;// 60分
	protected static $_sessionDataTblName = 'session_table';
	protected static $_sessionDataPKeyName = 'identifier';
	protected static $_serializeKeyName = 'data';
	protected static $_sessionDataDateKeyName = 'modify_date';
	protected static $_sessionData = NULL;
	protected static $_DSN = NULL;

	/**
	 * Sessionクラスの初期化
	 * @param string セッションの有効期限
	 * @param string DBDSN情報
	 */
	protected static function _init($argExpiredtime=NULL, $argDSN=NULL){
		if(FALSE === self::$_initialized){

			$DSN = NULL;
			$expiredtime = self::$_expiredtime;

			if(class_exists('Configure') && NULL !== Configure::constant('MEMCACHE_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::MEMCACHE_DSN;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('MC_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::MC_DSN;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_MEMCACHE_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::SESSION_MEMCACHE_DSN;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_MC_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::SESSION_MC_DSN;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_EXPIRED_TIME')){
				// 定義からセッションの有効期限を設定
				$expiredtime = Configure::SESSION_EXPIRED_TIME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_DATA_TBL_NAME')){
				// 定義からセッションデータテーブル名を特定
				self::$_sessionDataTblName = $ProjectConfigure::SESSION_DATA_TBL_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_DATA_TBL_PKEY_NAME')){
				// 定義からセッションデータテーブルのPKey名を特定
				self::$_sessionDataPKeyName = Configure::SESSION_DATA_TBL_PKEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SERIALIZE_KEY_NAME')){
				// 定義からシリアライズデータのフィールド名を特定
				self::$_serializeKeyName = Configure::SERIALIZE_KEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('SESSION_DATA_DATE_KEY_NAME')){
				// 定義から日時フィールド名を特定
				self::$_sessionDataDateKeyName = Configure::SESSION_DATA_DATE_KEY_NAME;
			}
			if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
				$ProjectConfigure = PROJECT_NAME . 'Configure';
				if(NULL !== $ProjectConfigure::constant('MEMCACHE_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::MEMCACHE_DSN;
				}
				if(NULL !== $ProjectConfigure::constant('MC_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::MC_DSN;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_MEMCACHE_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::SESSION_MEMCACHE_DSN;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_MC_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::SESSION_MC_DSN;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_EXPIRED_TIME')){
					// 定義からセッションの有効期限を設定
					$expiredtime = $ProjectConfigure::SESSION_EXPIRED_TIME;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_DATA_TBL_NAME')){
					// 定義からセッションデータテーブル名を特定
					self::$_sessionDataTblName = $ProjectConfigure::SESSION_DATA_TBL_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_DATA_TBL_PKEY_NAME')){
					// 定義からセッションデータテーブルのPKey名を特定
					self::$_sessionDataPKeyName = $ProjectConfigure::SESSION_DATA_TBL_PKEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('SERIALIZE_KEY_NAME')){
					// 定義からuserTable名を特定
					self::$_serializeKeyName = $ProjectConfigure::SERIALIZE_KEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('SESSION_DATA_DATE_KEY_NAME')){
					// 定義から日時フィールド名を特定
					self::$_sessionDataDateKeyName = $ProjectConfigure::SESSION_DATA_DATE_KEY_NAME;
				}
			}

			// memcacheのDSNを取っておく
			if(NULL === self::$_DSN){
				if(NULL !== $argDSN){
					// セッションmemcacheの接続情報を直指定
					$DSN = $argDSN;
				}
				self::$_DSN = $DSN;
			}

			// セッションの有効期限を設定
			if(NULL !== $argExpiredtime){
				// セッションの有効期限を直指定
				$expiredtime = $argExpiredtime;
			}
			self::$_expiredtime = $expiredtime;

			// 初期化済み
			self::$_initialized = TRUE;
		}
	}

	/**
	 * セッションデータデーブルからデータを取得し復元する
	 * @param string セッションデータのプライマリーキー
	 */
	protected static function _initializeData($argPKey){
		if(NULL === self::$_sessionData){
			$Session = MCO::get($argPKey, self::$_DSN);
			if (FALSE !== $Session && 0 < strlen($Session)){
				$Session = @unserialize($Session);
			}
			if(FALSE !== $Session && is_object($Session) && isset($Session->{self::$_sessionDataPKeyName}) && strlen($Session->{self::$_sessionDataPKeyName}) > 0){
				self::$_sessionData = json_decode($Session->{self::$_serializeKeyName}, TRUE);
			}
			else{
				// 配列に初期化
				self::$_sessionData = array();
			}
		}
		return TRUE;
	}

	/**
	 * セッションデータテーブルにデータをしまう
	 * @param string セッションデータのプライマリーキー
	 */
	protected static function _finalizeData($argPKey){
		if(is_array(self::$_sessionData) && count(self::$_sessionData) > 0){
			// XXX identifierが変えられたかもしれないので、もう一度セット
			$Session = new stdClass;
			$Session->{self::$_sessionDataPKeyName} = $argPKey;
			$Session->{self::$_serializeKeyName} = json_encode(self::$_sessionData);
			$Session->{self::$_sessionDataDateKeyName} = Utilities::date('Y-m-d H:i:s', NULL, NULL, 'GMT');
			// memcacheに保存
			debug('session!');
			try{
				debug('save???');
				if(FALSE === MCO::set($argPKey, @serialize($Session), FALSE, self::$_expiredtime, self::$_DSN)){
					throw new Exception('memcache session data save feild.');
				}
				debug('save!');
				// 正常終了
				return TRUE;
			}
			catch (exception $Exception){
				// XXX この場合は、並列プロセス(Ajaxの非同期プロセス等)が先にinsertを走らせた場合に発生する
				debug('throw msg='.$Exception->getMessage());
				debug('throw save?');
				$Session->save();
				debug('throw save!');
				// 正常終了
				return TRUE;
			}
			// XXX SESSIONExceptionクラスを実装予定
			logging(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__.PATH_SEPARATOR.self::$_DBO->getLastErrorMessage(), 'exception');
			return FALSE;
		}
		return TRUE;
	}

	/**
	 * セッションデータのキーの数を返す
	 */
	public static function count(){
		if(NULL !== self::$_sessionData){
			return count(self::$_sessionData);
		}
		return 0;
	}

	/**
	 * セッションデータのキーの一覧を返す
	 */
	public static function keys(){
		if(NULL !== self::$_sessionData){
			return array_keys(self::$_sessionData);
		}
		return array();
	}

	/**
	 * セッションデータの指定のキー名で保存されたデータを返す
	 * @param string セッションデータのプライマリーキー
	 * @param string キー名
	 * @param mixed 変数全て(PHPオブジェクトは保存出来ない！)
	 * @param int 有効期限の直指定
	 * @param mixed DBDSN情報の直指定
	 */
	public static function get($argPKey, $argKey = NULL, $argExpiredtime=NULL, $argDSN=NULL){
		if(FALSE === self::$_initialized){
			self::_init($argExpiredtime, $argDSN);
		}
		// データに実際にアクセスする時に、データの初期化は実行される
		if(NULL === self::$_sessionData){
			self::_initializeData($argPKey);
		}
		if(isset(self::$_sessionData[$argKey])){
			return self::$_sessionData[$argKey];
		}
		// 存在しないキーへのアクセスはNULL
		return NULL;
	}

	/**
	 * セッションデータに指定のキー名で指定のデータを追加する
	 * @param string セッションデータのプライマリーキー
	 * @param string キー名
	 * @param mixed 変数全て(PHPオブジェクトは保存出来ない！)
	 * @param int 有効期限の直指定
	 * @param mixed DBDSN情報の直指定
	 */
	public static function set($argPKey, $argKey, $argment, $argExpiredtime=NULL, $argDSN=NULL){
		if(FALSE === self::$_initialized){
			self::_init($argExpiredtime, $argDSN);
		}
		// データに実際にアクセスする時に、データの初期化は実行される
		if(NULL === self::$_sessionData){
			self::_initializeData($argPKey);
		}
		// 配列にデータを追加
		self::$_sessionData[$argKey] = $argment;
		// セッションデータレコードの更新
		if(FALSE === self::_finalizeData($argPKey)){
			// エラー
			throw new Exception(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__.PATH_SEPARATOR.Utilities::getBacktraceExceptionLine());
		}
		return TRUE;
	}

	/**
	 * セッションデータに指定のキー名の値を削除する
	 * @param string セッションデータのプライマリーキー
	 * @param string キー名
	 * @param mixed 変数全て(PHPオブジェクトは保存出来ない！)
	 * @param int 有効期限の直指定
	 * @param mixed DBDSN情報の直指定
	 */
	public static function remove($argPKey, $argKey, $argExpiredtime=NULL, $argDSN=NULL){
		if(FALSE === self::$_initialized){
			self::_init($argExpiredtime, $argDSN);
		}
		// データに実際にアクセスする時に、データの初期化は実行される
		if(NULL === self::$_sessionData){
			self::_initializeData($argPKey);
		}
		// 配列にデータから抹消
		unset(self::$_sessionData[$argKey]);
		// セッションデータレコードの更新
		if(FALSE === self::_finalizeData($argPKey)){
			// エラー
			throw new Exception(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__.PATH_SEPARATOR.Utilities::getBacktraceExceptionLine());
		}
		return TRUE;
	}

	/**
	 * identifierに紐づくセッションデータレコードをクリアする
	 * @param string セッションデータのプライマリーキー
	 * @param int 有効期限の直指定
	 * @param mixed DBDSN情報の直指定
	 */
	public static function clear($argPKey=NULL, $argExpiredtime=NULL, $argDSN=NULL){
		if(FALSE === self::$_initialized){
			self::_init($argExpiredtime, $argDSN);
		}
		// SESSIONレコードの削除
		@MCO::delete($argPKey, 0, self::$_DSN);
		return TRUE;
	}

	/**
	 * Expiredの切れたSessionレコードをDeleteする
	 * @param int 有効期限の直指定
	 * @param mixed DBDSN情報の直指定
	 */
	public static function clean($argExpiredtime=NULL, $argDSN=NULL){
		// XXX 何もしない
		return TRUE;
	}
}

?>