<?php

abstract class RestControllerBase extends APIControllerBase implements RestControllerIO {

	protected $_initialized = FALSE;
	public $requestMethod = 'GET';
	public $restResource = '';
	public $restResourceModel = '';
	public $restResourceListed = NULL;
	public $restResourceCreateDateKeyName = '';
	public $restResourceModifyDateKeyName = '';
	public $restResourceAvailableKeyName = '';
	public $restResourceUserTableName = NULL;
	public $restResourceRelaySuffix = '';
	public $restResourceRelayPrefix = '';
	public $AuthDevice = NULL;
	public $AuthUser = NULL;
	public $authUserID = NULL;
	public $authUserIDFieldName = NULL;
	public $authUserQuery = NULL;
	public $deepRESTMode = TRUE;
	public $rootREST = TRUE;
	public $virtualREST = FALSE;
	public $responceData = FALSE;
	public static $nowGMT = NULL;

	public function __construct(){
		if(NULL === self::$nowGMT){
			self::$nowGMT = Utilities::date('Y-m-d H:i:s', NULL, NULL, 'GMT');
		}
	}

	protected function _init(){
		if(FALSE === $this->_initialized){
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_OWNER_PKEY_NAME')){
				$this->authUserIDFieldName = Configure::REST_RESOURCE_OWNER_PKEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_CREATE_DATE_KEY_NAME')){
				$this->restResourceCreateDateKeyName = Configure::REST_RESOURCE_CREATE_DATE_KEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_MODIFY_DATE_KEY_NAME')){
				$this->restResourceModifyDateKeyName = Configure::REST_RESOURCE_MODIFY_DATE_KEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_AVAILABLE_KEY_NAME')){
				$this->restResourceAvailableKeyName = Configure::REST_RESOURCE_AVAILABLE_KEY_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_USER_TBL_NAME')){
				$this->restResourceUserTableName = Configure::REST_UIDAUTH_USER_TBL_NAME;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_RELAY_SUFFIX')){
				$this->restResourceRelaySuffix = Configure::REST_RESOURCE_RELAY_SUFFIX;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_RESOURCE_RELAY_PREFIX')){
				$this->restResourceRelayPrefix = Configure::REST_RESOURCE_RELAY_PREFIX;
			}
			elseif(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
				$ProjectConfigure = PROJECT_NAME . 'Configure';
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_OWNER_PKEY_NAME')){
					$this->authUserIDFieldName = $ProjectConfigure::REST_RESOURCE_OWNER_PKEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_CREATE_DATE_KEY_NAME')){
					$this->restResourceCreateDateKeyName = $ProjectConfigure::REST_RESOURCE_CREATE_DATE_KEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_MODIFY_DATE_KEY_NAME')){
					$this->restResourceModifyDateKeyName = $ProjectConfigure::REST_RESOURCE_MODIFY_DATE_KEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_AVAILABLE_KEY_NAME')){
					$this->restResourceAvailableKeyName = $ProjectConfigure::REST_RESOURCE_AVAILABLE_KEY_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_USER_TBL_NAME')){
					$this->restResourceUserTableName = $ProjectConfigure::REST_UIDAUTH_USER_TBL_NAME;
				}
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_RELAY_SUFFIX')){
					$this->restResourceRelaySuffix = $ProjectConfigure::REST_RESOURCE_RELAY_SUFFIX;
				}
				if(NULL !== $ProjectConfigure::constant('REST_RESOURCE_RELAY_PREFIX')){
					$this->restResourceRelayPrefix = $ProjectConfigure::REST_RESOURCE_RELAY_PREFIX;
				}
			}
			// オートavailableの強制OFF判定
			if(isset($_SERVER['_availalefilter_']) && TRUE == ('0' === $_SERVER['_availalefilter_'] || 'false' === strtolower($_SERVER['_availalefilter_']))){
				$this->restResourceAvailableKeyName = '';
			}
			if(NULL === self::$nowGMT){
				self::$nowGMT = Utilities::date('Y-m-d H:i:s', NULL, NULL, 'GMT');
			}
			$this->_initialized = TRUE;
		}
	}

	public function getDBO($argDSN=NULL){
		return self::_getDBO($argDSN);
	}

	protected static function _getDBO($argDSN=NULL){
		// DBOを初期化
		static $defaultDSN = NULL;
		static $DBO = array();
		// DSNの自動判別
		$DSN = $defaultDSN;
		if(NULL === $argDSN && NULL === $defaultDSN){
			$DSN = NULL;
			if(class_exists('Configure') && NULL !== Configure::constant('DB_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::DB_DSN;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('REST_DB_DSN')){
				// 定義からセッションDBの接続情報を特定
				$DSN = Configure::REST_DB_DSN;
			}
			if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
				$ProjectConfigure = PROJECT_NAME . 'Configure';
				if(NULL !== $ProjectConfigure::constant('DB_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::DB_DSN;
				}
				if(NULL !== $ProjectConfigure::constant('REST_DB_DSN')){
					// 定義からセッションDBの接続情報を特定
					$DSN = $ProjectConfigure::REST_DB_DSN;
				}
			}
			$defaultDSN = $DSN;
		}
		// DSN指定があった場合はそれに従う
		elseif(NULL !== $argDSN){
			$DSN = $argDSN;
		}
		if(!isset($DBO[$DSN])){
			$DBO[$DSN] = DBO::sharedInstance($DSN);
		}
		return $DBO[$DSN];
	}

	public function getModel($argModel, $argIdentifierORQuery=NULL, $argBinds=NULL, $argDSN=NULL){
		return self::_getModel($argModel, $argIdentifierORQuery, $argBinds, $argDSN);
	}

	protected function _getModel($argModel, $argIdentifierORQuery=NULL, $argBinds=NULL, $argDSN=NULL){
		if(NULL !== $argIdentifierORQuery){
			return ORMapper::getModel(self::_getDBO($argDSN), $argModel, $argIdentifierORQuery, $argBinds);
		}
		else{
			return ORMapper::getModel(self::_getDBO($argDSN), $argModel);
		}
	}

	public function convertArrayFromModel($ArgModel, $argFields=NULL){
		return $this->_convertArrayFromModel($ArgModel, $argFields);
	}

	protected function _convertArrayFromModel($ArgModel, $argFields=NULL){
		if(is_object($ArgModel)){
			$arrayModel = array();
			$fields = $ArgModel->getFieldKeys();
			if(NULL !== $argFields){
				for($fieldsIdx=0; $fieldsIdx < count($argFields); $fieldsIdx++){
					if(isset($ArgModel->{$argFields[$fieldsIdx]})){
						$arrayModel[$argFields[$fieldsIdx]] = (string)$ArgModel->{$argFields[$fieldsIdx]};
					}
				}
			}
			else{
				for($fieldsIdx=0; $fieldsIdx < count($fields); $fieldsIdx++){
					$arrayModel[$fields[$fieldsIdx]] = (string)$ArgModel->{$fields[$fieldsIdx]};
				}
			}
			return $arrayModel;
		}
		return FALSE;
	}
	public static function resolveRequestParams(){
		$requestParams = array();
		debug('method='.$_SERVER['REQUEST_METHOD']);
		if('PUT' === $_SERVER['REQUEST_METHOD'] || 'DELETE' === $_SERVER['REQUEST_METHOD']){
			static $putParam = NULL;
			if(NULL === $putParam){
				$putParam = parse_phpinput_str();
			}
			$requestParams = $putParam;
		}
		else if('POST' === $_SERVER['REQUEST_METHOD']){
			// XXX multipart/form-dataもPOSTなので、PHPに任せます
			$requestParams = $_POST;
		}
		else if('GET' === $_SERVER['REQUEST_METHOD'] || 'HEAD' === $_SERVER['REQUEST_METHOD']){
			$requestParams = $_GET;
		}
		else {
			// 未知のメソッド
		}
		return $requestParams;
	}

	public function getRequestParams(){
		return self::resolveRequestParams();
	}

	/**
	 * フレームワーク標準のAuth機能を利用した認証と登録を行って、RESTする(スマフォAPI向け)
	 * @return array 配列構造のリソースデータ
	 */
	public function UIDAuthAndExecute(){
		$this->_init();
		// UIDAuthREST用変数初期化
		$DBO = NULL;
		$User = FALSE;
		$userModelName = NULL;
		$UserModelCreatedFieldName = NULL;
		$UserModelModifiedFieldName = NULL;
		$deviceTypeFieldName = NULL;
		$deviceTokenFieldName = NULL;
		$deviceRegistrationIDFieldName = NULL;
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_USER_TBL_NAME')){
			$userModelName = Configure::REST_UIDAUTH_USER_TBL_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_USER_CREATE_DATE_KEY_NAME')){
			$UserModelCreatedFieldName = Configure::REST_UIDAUTH_USER_CREATE_DATE_KEY_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_USER_MODIFY_DATE_KEY_NAME')){
			$UserModelModifiedFieldName = Configure::REST_UIDAUTH_USER_MODIFY_DATE_KEY_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME')){
			$deviceTypeFieldName = Configure::REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME')){
			$deviceTypeFieldName = Configure::REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_DEVICE_TOKEN_FIELD_NAME')){
			$deviceTokenFieldName = Configure::REST_UIDAUTH_DEVICE_TOKEN_FIELD_NAME;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('REST_UIDAUTH_DEVICE_REGISTRATIONID_FIELD_NAME')){
			$deviceRegistrationIDFieldName = Configure::REST_UIDAUTH_DEVICE_REGISTRATIONID_FIELD_NAME;
		}
		if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
			$ProjectConfigure = PROJECT_NAME . 'Configure';
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_USER_TBL_NAME')){
				$userModelName = $ProjectConfigure::REST_UIDAUTH_USER_TBL_NAME;
			}
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_USER_CREATE_DATE_KEY_NAME')){
				$UserModelCreatedFieldName = $ProjectConfigure::REST_UIDAUTH_USER_CREATE_DATE_KEY_NAME;
			}
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_USER_MODIFY_DATE_KEY_NAME')){
				$UserModelModifiedFieldName = $ProjectConfigure::REST_UIDAUTH_USER_MODIFY_DATE_KEY_NAME;
			}
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME')){
				$deviceTypeFieldName = $ProjectConfigure::REST_UIDAUTH_DEVICE_TYPE_FIELD_NAME;
			}
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_DEVICE_TOKEN_FIELD_NAME')){
				$deviceTokenFieldName = $ProjectConfigure::REST_UIDAUTH_DEVICE_TOKEN_FIELD_NAME;
			}
			if(NULL !== $ProjectConfigure::constant('REST_UIDAUTH_DEVICE_REGISTRATIONID_FIELD_NAME')){
				$deviceRegistrationIDFieldName = $ProjectConfigure::REST_UIDAUTH_DEVICE_REGISTRATIONID_FIELD_NAME;
			}
		}
		try{
			$DBO = self::_getDBO();
			// UIDAuth
			$Device = Auth::getCertifiedUser();
			if(FALSE === $Device){
				// 登録処理
				// SessionID=端末固有IDと言う決めに沿って登録を行う
				$deviceID = Auth::getDecryptedAuthIdentifier();
				debug('$deviceID='.$deviceID);
				if(30 >= strlen($deviceID)){
					// UIDエラー！ 認証エラー
					throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 401);
				}
				$Device = Auth::registration($deviceID, $deviceID, self::$nowGMT);
				// 強制認証で証明を得る
				if(TRUE !== Auth::certify($Device->{Auth::$authIDField}, $Device->{Auth::$authPassField}, NULL, TRUE)){
					// 認証NG(401)
					throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 401);
				}
				// user情報の更新
				$userAdded = FALSE;
				$deviceModified = FALSE;
				if(NULL !== $userModelName && $userModelName != $Device->tableName){
					$ownerIDField = $userModelName . '_id';
					if(isset($Device->{$this->authUserIDFieldName})){
						$ownerIDField = $this->authUserIDFieldName;
					}
					if(!(0 < strlen($Device->{$ownerIDField}) && '0' != $Device->{$ownerIDField})){
						// userテーブルとdeviceテーブルのテーブル名が違うので、userテーブルの保存を行う
						$User = self::_getModel($userModelName);
						if(NULL !== $UserModelCreatedFieldName && in_array($UserModelCreatedFieldName, $User->getFieldKeys())){
							$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelCreatedFieldName)))}(self::$nowGMT);
						}
						if(NULL !== $UserModelModifiedFieldName && in_array($UserModelModifiedFieldName, $User->getFieldKeys())){
							$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelModifiedFieldName)))}(self::$nowGMT);
						}
						$User->save();
						// deviceテーブルにユーザーIDのセット(強制)
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $ownerIDField)))}($User->pkey);
						$deviceModified = TRUE;
						$userAdded = TRUE;
					}
					else {
						$User = self::_getModel($userModelName, $Device->{$ownerIDField});
						if(!(0 < (int)$User->pkey)){
							// デバイスの持ち主が変わった可能性
							// userテーブルとdeviceテーブルのテーブル名が違うので、userテーブルの保存を行う
							if(NULL !== $UserModelCreatedFieldName && in_array($UserModelCreatedFieldName, $User->getFieldKeys())){
								$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelCreatedFieldName)))}(self::$nowGMT);
							}
							if(NULL !== $UserModelModifiedFieldName && in_array($UserModelModifiedFieldName, $User->getFieldKeys())){
								$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelModifiedFieldName)))}(self::$nowGMT);
							}
							$User->save();
							// deviceテーブルにユーザーIDのセット(強制)
							$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $ownerIDField)))}($User->pkey);
							$deviceModified = TRUE;
							$userAdded = TRUE;
						}
					}
				}
				else {
					$User = $Device;
				}
				// device情報の更新
				// デバイズのtype設定があるなら保存する
				if(NULL !== $deviceTypeFieldName && in_array($deviceTypeFieldName, $Device->getFieldKeys()) && isset($this->deviceType) && 0 < strlen($this->deviceType)){
					if($Device->{$deviceTypeFieldName} != $this->deviceType){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceTypeFieldName)))}($this->deviceType);
						$deviceModified = TRUE;
					}
				}
				$request = $this->getRequestParams();
				// デバイズトークン(iOS)設定があるなら保存する
				if(NULL !== $deviceTokenFieldName && in_array($deviceTokenFieldName, $Device->getFieldKeys()) && isset($request[$deviceTokenFieldName]) && 0 < strlen($request[$deviceTokenFieldName])){
					// 上書きチェック
					if($Device->{$deviceTokenFieldName} != $request[$deviceTokenFieldName]){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceTokenFieldName)))}($request[$deviceTokenFieldName]);
						$deviceModified = TRUE;
					}
				}
				// SANDBOX端末設定(iOS)があるなら保存する
				// XXX フィード名を定数化するかどうか
				if(in_array('sandbox_enabled', $Device->getFieldKeys()) && isset($request['sandbox_enabled']) && 0 < strlen($request['sandbox_enabled'])){
					// 上書きチェック
					if($Device->sandbox_enabled != $request['sandbox_enabled']){
						$Device->setSandboxEnabled($request['sandbox_enabled']);
						$deviceModified = TRUE;
					}
				}
				// アプリバージョンがあるなら保存する
				// XXX フィード名を定数化する！？
				if(in_array('version_code', $Device->getFieldKeys()) && isset(Core::$appVersion) && NULL !== Core::$appVersion && 0 < strlen(Core::$appVersion)){
					// 上書きチェック
					if($Device->version_code != Core::$appVersion){
						$Device->setVersionCode(Core::$appVersion);
						$deviceModified = TRUE;
					}
				}
				// アプリ表示バージョンがあるなら保存する
				// XXX フィード名を定数化する！？
				if(in_array('version_name', $Device->getFieldKeys()) && isset(Core::$appDispayVersion) && NULL !== Core::$appDispayVersion && 0 < strlen(Core::$appDispayVersion)){
					// 上書きチェック
					if($Device->version_name != Core::$appDispayVersion){
						$Device->setVersionName(Core::$appDispayVersion);
						$deviceModified = TRUE;
					}
				}
				// レジストレーションID(Android)設定があるなら保存する
				if(NULL !== $deviceRegistrationIDFieldName && in_array($deviceRegistrationIDFieldName, $Device->getFieldKeys()) && isset($request[$deviceRegistrationIDFieldName]) && 0 < strlen($request[$deviceRegistrationIDFieldName])){
					// 上書きチェック
					if($Device->{$deviceRegistrationIDFieldName} != $request[$deviceRegistrationIDFieldName]){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceRegistrationIDFieldName)))}($request[$deviceRegistrationIDFieldName]);
						$deviceModified = TRUE;
					}
				}
				if(TRUE === $deviceModified){
					if(in_array(Auth::$authModifiedField, $Device->getFieldKeys())){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', Auth::$authModifiedField)))}(self::$nowGMT);
					}
					$Device->save();
				}
				if(TRUE === $deviceModified || TRUE === $userAdded){
					// 一旦コミット
					$DBO->commit();
				}
			}
			elseif(NULL !== $userModelName && $userModelName != $Device->tableName){
				$ownerIDField = $userModelName . '_id';
				if(isset($Device->{$this->authUserIDFieldName})){
					$ownerIDField = $this->authUserIDFieldName;
				}
				// user情報の更新
				$userModified = FALSE;
				$deviceModified = FALSE;
				debug('is owner?'.$Device->{$ownerIDField});
				if(!(0 < strlen($Device->{$ownerIDField}) && '0' != $Device->{$ownerIDField})){
					// user情報の更新
					// userテーブルとdeviceテーブルのテーブル名が違うので、userテーブルの保存を行う
					$User = self::_getModel($userModelName);
					if(NULL !== $UserModelCreatedFieldName && in_array($UserModelCreatedFieldName, $User->getFieldKeys())){
						$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelCreatedFieldName)))}(self::$nowGMT);
						$userModified = TRUE;
					}
					// deviceテーブルにユーザーIDのセット(強制)
					$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $ownerIDField)))}($User->pkey);
					if(NULL !== $deviceTypeFieldName && in_array($deviceTypeFieldName, $Device->getFieldKeys()) && isset($this->deviceType) && 0 < strlen($this->deviceType)){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceTypeFieldName)))}($this->deviceType);
						$deviceModified = TRUE;
					}
				}
				else {
					$User = self::_getModel($userModelName, $Device->{$ownerIDField});
					if(!(0 < (int)$User->pkey)){
						// デバイスの持ち主が変わった可能性
						// userテーブルとdeviceテーブルのテーブル名が違うので、userテーブルの保存を行う
						if(NULL !== $UserModelCreatedFieldName && in_array($UserModelCreatedFieldName, $User->getFieldKeys())){
							$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelCreatedFieldName)))}(self::$nowGMT);
							$userModified = TRUE;
						}
						// deviceテーブルにユーザーIDのセット(強制)
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $ownerIDField)))}($User->pkey);
						if(NULL !== $deviceTypeFieldName && in_array($deviceTypeFieldName, $Device->getFieldKeys()) && isset($this->deviceType) && 0 < strlen($this->deviceType)){
							$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceTypeFieldName)))}($this->deviceType);
							$deviceModified = TRUE;
						}
					}
				}
				$request = $this->getRequestParams();
				// デバイズトークン(iOS)設定があるなら保存する
				if(NULL !== $deviceTokenFieldName && in_array($deviceTokenFieldName, $Device->getFieldKeys()) && isset($request[$deviceTokenFieldName]) && 0 < strlen($request[$deviceTokenFieldName])){
					// 上書きチェック
					if($Device->{$deviceTokenFieldName} != $request[$deviceTokenFieldName]){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceTokenFieldName)))}($request[$deviceTokenFieldName]);
						$deviceModified = TRUE;
					}
				}
				// SANDBOX端末設定(iOS)があるなら保存する
				if(in_array('sandbox_enabled', $Device->getFieldKeys()) && isset($request['sandbox_enabled']) && 0 < strlen($request['sandbox_enabled'])){
					// 上書きチェック
					if($Device->sandbox_enabled != $request['sandbox_enabled']){
						$Device->setSandboxEnabled($request['sandbox_enabled']);
						$deviceModified = TRUE;
					}
				}
				// アプリバージョンがあるなら保存する
				// XXX フィード名を定数化する！？
				if(in_array('version_code', $Device->getFieldKeys()) && isset(Core::$appVersion) && NULL !== Core::$appVersion && 0 < strlen(Core::$appVersion)){
					// 上書きチェック
					if($Device->version_code != Core::$appVersion){
						$Device->setVersionCode(Core::$appVersion);
						$deviceModified = TRUE;
					}
				}
				// アプリ表示バージョンがあるなら保存する
				// XXX フィード名を定数化する！？
				if(in_array('version_name', $Device->getFieldKeys()) && isset(Core::$appDispayVersion) && NULL !== Core::$appDispayVersion && 0 < strlen(Core::$appDispayVersion)){
					// 上書きチェック
					if($Device->version_name != Core::$appDispayVersion){
						$Device->setVersionName(Core::$appDispayVersion);
						$deviceModified = TRUE;
					}
				}
				// レジストレーションID(Android)設定があるなら保存する
				if(NULL !== $deviceRegistrationIDFieldName && in_array($deviceRegistrationIDFieldName, $Device->getFieldKeys()) && isset($request[$deviceRegistrationIDFieldName]) && 0 < strlen($request[$deviceRegistrationIDFieldName])){
					// 上書きチェック
					if($Device->{$deviceRegistrationIDFieldName} != $request[$deviceRegistrationIDFieldName]){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $deviceRegistrationIDFieldName)))}($request[$deviceRegistrationIDFieldName]);
						$deviceModified = TRUE;
					}
				}
				if(TRUE === $userModified){
					if(NULL !== $UserModelModifiedFieldName && in_array($UserModelModifiedFieldName, $User->getFieldKeys())){
						$User->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $UserModelModifiedFieldName)))}(self::$nowGMT);
						$userModified = TRUE;
					}
					$User->save();
				}
				if(TRUE === $deviceModified){
					if(in_array(Auth::$authModifiedField, $Device->getFieldKeys())){
						$Device->{'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', Auth::$authModifiedField)))}(self::$nowGMT);
					}
					$Device->save();
				}
				if(TRUE === $deviceModified || TRUE === $userModified){
					// 一旦コミット
					$DBO->commit();
				}
			}
			else{
				$User = $Device;
			}
		}
		catch (Exception $Exception){
			if(NULL !== $DBO && is_object($DBO)){
				// トランザクションを異常終了する
				$DBO->rollback();
			}
			// 実装の問題によるエラー
			$this->httpStatus = 500;
			if(400 === $Exception->getCode() || 401 === $Exception->getCode() || 404 === $Exception->getCode() || 405 === $Exception->getCode() || 503 === $Exception->getCode()){
				$this->httpStatus = $Exception->getCode();
			}
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}

		$this->AuthDevice = $Device;
		if(FALSE !== $User){
			// 認証OK
			$this->AuthUser = $User;
			$this->authUserID = $User->pkey;
			if(NULL === $this->authUserIDFieldName){
				// XXX xxx_xxと言うAuthユーザー判定法は固定です！使用は任意になります。
				$this->authUserIDFieldName = strtolower($User->tableName) . '_' . $User->pkeyName;
			}
			$this->authUserQuery = ' `' . $this->authUserIDFieldName . '` = \'' . $User->pkey . '\'';
			return $this->execute();
		}

		// XXX ココを通るのは相当なイレギュラー！
		$this->httpStatus = 500;
		throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 500);
	}

	/**
	 * フレームワーク標準のAuth機能を利用した認証を行って、RESTする
	 * @return array 配列構造のリソースデータ
	 */
	public function authAndExecute(){
		$this->_init();
		$DBO = NULL;
		try{
			// Auth
			$DBO = self::_getDBO();
			$User = Auth::getCertifiedUser();
			if(FALSE === $User){
				// 認証NG(401)
				throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 401);
			}
		}
		catch (Exception $Exception){
			if(NULL !== $DBO && is_object($DBO)){
				// トランザクションを異常終了する
				$DBO->rollback();
			}
			// 実装の問題によるエラー
			$this->httpStatus = 500;
			if(400 === $Exception->getCode() || 401 === $Exception->getCode() || 404 === $Exception->getCode() || 405 === $Exception->getCode() || 503 === $Exception->getCode()){
				$this->httpStatus = $Exception->getCode();
			}
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}

		if(FALSE !== $User){
			// 認証OK
			$this->AuthUser = $User;
			$this->authUserID = $User->pkey;
			// XXX xxx_xxと言うAuthユーザー判定法は固定です！使用は任意になります。
			$this->authUserIDFieldName = strtolower($User->tableName) . '_' . $User->pkeyName;
			$this->authUserQuery = ' ' . $this->authUserIDFieldName . ' = \'' . $User->pkey . '\'';
			return $this->execute();
		}

		// XXX ココを通るのは相当なイレギュラー！
		// 恐らく実装の問題
		$this->httpStatus = 500;
		throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 500);
	}

	/**
	 * RESTする
	 * @return array 配列構造のリソースデータ
	 */
	public function execute($argResourceHint=NULL, $argRequestParams=NULL){
		static $prepend = FALSE;
		static $append = FALSE;

		$this->_init();
		debug($this->restResource);
		// RESTアクセスされるリソースの特定
		$this->restResource = $argResourceHint;
		if(NULL === $argResourceHint){
			$this->restResource = $_GET['_r_'];
		}
		if(isset($_GET['_deep_']) && TRUE == ('0' === $_GET['_deep_'] || 'false' === strtolower($_GET['_deep_']))){
			// RESTのDEEPモードを無効にする
			// XXX DEEPモードがTRUEの場合、[model名]_idのフィールドがリソースに合った場合、そのリソースまで自動で参照・更新・作成を試みます
			$this->deepRESTMode = FALSE;
		}
		if(isset($_SERVER['REQUEST_METHOD'])){
			$this->requestMethod = strtoupper($_SERVER['REQUEST_METHOD']);
			if(isset($_POST['_method_']) && strlen($_POST['_method_']) > 0){
				$this->requestMethod = strtoupper($_POST['_method_']);
			}
		}
		debug($this->restResource);
		debug('rest method='.strtolower($this->requestMethod));
		$resource = self::resolveRESTResource($this->restResource);
		debug($resource);
		if(NULL === $resource){
			// リソースの指定が無かったのでエラー終了
			$this->httpStatus = 400;
			throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 400);
		}
		if('GET' !== $this->requestMethod && 'HEAD' !== $this->requestMethod && 'POST' !== $this->requestMethod && NULL === $resource['ids']){
			// GET,POST以外のメソッドの場合はリソースID指定は必須
			$this->httpStatus = 400;
			throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 400);
		}

		$res = FALSE;
		$DBO = NULL;
		try{
			$DBO = self::_getDBO();

			// RESTの実行
			$this->restResourceModel = $resource['model'];
			if(NULL === $this->restResourceListed){
				$this->restResourceListed = $resource['listed'];
			}
			$this->restResource = $resource;

			// REST全体のPrepend処理
			if(TRUE === $this->rootREST && FALSE === $prepend){
				$prepend = TRUE;
				// 外部からのGETのQUERYとJOINは危険なので、FILTERで許可されていなければ削除する
				if (TRUE !== $this->allowed){
					$_GET['QUERY'] = '';
					$_GET['JOIN'] = '';
					unset($_GET['QUERY']);
					unset($_GET['JOIN']);
				}
				// 許可されてあっても、「; GRANT CREATE SHOW INSERT UPDATE DELETE ALTER DROP TRUNCATE」は削除
				if (isset($_GET['QUERY'])){
					$_GET['QUERY'] = str_ireplace('; ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('GRANT ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('CREATE ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('SHOW ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('INSERT ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('UPDATE ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('DELETE ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('ALTER ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('DROP ', '', $_GET['QUERY']);
					$_GET['QUERY'] = str_ireplace('TRUNCATE ', '', $_GET['QUERY']);
				}
				if (isset($_GET['JOIN'])){
					$_GET['JOIN'] = str_ireplace('; ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('GRANT ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('CREATE ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('SHOW ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('INSERT ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('UPDATE ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('DELETE ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('ALTER ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('DROP ', '', $_GET['JOIN']);
					$_GET['JOIN'] = str_ireplace('TRUNCATE ', '', $_GET['JOIN']);
				}
				// Filterがあったらフィルター処理をする
				$filerName = 'RestPrependFilter';
				debug('$filerName='.$filerName);
				if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
					$filterClass = MVCCore::loadMVCFilter($filerName);
					$Filter = new $filterClass();
					$Filter->REST = $this;
					$Filter->execute($argRequestParams);
				}
			}

			$classHint = str_replace(' ', '', ucwords(str_replace(' ', '', $this->restResourceModel)));
			debug('$classHint='.$classHint);
			debug('whitelistcheck allowed='.var_export($this->allowed,TRUE));
			if(TRUE !== isTest() && !isset($this->AuthUser) && TRUE !== $this->allowed){
				// アクセスエラー！
				throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
			}
			else if (TRUE !== $this->allowed){
				// ホワイトリストフィルター
				if (TRUE === $this->rootREST){
					// 現在のホワイトリストの一覧を取得
					$nowWhiteList = stripslashes(trim(getConfig('REST_RESOURCE_WHITE_LIST')));
					debug("whitelistcheck now whiteList=". $nowWhiteList);
					$whiteList = json_decode($nowWhiteList, TRUE);
					$resourcePath = $this->restResource["model"];
					if (TRUE === $this->restResource["me"]){
						$resourcePath = "me.".$resourcePath;
					}
					if (TRUE !== $this->restResource["me"] && TRUE === $this->restResource["listed"]){
						$resourcePath .= ".list";
					}
					debug("whitelistcheck resourcePath=". $resourcePath);
					if (NULL === $nowWhiteList && 0 === strlen($nowWhiteList)){
						// アクセスエラー！
						throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
					}
					else {
						debug("whitelistcheck isTest=". var_export(isTest(), true));
						debug("whitelistcheck whiteList=". var_export($whiteList, true));
						$paramKeys = array_keys($this->getRequestParams());
						$allowUser = $_SERVER['REMOTE_ADDR'];
						if (isset($this->AuthUser) && NULL !== $this->AuthUser && 0 < strlen($this->AuthUser->tableName)){
							$allowUser = $this->AuthUser->tableName;
						}
						if (isTest()){
							// テスト環境の場合は、ホワイトフィルターを育てる処理
							$updateWhiteList = FALSE;
							if (!isset($whiteList[$resourcePath])){
								$whiteList[$resourcePath] = array("Method ".$this->requestMethod => NULL);
							}
							if (!isset($whiteList[$resourcePath]["Method ".$this->requestMethod])){
								$whiteList[$resourcePath]["Method ".$this->requestMethod] = array();
							}
							// ホワイトリストに追加
							$whiteList[$resourcePath]["Method ".$this->requestMethod][$allowUser] = $paramKeys;
							$newWhiteList = json_encode($whiteList);
							debug("whitelistcheck new whiteList=". $newWhiteList);
							debug("whitelistcheck now whiteList=". $nowWhiteList);
							// Configに書き出す
							if ($nowWhiteList != $newWhiteList){
								debug("whitelistcheck modify whiteList=". $newWhiteList);
								modifiyConfig('REST_RESOURCE_WHITE_LIST', PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.
									str_replace("\"],\"", "\"]".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB.",\"", 
										str_replace("\"]},\"Method ", "\"]}".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB.",\"Method ", 
											str_replace("\":{\"", "\":".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB."{\"", 
												str_replace(":{\"Method ", ":".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB."{\"Method ", 
													str_replace("}}", "}".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB."}", 
														str_replace("\"]}}", "\"]}".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB.PHP_TAB."}".PHP_EOL.PHP_TAB.PHP_TAB.PHP_TAB, json_encode($whiteList))))))).PHP_EOL.PHP_TAB.PHP_TAB);
							}
						}
						else {
							debug("whitelistcheck new is??");
							// ホワイトリストによるリソースアクセスチェック！
							if (!(isset($whiteList[$resourcePath]) && isset($whiteList[$resourcePath]["Method ".$this->requestMethod]))){
								// アクセスエラー！
								throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
							}
							else if(is_array($whiteList[$resourcePath]["Method ".$this->requestMethod])){
								if(isset($whiteList[$resourcePath]["Method ".$this->requestMethod]["*"]) && 0 < count(array_diff($paramKeys, $whiteList[$resourcePath]["Method ".$this->requestMethod]["*"]))){
									// アクセスエラー！
									throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
								}
								else if(0 < count(array_diff($paramKeys, $whiteList[$resourcePath]["Method ".$this->requestMethod][$allowUser]))){
									// アクセスエラー！
									throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
								}
							}
							else if ("*" !== $whiteList[$resourcePath]["Method ".$this->requestMethod]){
								// アクセスエラー！
								throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 405);
							}
							// 許可されたRESTへのアクセス
							debug("whitelistcheck new is ok!");
						}
					}
				}
			}

			// 指定リソースの絶対的なPrepend
			$filerName = $classHint . 'PrependFilter';
			debug('resoruce='.$filerName);
			if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
				$filterClass = MVCCore::loadMVCFilter($filerName);
				$Filter = new $filterClass();
				$Filter->REST = $this;
				// リクエストメソッドで分岐する
				if('POST' === $this->requestMethod || 'PUT' === $this->requestMethod){
					$Filter->{strtolower($this->requestMethod)}($argRequestParams);
				}
				else {
					$Filter->{strtolower($this->requestMethod)}();
				}
			}

			if(FALSE !== MVCCore::loadMVCModule($classHint, TRUE)){
				debug('RestClassLoaded');
				// オーバーライドされたModelへのリソース操作クラスが在る場合は、それをnewして実行する
				$className = MVCCore::loadMVCModule($classHint);
				debug('RestClassLoaded='.$className);
				$RestController = new $className();
				// 自分自身の持っているパブリックパラメータをブリッジ先のRestControllerに引き渡す
				$RestController->controlerClassName = $this->restResourceModel;
				$RestController->httpStatus = $this->httpStatus;
				$RestController->outputType = $this->outputType;
				$RestController->requestMethod = $this->requestMethod;
				$RestController->restResource = $this->restResource;
				$RestController->jsonUnescapedUnicode = $this->jsonUnescapedUnicode;
				$RestController->deviceType = $this->deviceType;
				$RestController->appVersion = $this->appVersion;
				$RestController->appleReviewd = $this->appleReviewd;
				$RestController->mustAppVersioned = $this->mustAppVersioned;
				$RestController->allowed = $this->allowed;
				$RestController->deepRESTMode = $this->deepRESTMode;
				if (!isset($RestController->virtualREST)){
					$RestController->virtualREST = $this->virtualREST;
				}
				debug("virtualREST=".var_export($RestController->virtualREST,true));
				$RestController->restResource = $this->restResource;
				$RestController->restResourceModel = $this->restResourceModel;
				$RestController->restResourceListed = $this->restResourceListed;
				$RestController->restResourceUserTableName = $this->restResourceUserTableName;
				$RestController->restResourceCreateDateKeyName = $this->restResourceCreateDateKeyName;
				$RestController->restResourceModifyDateKeyName = $this->restResourceModifyDateKeyName;
				$RestController->restResourceAvailableKeyName = $this->restResourceAvailableKeyName;
				$RestController->restResourceRelaySuffix = $this->restResourceRelaySuffix;
				$RestController->restResourceRelayPrefix = $this->restResourceRelayPrefix;
				$RestController->AuthUser = $this->AuthUser;
				$RestController->AuthDevice = $this->AuthDevice;
				$RestController->authUserID = $this->authUserID;
				$RestController->authUserIDFieldName = $this->authUserIDFieldName;
				$RestController->authUserQuery = $this->authUserQuery;
				// リクエストメソッドで分岐する
				if('POST' === $this->requestMethod || 'PUT' === $this->requestMethod){
					$res = $RestController->{strtolower($this->requestMethod)}($argRequestParams);
				}
				else {
					$res = $RestController->{strtolower($this->requestMethod)}();
				}
				$this->responceData = &$res;
				// 結果のパラメータを受け取り直す
				$this->httpStatus = $RestController->httpStatus;
				$this->outputType = $RestController->outputType;
				$this->requestMethod = $RestController->requestMethod;
				$this->restResource = $RestController->restResource;
				$this->jsonUnescapedUnicode = $RestController->jsonUnescapedUnicode;
				$this->deviceType = $RestController->deviceType;
				$this->appVersion = $RestController->appVersion;
				$this->appleReviewd = $RestController->appleReviewd;
				$this->mustAppVersioned = $RestController->mustAppVersioned;
				$this->allowed = $RestController->allowed;
				$this->deepRESTMode = $RestController->deepRESTMode;
				$this->virtualREST = $RestController->virtualREST;
				$this->restResource = $RestController->restResource;
				$this->restResourceModel = $RestController->restResourceModel;
				$this->restResourceListed = $RestController->restResourceListed;
				$this->restResourceUserTableName = $RestController->restResourceUserTableName;
				$this->restResourceCreateDateKeyName = $RestController->restResourceCreateDateKeyName;
				$this->restResourceModifyDateKeyName = $RestController->restResourceModifyDateKeyName;
				$this->restResourceAvailableKeyName = $RestController->restResourceAvailableKeyName;
				$this->restResourceRelaySuffix = $RestController->restResourceRelaySuffix;
				$this->restResourceRelayPrefix = $RestController->restResourceRelayPrefix;
				$this->AuthUser = $RestController->AuthUser;
				$this->AuthDevice = $RestController->AuthDevice;
				$this->authUserID = $RestController->authUserID;
				$this->authUserIDFieldName = $RestController->authUserIDFieldName;
				$this->authUserQuery = $RestController->authUserQuery;
			}
			else {
				// リクエストメソッドで分岐する
				$res = $this->{strtolower($this->requestMethod)}();
				$this->responceData = &$res;
			}

			// 指定リソースの絶対的なAppend
			$filerName = $classHint . 'AppendFilter';
			debug('resoruce='.$filerName);
			if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
				$filterClass = MVCCore::loadMVCFilter($filerName);
				$Filter = new $filterClass();
				$Filter->REST = $this;
				// リクエストメソッドで分岐する
				if('POST' === $this->requestMethod || 'PUT' === $this->requestMethod){
					$Filter->{strtolower($this->requestMethod)}($argRequestParams);
				}
				else {
					$Filter->{strtolower($this->requestMethod)}();
				}
			}

			// REST全体のAppend処理
			if(TRUE === $this->rootREST && FALSE === $append){
				$append = TRUE;
				// Filterがあったらフィルター処理をする
				$filerName = 'RestAppendFilter';
				debug('$filerName='.$filerName);
				if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
					$filterClass = MVCCore::loadMVCFilter($filerName);
					$Filter = new $filterClass();
					$Filter->REST = $this;
					$Filter->execute($argRequestParams);
				}
			}

			// トランザクションを正常終了する
			$DBO->commit();
		}
		catch (Exception $Exception){
			if(NULL !== $DBO && is_object($DBO)){
				// トランザクションを異常終了する
				$DBO->rollback();
			}
			// 実装の問題によるエラー
			$this->httpStatus = 500;
			if(400 === $Exception->getCode() || 401 === $Exception->getCode() || 404 === $Exception->getCode() || 405 === $Exception->getCode() || 503 === $Exception->getCode()){
				$this->httpStatus = $Exception->getCode();
			}
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}

		debug('res=');
		debug($res);

		if(TRUE === $res){
			$res = array('success' => TRUE);
		}

		if(FALSE === $res || TRUE !== is_array($res)){
			// XXX ココを通るのは相当なイレギュラー！
			// 恐らく実装の問題
			$this->httpStatus = 500;
			throw new RESTException(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__, 400);
		}

		if(TRUE === is_array($res) && 'HEAD' !== $this->requestMethod){
			if('html' === $this->outputType){
				debug('convert html');
				$basehtml = '';
				$URIs = explode('?', $_SERVER['REQUEST_URI']);
				if("index" === strtolower($this->restResourceModel)){
					$basehtml .= '<h2>Table List</h2>'.PHP_EOL;
					$basehtml .= '<ul>'.PHP_EOL;
					for($idx=0; $idx < count($res); $idx++){
						$basehtml .= '<li><a class="tablelink" id="table_'.$res[$idx]['name'].'" href="'.str_replace('/index.html', '/', $URIs[0]).$res[$idx]['name'].'.html"><span class="table-name">'.$res[$idx]['name'].'</span>'.((0 < strlen($res[$idx]['comment']) ? ' "<span class="table-comment">'.$res[$idx]['comment'].'</span>"' : '')).'(<span class="table-row">'.$res[$idx]['row'].'</span>)'.'</a></li>'.PHP_EOL;
					}
					$basehtml .= '</ul>'.PHP_EOL;
				}
				else {
					$requestParams = $this->getRequestParams();
					$basehtml .= '<h2>'.$this->restResourceModel.'</h2>'.PHP_EOL;
					if(TRUE === $this->restResourceListed){
						$basehtml .= '<h3><form id="crud-form-search" class="crud-form" method="GET"><input type="text" value="' . ((isset($requestParams['LIKE']))? $requestParams['LIKE'] : '') . '" name="LIKE"/><div class="submit-button search-button"><input type="submit" value="search"/></div></form></h3>'.PHP_EOL;
						if(isset($res[0])){
							$basehtml .= '<table class="list">'.PHP_EOL;
							// リストヘッダ
							$basehtml .= '<tr>'.PHP_EOL;
							foreach($res[0] as $key => $val){
								$order = $requestParams['ORDER'];
								if(strlen($order) > 0 && 0 === strpos($order, $key) && FALSE !== strpos($order, 'DESC')){
									$order = rawurlencode($key.' ASC');
								}
								else {
									$order = rawurlencode($key.' DESC');
								}
								$basehtml .= '<th class="crudkey"><a class="crudlink" id="crud_order_'.$this->restResourceModel.'_'.$key.'" href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET=0&total='.$requestParams['total'].'&ORDER='.$order.'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.$key.'</a></th>';
							}
							$basehtml .= '</tr>'.PHP_EOL;
							for($idx=0; $idx < count($res); $idx++){
								$basehtml .= '<tr>'.PHP_EOL;
								$id = '';
								foreach($res[$idx] as $key => $val){
									if('' === $id){
										$id = $val;
									}
									$basehtml .= '<td><a class="crudlink" id="crud_'.$this->restResourceModel.'_'.$id.'" target="_blank" href="'.str_replace('/'.$this->restResourceModel.'.html', '/'.$this->restResourceModel.'/'.$id.'.html', $URIs[0]).'">'.$val.'</a></td>';
								}
								$basehtml .= '</tr>'.PHP_EOL;
							}
							$basehtml .= '</table>'.PHP_EOL;
							if(TRUE === $this->rootREST && isset($requestParams['LIMIT']) && is_numeric($requestParams['LIMIT']) && (int)$requestParams['LIMIT'] > 0 && isset($requestParams['OFFSET']) && is_numeric($requestParams['OFFSET']) && isset($requestParams['total']) && is_numeric($requestParams['total']) && (int)$requestParams['total'] > 0){
								// ページング
								$nowPage = (floor((int)$requestParams['OFFSET']/(int)$requestParams['LIMIT'])+1);
								if(1 < ceil((int)$requestParams['total']/(int)$requestParams['LIMIT'])){
									$basehtml .= '<table class="paging"><tr>'.PHP_EOL;
									if($nowPage > 1){
										// 先頭リンク
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET=0&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">&lt;&lt;</a></td>'.PHP_EOL;
										// 前へリンク
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']-(int)$requestParams['LIMIT']).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">&lt;</a></td>'.PHP_EOL;
									}
									// 2つ前のページ
									if($nowPage-2 > 0){
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']-(int)$requestParams['LIMIT']*2).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.($nowPage-2).'</a></td>'.PHP_EOL;
									}
									// 1つ前のページ
									if($nowPage-1 > 0){
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']-(int)$requestParams['LIMIT']).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.($nowPage-1).'</a></td>'.PHP_EOL;
									}
									// 現在ページ
									$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.$requestParams['OFFSET'].'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.$nowPage.'</a></td>'.PHP_EOL;
									// 1つ次のページ
									if($nowPage < ceil((int)$requestParams['total']/(int)$requestParams['LIMIT'])){
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']+(int)$requestParams['LIMIT']).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.($nowPage+1).'</a></td>'.PHP_EOL;
									}
									// 2つ次のページ
									if($nowPage+1 < ceil((int)$requestParams['total']/(int)$requestParams['LIMIT'])){
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']+(int)$requestParams['LIMIT']*2).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">'.($nowPage+2).'</a></td>'.PHP_EOL;
									}
									if($nowPage < (ceil((int)$requestParams['total']/(int)$requestParams['LIMIT']))){
										// 次へリンク
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.((int)$requestParams['OFFSET']+(int)$requestParams['LIMIT']).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">&gt;</a></td>'.PHP_EOL;
										// 終端リンク
										$basehtml .= '<td class="list-paginglink"><a href="'.$URIs[0].'?LIMIT='.$requestParams['LIMIT'].'&OFFSET='.(floor((int)$requestParams['total']/(int)$requestParams['LIMIT'])*(int)$requestParams['LIMIT']).'&total='.$requestParams['total'].'&ORDER='.rawurlencode($requestParams['ORDER']).'&LIKE='.rawurlencode($requestParams['LIKE']).'">&gt;&gt;</a></td>'.PHP_EOL;
									}
									$basehtml .= '</tr></table>'.PHP_EOL;
								}
							}
							$basehtml .= '<div class="csv-download-link"><a href="'.str_replace('.html', '.csv', $_SERVER['REQUEST_URI']).'">download csv</a></div>'.PHP_EOL;
							$basehtml .= '<div class="csv-all-download-link"><a href="'.str_replace('.html', '.csv', $URIs[0]).'?ORDER='.rawurlencode($requestParams['ORDER']).'">download csv all records</a></div>'.PHP_EOL;
							$basehtml .= '<div class="tablelist-link"><a href="'.str_replace('/'.$this->restResourceModel.'.html', '/index.html', $URIs[0]).'">table list</a></div>'.PHP_EOL;
						}
					}
					else {
						if(isset($res[0])){
							$basehtml .= '<form id="crud-form-put" class="crud-form" method="POST">'.PHP_EOL;
							$basehtml .= '<table class="detail">'.PHP_EOL;
							$id = '';
							foreach($res[0] as $key => $val){
								if('' === $id){
									$id = $val;
								}
								$basehtml .= '<tr><th class="crudkey">'.$key.'</th></tr>'.PHP_EOL;
								$basehtml .= '<tr><td><input type="text" name="'.$key.'" value="'.htmlspecialchars($val).'"/></td></tr>'.PHP_EOL;
							}
							$basehtml .= '<tr><td><div class="submit-button put-button"><input type="submit"/ value="PUT"></div></td></tr>'.PHP_EOL;
							$basehtml .= '<input type="hidden" name="_method_" value="PUT"/>'.PHP_EOL;
							$basehtml .= '</table>'.PHP_EOL;
							$basehtml .= '</form>'.PHP_EOL;
							$basehtml .= '<form id="crud-form-delete" class="crud-form" method="POST">'.PHP_EOL;
							$basehtml .= '<div class="submit-button delete-button"><input type="submit"/ value="DELETE"></div>'.PHP_EOL;
							$basehtml .= '<input type="hidden" name="_method_" value="DELETE"/>'.PHP_EOL;
							$basehtml .= '</form>'.PHP_EOL;
							$basehtml .= '<div class="list-link"><a href="'.str_replace('/'.$this->restResourceModel.'/'.$id.'.html', '/'.$this->restResourceModel.'.html', $URIs[0]).'">'.$this->restResourceModel.' list</a></div>'.PHP_EOL;
						}
						else {
							$basehtml .= '<div class="list-link"><a href="javascript:history.back()">back</a></div>'.PHP_EOL;
						}
					}
				}
				$res = $basehtml;
			}
		}

		if('HEAD' === $this->requestMethod && isset($res['describes'])){
			header('Head: ' . json_encode($res['describes']));
			header('Rules: ' . json_encode($res['rules']));
			header('Records: ' . $res['count']);
			header('Comment: ' . json_encode($res['comment']));
			$res = TRUE;
		}
		else if(TRUE === $this->rootREST && FALSE === $this->virtualREST && 'GET' === $this->requestMethod && TRUE !== ('index' === strtolower($this->restResourceModel) && 'html' === $this->outputType)){
			// GETの時はHEADリクエストの結果を包括する為の処理
			try{
				$headRes = $this->head();
				header('Head: ' . json_encode($headRes['describes']));
				header('Rules: ' . json_encode($headRes['rules']));
				header('Records: ' . $headRes['count']);
				header('Comment: ' . json_encode($headRes['comment']));
			}
			catch (Exception $Exception){
				// 何もしない
			}
		}

		// MVCCoreのアクセス時間をRESTが持っている現在時刻で差し替える
		MVCCore::$accessed = self::$nowGMT;

		// 正常終了(のハズ！)
		return $res;
	}

	/**
	 * RESTAPIでリソースにアクセスする際の指定リソース情報を分解してパラメータ化します
	 * [me指定(任意)/][model指定(必須)/][pkey指定(,pkey指定,...)(GET以外は必須)/]
	 * 例)
	 * 自分の"model"の一覧を取得
	 * /me/model.json
	 * XXX システム毎にRESTのURIパラメータ分解法が違う場合はこのメソッドをオーバーライドして下さい
	 * @param string $argRESTResourceHint
	 * @return array model,listed,fields,idsの配列
	 */
	public static function resolveRESTResource($argRESTResourceHint){
		$resource = NULL;
		if(strlen($argRESTResourceHint) > 0){
			// /区切りのリソースヒントを分解する
			$hints = explode('/', $argRESTResourceHint);
			$hintIdx=0;
			// 少なくとも一つ以上のリソース指定条件を必要とする！
			if(count($hints) >= 1){
				$me = FALSE;
				// me指定があるかどうか
				if('me' === $hints[$hintIdx]){
					$me = TRUE;
					$hintIdx++;
					$model = $hints[$hintIdx];
				}
				else{
					$model = $hints[$hintIdx];
				}
				$hintIdx++;
				$ids = NULL;
				$listed = TRUE;
				// pkey指定があるかどうか
				if(isset($hints[$hintIdx]) && strlen($hints[$hintIdx]) > 0){
					$ids = array($hints[$hintIdx]);
					if(',' === $hints[$hintIdx]){
						$ids = explode(',', $hints[$hintIdx]);
					}
					if(count($ids) <= 1){
						// リース１件に対してのアクセスなのでlistでは無い
						$listed = FALSE;
					}
				}
				$resource = array('me' => $me, 'model' => $model, 'listed' => $listed, 'ids' => $ids);
			}
		}
		return $resource;
	}

	/**
	 * GETメソッド リソースの参照(冪等性を持ちます)
	 * XXX モデルの位置付けが、テーブルリソースで無い場合は、継承して、RESTの”冪等性”に従って実装して下さい
	 * @return mixed 成功時は最新のリソース配列 失敗時はFALSE
	 */
	public function get(){
		$resources = array();
		$requestParams = array();
		$baseQuery = ' 1=1 ';
		$baseBinds = NULL;
		$isDeepModel = FALSE;
		$deepModels = array();
		if("index" === strtolower($this->restResourceModel)){
			// IndexはCRUD出来るテーブル一覧を返す
			$DBO = self::_getDBO();
			// XXX MySQL専用になっている事に注意！
			$response = $DBO->getTables();
			if(FALSE === $response){
				throw new Exception(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__);
			}
			else{
				$resources = $response;
			}
			return $resources;
		}
		try{
			if(TRUE === $this->restResource['me'] && NULL !== $this->AuthUser && is_object($this->AuthUser) && strtolower($this->restResourceModel) == strtolower($this->AuthUser->tableName)){
				// 自分自身のAuthモデルに対しての処理とする
				$Model = $this->AuthUser;
				$fields = $Model->getFieldKeys();
				// REQUESTされているパラメータは条件分に利用する
				for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
					// DEEP-REST用のテーブルとフィールドの一覧をストックしておく
					if(TRUE === $this->deepRESTMode && TRUE === (TRUE === $this->restResource['me'] || $this->authUserIDFieldName != $fields[$fieldIdx])){
						$deepBaseResource = NULL;
						if(0 < strlen($this->restResourceRelayPrefix) && 0 === strpos($fields[$fieldIdx], $this->restResourceRelayPrefix) && (strlen($this->restResourceRelayPrefix.$fields[$fieldIdx]) -3) === strpos($this->restResourceRelayPrefix.$fields[$fieldIdx], '_id')){
							$deepBaseResource = substr(substr($fields[$fieldIdx], 0, -3), strlen($this->restResourceRelayPrefix));
						}
						else if((strlen($fields[$fieldIdx]) - (3 + strlen($this->restResourceRelaySuffix))) === strpos($fields[$fieldIdx], '_id'.$this->restResourceRelaySuffix)){
							$deepBaseResource = substr($fields[$fieldIdx], 0, - (3 + strlen($this->restResourceRelaySuffix)));
						}
						else if((strlen($fields[$fieldIdx]) -3) === strpos($fields[$fieldIdx], '_id')){
							$deepBaseResource = substr($fields[$fieldIdx], 0, -3);
						}
						if(NULL !== $this->restResourceUserTableName && $this->authUserIDFieldName == $fields[$fieldIdx]){
							$deepBaseResource = $this->restResourceUserTableName;
						}
						if(NULL !== $deepBaseResource && 0 < strlen($deepBaseResource)){
							debug(__LINE__.'deep??'.$deepBaseResource.'&'.$this->authUserIDFieldName.'&'.$fields[$fieldIdx]);
							$isDeepModel = TRUE;
							$deepModels[$fields[$fieldIdx]] = $deepBaseResource;
						}
					}
				}
				$resources[] = $this->_convertArrayFromModel($Model);
				// DEEP-REST IDに紐づく関連テーブルのレコード参照
				if(TRUE === $isDeepModel){
					foreach($deepModels as $key => $val){
						$id = $resources[count($resources)-1][$key];
						if(0 < (int)$id && 0 < strlen($id)){
							// DEEPは有効なIDの値の時だけ
							$deepResource = $val.'/'.$id;
							$field = str_replace('_id', '', $key);
							if($this->authUserIDFieldName == $key){
								$field = $val;
							}
							if(TRUE === $this->restResource['me']  && strtolower($val) != strtolower($this->AuthUser->tableName)){
								// meリソース参照を継承
								$deepResource = 'me/'.$deepResource;
							}
							debug(__LINE__.'deep???'.$deepResource.'&'.$key.'&field='.$field);
							// deepRESTを実行し、IDの取得をする
							$DeepREST = new REST();
							$DeepREST->AuthUser = $this->AuthUser;
							$DeepREST->AuthDevice = $this->AuthDevice;
							$DeepREST->authUserID = $this->authUserID;
							$DeepREST->authUserIDFieldName = $this->authUserIDFieldName;
							$DeepREST->authUserQuery = $this->authUserQuery;
							// リスト参照はDEEP-RESTに継承する
							$DeepREST->restResourceListed = $this->restResourceListed;
							$DeepREST->rootREST = FALSE;
							$resources[count($resources)-1][$field] = $DeepREST->execute($deepResource);
						}
					}
				}
			}
			else {
				$requestParams = $this->getRequestParams();
				$Model = $this->_getModel($this->restResourceModel);
				$fields = $Model->getFieldKeys();
				debug($fields);
				if(TRUE === $this->restResource['me'] && FALSE !== in_array($this->authUserIDFieldName, $fields)){
					// 認証ユーザーのリソース指定
					// bind使うので自力で組み立てる
					$baseQuery = ' `' . $Model->tableName . '`.`' . $this->authUserIDFieldName . '` = :' . $this->authUserIDFieldName . ' ';
					$baseBinds = array($this->authUserIDFieldName => $this->authUserID);
				}
				debug(array_keys($requestParams));
				// REQUESTされているパラメータは条件文に利用する
				for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
					if(isset($requestParams[$fields[$fieldIdx]])){
						// GETパラメータでbaseクエリを書き換える
						if(is_array($requestParams[$fields[$fieldIdx]]) && isset($requestParams[$fields[$fieldIdx]]['mark']) && isset($requestParams[$fields[$fieldIdx]]['value'])){
							// =以外の条件を指定したい場合の特殊処理
							$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` ' . $requestParams[$fields[$fieldIdx]]['mark'] . ' :' . $fields[$fieldIdx] . ' ';
							$bindValue = $requestParams[$fields[$fieldIdx]]['value'];
						}
						else{
							$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` = :' . $fields[$fieldIdx] . ' ';
							$bindValue = $requestParams[$fields[$fieldIdx]];
						}
						if(NULL === $baseBinds){
							$baseBinds = array();
						}
						$baseBinds[$fields[$fieldIdx]] = $bindValue;
					}
					else if(isset($requestParams['LIKE']) && strlen($requestParams['LIKE']) > 0){
						$baseQuery .= ' OR `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` LIKE \'%'.addslashes($requestParams['LIKE']).'%\' ';
					}
					// 有効フラグの自動参照制御
					if($this->restResourceAvailableKeyName == $fields[$fieldIdx]){
						$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $this->restResourceAvailableKeyName . '` = :' . $fields[$fieldIdx] . ' ';
						$baseBinds[$fields[$fieldIdx]] = '1';
					}
					// DEEP-REST用のテーブルとフィールドの一覧をストックしておく
					if(TRUE === $this->deepRESTMode && TRUE === (TRUE === $this->restResource['me'] || $this->authUserIDFieldName != $fields[$fieldIdx])){
						$deepBaseResource = NULL;
						if(0 < strlen($this->restResourceRelayPrefix) && 0 === strpos($fields[$fieldIdx], $this->restResourceRelayPrefix) && (strlen($this->restResourceRelayPrefix.$fields[$fieldIdx]) -3) === strpos($this->restResourceRelayPrefix.$fields[$fieldIdx], '_id')){
							$deepBaseResource = substr(substr($fields[$fieldIdx], 0, -3), strlen($this->restResourceRelayPrefix));
						}
						else if((strlen($fields[$fieldIdx]) - (3 + strlen($this->restResourceRelaySuffix))) === strpos($fields[$fieldIdx], '_id'.$this->restResourceRelaySuffix)){
							$deepBaseResource = substr($fields[$fieldIdx], 0, - (3 + strlen($this->restResourceRelaySuffix)));
						}
						else if((strlen($fields[$fieldIdx]) -3) === strpos($fields[$fieldIdx], '_id')){
							$deepBaseResource = substr($fields[$fieldIdx], 0, -3);
						}
						if(NULL !== $this->restResourceUserTableName && $this->authUserIDFieldName == $fields[$fieldIdx]){
							$deepBaseResource = $this->restResourceUserTableName;
						}
						if(NULL !== $deepBaseResource && 0 < strlen($deepBaseResource)){
							debug(__LINE__.'deep??'.$deepBaseResource.'&'.$this->authUserIDFieldName.'&'.$fields[$fieldIdx]);
							$isDeepModel = TRUE;
							$deepModels[$fields[$fieldIdx]] = $deepBaseResource;
						}
					}
				}
				if(TRUE === $this->rootREST && isset($requestParams['QUERY']) && strlen($requestParams['QUERY']) > 0){
					// XXX SQLインジェクション対策を後でTXに相談！
					$baseQuery .= ' AND ' . $requestParams['QUERY'] . ' ';
				}
				if(FALSE !== strpos($baseQuery, '1=1  OR ')){
					$baseQuery = str_replace('1=1  OR ', 'WHERE ', $baseQuery);
				}
				// ID指定による参照(単一参照含む)
				if(NULL !== $this->restResource['ids'] && count($this->restResource['ids']) >= 1){
					// id指定でループする
					for($IDIdx = 0; $IDIdx < count($this->restResource['ids']); $IDIdx++){
						$query = $baseQuery . ' AND `' . $Model->tableName . '`.`' . $Model->pkeyName . '` = :' . $Model->pkeyName . ' ';
						$binds = $baseBinds;
						if(NULL === $binds){
							$binds = array();
						}
						$binds[$Model->pkeyName] = $this->restResource['ids'][$IDIdx];
						// GROUP句指定があれば付け足す
						if(TRUE === $this->rootREST && isset($requestParams['GROUP']) && 0 < strlen($requestParams['GROUP'])){
							$query .= ' GROUP BY ' . $requestParams['GROUP'] . ' ';
						}
						// ORDER句指定があれば付け足す
						if(isset($requestParams['ORDER']) && 0 < strlen($requestParams['ORDER'])){
							$query .= ' ORDER BY ' . $requestParams['ORDER'] . ' ';
						}
						elseif(in_array($this->restResourceModifyDateKeyName, $fields)) {
							$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceModifyDateKeyName . '` DESC ';
						}
						elseif(in_array($this->restResourceCreateDateKeyName, $fields)) {
							$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceCreateDateKeyName . '` DESC ';
						}
						else {
							$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $Model->pkeyName . '` DESC ';
						}
						// LIMIT句指定があれば付け足す
						if(TRUE === $this->rootREST){
							if(isset($requestParams['LIMIT']) && is_numeric($requestParams['LIMIT']) && 0 < (int)$requestParams['LIMIT']){
								$query .= ' LIMIT';
								// OFFSET句指定があれば付け足す
								if(isset($requestParams['OFFSET']) && is_numeric($requestParams['OFFSET']) && 0 < (int)$requestParams['OFFSET']){
									$query .= ' ' . $requestParams['OFFSET'] . ',';
								}
								$query .= ' ' . $requestParams['LIMIT'] . ' ';
							}
							if (isset($requestParams['JOIN'])){
								$query = array('QUERY' => $query, 'JOIN' => $requestParams['JOIN']);
							}
						}
						debug('REST '.__LINE__.'load query='.var_export($query, TRUE));
						// 読み込み
						$Model->load($query, $binds);
						if($Model->count > 0){
							$resources[] = $this->_convertArrayFromModel($Model);
							// DEEP-REST IDに紐づく関連テーブルのレコード参照
							if(TRUE === $isDeepModel){
								foreach($deepModels as $key => $val){
									$id = $resources[count($resources)-1][$key];
									if(0 < (int)$id && 0 < strlen($id)){
										// DEEPは有効なIDの値の時だけ
										$deepResource = $val.'/'.$id;
										$field = str_replace('_id', '', $key);
										if($this->authUserIDFieldName == $key){
											$field = $val;
										}
										if(TRUE === $this->restResource['me']  && strtolower($val) != strtolower($this->AuthUser->tableName)){
											// meリソース参照を継承
											$deepResource = 'me/'.$deepResource;
										}
										debug(__LINE__.'deep???'.$deepResource.'&'.$key.'&field='.$field);
										// deepRESTを実行し、IDの取得をする
										$DeepREST = new REST();
										$DeepREST->AuthUser = $this->AuthUser;
										$DeepREST->AuthDevice = $this->AuthDevice;
										$DeepREST->authUserID = $this->authUserID;
										$DeepREST->authUserIDFieldName = $this->authUserIDFieldName;
										$DeepREST->authUserQuery = $this->authUserQuery;
										// リスト参照はDEEP-RESTに継承する
										$DeepREST->restResourceListed = $this->restResourceListed;
										$DeepREST->rootREST = FALSE;
										$resources[count($resources)-1][$field] = $DeepREST->execute($deepResource);
									}
								}
							}
						}
						else if(TRUE === $this->rootREST && TRUE !== $this->restResourceListed){
							// ROOT-RESTで且つLIST指定で無い時は、素直にリソースが無かったエラー
							if(!isset($Model->{$Model->pkeyName}) || $Model->{$Model->pkeyName} != $this->restResource['ids'][$IDIdx]){
								// リソースが存在しない
								debug($this->restResourceModel);
								debug($query);
								debug($binds);
								debug($this->restResource);
								debug($Model->pkeyName . '=' . $Model->{$Model->pkeyName});
								throw new Exception(__CLASS__.PATH_SEPARATOR.__METHOD__.PATH_SEPARATOR.__LINE__);
							}
						}
					}
				}
				// 配列の参照
				else if(TRUE === $this->restResourceListed){
					$query = $baseQuery;
					$binds = $baseBinds;
					// GROUP句指定があれば付け足す
					if(TRUE === $this->rootREST && isset($requestParams['GROUP']) && 0 < strlen($requestParams['GROUP'])){
						$query .= ' GROUP BY ' . $requestParams['GROUP'] . ' ';
					}
					// ORDER句指定があれば付け足す
					if(isset($requestParams['ORDER']) && 0 < strlen($requestParams['ORDER'])){
						$query .= ' ORDER BY ' . $requestParams['ORDER'] . ' ';
					}
					elseif(in_array($this->restResourceModifyDateKeyName, $fields)) {
						$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceModifyDateKeyName . '` DESC ';
					}
					elseif(in_array($this->restResourceCreateDateKeyName, $fields)) {
						$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceCreateDateKeyName . '` DESC ';
					}
					else {
						$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $Model->pkeyName . '` DESC ';
					}

					// LIMIT句指定があれば付け足す
					if(TRUE === $this->rootREST){
						if(isset($requestParams['LIMIT']) && is_numeric($requestParams['LIMIT']) && 0 < (int)$requestParams['LIMIT']){
							$query .= ' LIMIT';
							// OFFSET句指定があれば付け足す
							if(isset($requestParams['OFFSET']) && is_numeric($requestParams['OFFSET']) && 0 < (int)$requestParams['OFFSET']){
								$query .= ' ' . $requestParams['OFFSET'] . ',';
							}
							$query .= ' ' . $requestParams['LIMIT'] . ' ';
						}
						if (isset($requestParams['JOIN'])){
							$query = array('QUERY' => $query, 'JOIN' => $requestParams['JOIN']);
						}
					}

					// 読み込み
					debug('REST '.var_export($query, TRUE));
					debug('REST '.var_export($binds, TRUE));
					$Model->load($query, $binds);
					if($Model->count > 0){
						do {
							$resources[] = $this->_convertArrayFromModel($Model);
							// DEEP-REST IDに紐づく関連テーブルのレコード参照
							if(TRUE === $isDeepModel){
								foreach($deepModels as $key => $val){
									$id = $resources[count($resources)-1][$key];
									if(0 < (int)$id && 0 < strlen($id)){
										// DEEPは有効なIDの値の時だけ
										$deepResource = $val.'/'.$id;
										$field = str_replace('_id', '', $key);
										if($this->authUserIDFieldName == $key){
											$field = $val;
										}
										if(TRUE === $this->restResource['me']  && strtolower($val) != strtolower($this->AuthUser->tableName)){
											// meリソース参照を継承
											$deepResource = 'me/'.$deepResource;
										}
										debug(__LINE__.'deep???'.$deepResource.'&'.$key.'&field='.$field);
										// deepRESTを実行し、IDの取得をする
										$DeepREST = new REST();
										$DeepREST->AuthUser = $this->AuthUser;
										$DeepREST->AuthDevice = $this->AuthDevice;
										$DeepREST->authUserID = $this->authUserID;
										$DeepREST->authUserIDFieldName = $this->authUserIDFieldName;
										$DeepREST->authUserQuery = $this->authUserQuery;
										// リスト参照はDEEP-RESTに継承する
										$DeepREST->rootREST = FALSE;
										$DeepREST->restResourceListed = $this->restResourceListed;
										$resources[count($resources)-1][$field] = $DeepREST->execute($deepResource);
									}
								}
							}
						} while (FALSE !== $Model->next());
					}
				}
			}
		}
		catch (Exception $Exception){
			// リソースが存在しない
			$this->httpStatus = 404;
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}
		return $resources;
	}

	/**
	 * POSTメソッド リソースの新規作成、更新、インクリメント、デクリメント(冪等性を強制しません)
	 * XXX モデルの位置付けが、テーブルリソースで無い場合は、継承して、RESTの”冪等性”に従って実装して下さい
	 * @return mixed 成功時は最新のリソース配列 失敗時はFALSE
	 */
	public function post($argRequestParams = NULL){
		return $this->put($argRequestParams);
	}

	/**
	 * PUTメソッド リソースの新規作成、更新(冪等性を持ちます)
	 * XXX モデルの位置付けが、テーブルリソースで無い場合は、継承して、RESTの”冪等性”に従って実装して下さい
	 * @return mixed 成功時は最新のリソース配列 失敗時はFALSE
	 */
	public function put($argRequestParams = NULL){
		$this->_init();
		$requestParams = array();
		$resources = FALSE;
		if(NULL === $argRequestParams){
			$requestParams = $this->getRequestParams();
		}
		else {
			$requestParams = $argRequestParams;
		}
		debug('PUT param=');
		debug(array_keys($requestParams));
		if(isset($requestParams['datas']) && isset($requestParams['datas'][0])){
			// 配列のPOSTはリカーシブルで処理をする
			for($requestIdx=0; $requestIdx < count($requestParams['datas']); $requestIdx++){
				$tmpRes = $this->put($requestParams['datas'][$requestIdx]);
				if(is_array($tmpRes) && isset($tmpRes[0])){
					$resources[$requestIdx] = $tmpRes[0];
				}
				else {
					return FALSE;
				}
			}
		}
		else{
			// 更新を行うリソースを特定する
			$baseQuery = ' 1=1 ';
			$baseBinds = NULL;
			if(TRUE === $this->restResource['me']){
				// 認証ユーザーのリソース指定
				// bind使うので自力で組み立てる
				$baseQuery = ' `' . $this->authUserIDFieldName . '` = :' . $this->authUserIDFieldName. ' ';
				$baseBinds = array($this->authUserIDFieldName => $this->authUserID);
			}
			// リソースの更新
			// XXX 因みに更新はDEEP指定されていてもDEEPしない！
			if(NULL !== $this->restResource['ids'] && count($this->restResource['ids']) >= 1){
				// id指定でループする
				for($IDIdx = 0; $IDIdx < count($this->restResource['ids']); $IDIdx++){
					// 空のモデルを先ず作る
					try{
						if(TRUE === $this->restResource['me'] && NULL !== $this->AuthUser && is_object($this->AuthUser) && strtolower($this->restResourceModel) == strtolower($this->AuthUser->tableName) && $this->restResource['ids'][$IDIdx] == $this->AuthUser->pkeyName){
							// 自分自身のAuthモデルに対しての処理とする
							$Model = $this->AuthUser;
							$fields = $Model->getFieldKeys();
							if(TRUE === $this->restResource['me'] && FALSE === in_array($this->authUserIDFieldName, $fields)){
								// フィールドが無いなら$baseQueryを再初期化
								$baseQuery = ' 1=1 ';
								$baseBinds = NULL;
							}
						}
						else {
							$Model = $this->_getModel($this->restResourceModel);
							$fields = $Model->getFieldKeys();
							if(TRUE === $this->restResource['me'] && FALSE === in_array($this->authUserIDFieldName, $fields)){
								// フィールドが無いなら$baseQueryを再初期化
								$baseQuery = ' 1=1 ';
								$baseBinds = NULL;
							}
							$query = $baseQuery . ' AND `' . $Model->pkeyName . '` = :' . $Model->pkeyName . ' ';
							$binds = $baseBinds;
							if(NULL === $binds){
								$binds = array();
							}
							$binds[$Model->pkeyName] = $this->restResource['ids'][$IDIdx];
							// 読み込み
							debug($query);
							debug($binds);
							$Model->load($query, $binds);
						}
					}
					catch (Exception $Exception){
						// リソースが存在しない
						$this->httpStatus = 404;
						throw new RESTException($Exception->getMessage(), $this->httpStatus);
						break;
					}
					// 最初の一回目はバリデーションを必ず実行
					if(0 === $IDIdx){
						$datas = array();
						if(FALSE === in_array($this->authUserIDFieldName, $fields)){
							// フィールドが無いなら$baseQueryを再初期化
							$baseQuery = ' 1=1 ';
							$baseBinds = NULL;
						}
						// オートバリデート
						try{
							for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
								if(isset($requestParams[$fields[$fieldIdx]])){
									try{
										// XXX intのincrementとdecrimentは許可する
										if(FALSE === ('int' === $Model->describes[$fields[$fieldIdx]]['type'] && TRUE === ('increment' === strtolower($requestParams[$fields[$fieldIdx]]) || 'decrement' === strtolower($requestParams[$fields[$fieldIdx]])))){
											// exec系以外はオートバリデート
											$Model->validate($fields[$fieldIdx], $requestParams[$fields[$fieldIdx]]);
										}
										// バリデートに成功したので更新値として認める
										$datas[$fields[$fieldIdx]] = $requestParams[$fields[$fieldIdx]];
									}
									catch (Exception $Exception){
										// バリデーションエラー(必須パラメータチェックエラー)
										$this->httpStatus = 400;
										throw new RESTException($Exception->getMessage(), $this->httpStatus);
										break;
									}
								}
								elseif($fields[$fieldIdx] == $this->restResourceCreateDateKeyName && TRUE !== (0 < strlen($Model->{$this->restResourceCreateDateKeyName}))){
									// データ作成日付の自動補完
									$datas[$fields[$fieldIdx]] = self::$nowGMT;
								}
								elseif($fields[$fieldIdx] == $this->restResourceModifyDateKeyName){
									// データ更新日付の自動補完
									$datas[$fields[$fieldIdx]] = self::$nowGMT;
								}
								elseif($fields[$fieldIdx] == $Model->pkeyName){
									// Pkeyも入れえておく(複合キーの為の処理)
									$datas[$fields[$fieldIdx]] = $this->restResource['ids'][$IDIdx];
								}
								elseif($fields[$fieldIdx] == $this->authUserIDFieldName){
									// 自分自身のIDを入れる
									$datas[$fields[$fieldIdx]] = $this->authUserID;
								}
								// Filterがあったらフィルター処理をする
								$filerName = str_replace(' ', '', ucwords(str_replace('_', ' ', $this->restResourceModel. ' '. $fields[$fieldIdx]))) . 'Filter';
								debug('$filerName='.$filerName);
								if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
									$filterClass = MVCCore::loadMVCFilter($filerName);
									$Filter = new $filterClass();
									$Filter->REST = $this;
									$Filter->Model = $Model;
									if(!isset($datas[$fields[$fieldIdx]]) ){
										// 初期化
										$datas[$fields[$fieldIdx]] = NULL;
										if(0 < strlen($Model->{$fields[$fieldIdx]})){
											$datas[$fields[$fieldIdx]] = $Model->{$fields[$fieldIdx]};
										}
									}
									debug('original value='.$datas[$fields[$fieldIdx]]);
									$filterMethod = 'filter'.ucfirst(strtolower($_SERVER['REQUEST_METHOD']));
									$datas[$fields[$fieldIdx]] = $Filter->$filterMethod($datas[$fields[$fieldIdx]]);
									debug('$filered value='.$datas[$fields[$fieldIdx]]);
								}
							}
						}
						catch (Exception $Exception){
							throw new RESTException($Exception->getMessage(), $this->httpStatus);
							break;
						}
					}
					// POSTに従ってModelを更新する
					$Model->save($datas);
					// 更新の完了した新しいモデルのデータをレスポンスにセット
					$resources[] = $this->_convertArrayFromModel($Model);
				}
			}
			// リソースの新規作成
			else{
				try{
					if(TRUE === $this->restResource['me'] && NULL !== $this->AuthUser && is_object($this->AuthUser) && strtolower($this->restResourceModel) == strtolower($this->AuthUser->tableName)){
						// 自分自身のAuthモデルに対しての処理とする
						$Model = $this->AuthUser;
					}
					else {
						$Model = $this->_getModel($this->restResourceModel);
					}
					$datas = array();
					$isDeepModel = FALSE;
					$deepDatas = array();
					$fields = $Model->getFieldKeys();
					if(TRUE === $this->restResource['me'] && FALSE === in_array($this->authUserIDFieldName, $fields)){
						// フィールドが無いなら$baseQueryを再初期化
						$baseQuery = ' 1=1 ';
						$baseBinds = NULL;
					}
				}
				catch (Exception $Exception){
					// リソースが存在しない
					$this->httpStatus = 404;
					throw new RESTException($Exception->getMessage(), $this->httpStatus);
				}
				// オートバリデート
				for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
					if(isset($requestParams[$fields[$fieldIdx]])){
						try{
							// XXX intのincrementとdecrimentは許可する
							if(FALSE === ('int' === $Model->describes[$fields[$fieldIdx]]['type'] && TRUE === ('increment' === strtolower($requestParams[$fields[$fieldIdx]]) || 'decrement' === strtolower($requestParams[$fields[$fieldIdx]])))){
								// exec系以外はオートバリデート
								$Model->validate($fields[$fieldIdx], $requestParams[$fields[$fieldIdx]]);
							}
							// バリデートに成功したので更新値として認める
							$datas[$fields[$fieldIdx]] = $requestParams[$fields[$fieldIdx]];
						}
						catch (Exception $Exception){
							// バリデーションエラー(必須パラメータチェックエラー)
							$this->httpStatus = 400;
							throw new RESTException($Exception->getMessage(), $this->httpStatus);
							break;
						}
					}
					// DEEP-REST IDに紐づく関連テーブルのレコード作成・更新
					elseif(TRUE === $this->deepRESTMode && (strlen($fields[$fieldIdx]) -3) === strpos($fields[$fieldIdx], '_id') && $this->authUserIDFieldName != $fields[$fieldIdx]){
						$deepResource = substr($fields[$fieldIdx], 0, -3);
						$deepResourcePath = $deepResource;
						if(TRUE === $this->restResource['me']){
							$deepResourcePath = 'me/'.$deepResource;
						}
						debug(__LINE__.'deep??'.$deepResourcePath.' & '.$this->authUserIDFieldName.' & '.$fields[$fieldIdx].' & '.(strlen($fields[$fieldIdx]) -3).' & '.strpos($fields[$fieldIdx], '_id'));
						$isDeepModel = TRUE;
						try{
							$deepModel = $this->_getModel($deepResource);
						}
						catch(Exception $Exception){
							$isDeepModel = FALSE;
						}
						if(TRUE === $isDeepModel){
							// deepRESTを実行し、IDの取得をする
							$DeepREST = new REST();
							$DeepREST->AuthUser = $this->AuthUser;
							$DeepREST->AuthDevice = $this->AuthDevice;
							$DeepREST->authUserID = $this->authUserID;
							$DeepREST->authUserIDFieldName = $this->authUserIDFieldName;
							$DeepREST->authUserQuery = $this->authUserQuery;
							$DeepREST->rootREST = FALSE;
							$res = $DeepREST->execute($deepResourcePath, $requestParams);
							$datas[$fields[$fieldIdx]] = $res[0]['id'];
							$deepDatas[$deepResource] = $res;
						}
					}
					// DEEP-REST 自身のIDの自動補完
					elseif(TRUE === $this->deepRESTMode && $this->authUserIDFieldName == $fields[$fieldIdx]) {
						// ログインIDの自動補完
						$datas[$fields[$fieldIdx]] = $this->authUserID;
					}
					elseif($fields[$fieldIdx] == $this->restResourceCreateDateKeyName && TRUE !== (0 < strlen($Model->{$this->restResourceCreateDateKeyName}))){
						// データ作成日付の自動補完
						$datas[$fields[$fieldIdx]] = self::$nowGMT;
					}
					elseif($fields[$fieldIdx] == $this->restResourceModifyDateKeyName){
						// データ更新日付の自動補完
						$datas[$fields[$fieldIdx]] = self::$nowGMT;
					}
					// Filterがあったらフィルター処理をする
					$filerName = str_replace(' ', '', ucwords(str_replace('_', ' ', $this->restResourceModel. ' '. $fields[$fieldIdx]))) . 'Filter';
					debug('$filerName='.$filerName);
					try {
						if(FALSE !== MVCCore::loadMVCFilter($filerName, TRUE)){
							$filterClass = MVCCore::loadMVCFilter($filerName);
							debug($filterClass);
							$Filter = new $filterClass();
							$Filter->REST = $this;
							$Filter->Model = $Model;
							if(!isset($datas[$fields[$fieldIdx]]) ){
								// 初期化
								$datas[$fields[$fieldIdx]] = NULL;
								if(0 < strlen($Model->{$fields[$fieldIdx]})){
									$datas[$fields[$fieldIdx]] = $Model->{$fields[$fieldIdx]};
								}
							}
							debug('original value='.$datas[$fields[$fieldIdx]]);
							$filterMethod = 'filter'.ucfirst(strtolower($_SERVER['REQUEST_METHOD']));
							$datas[$fields[$fieldIdx]] = $Filter->$filterMethod($datas[$fields[$fieldIdx]]);
							debug('$filered value='.$datas[$fields[$fieldIdx]]);
						}
					}
					catch (Exception $Exception){
						throw new RESTException($Exception->getMessage(), $this->httpStatus);
						break;
					}
				}
				// POSTに従ってModelを作成する
				$Model->save($datas);
				// 更新の完了した新しいモデルのデータをレスポンスにセット
				$resources[] = $this->_convertArrayFromModel($Model);
				if(TRUE === $isDeepModel && 0 < count($deepDatas)){
					foreach($deepDatas as $key => $val){
						$resources[count($resources)-1][$key] = $val;
					}
				}
			}
		}
		return $resources;
	}

	/**
	 * DELETEメソッド
	 * XXX モデルの位置付けが、テーブルリソースで無い場合は、継承してRESTの”冪等性”に従って実装して下さい(冪等性を持ちます)
	 * @return boolean
	 */
	public function delete(){
		$requestParams = $this->getRequestParams();
		$baseQuery = ' 1=1 ';
		$baseBinds = NULL;
		$isDeepModel = FALSE;
		$deepModels = array();
		if($this->restResource['me'] && NULL !== $this->AuthUser && is_object($this->AuthUser)){
			// 認証ユーザーのリソース指定
			// bind使うので自力で組み立てる
			$baseQuery = ' `' . $this->authUserIDFieldName . '` = :' . $this->authUserIDFieldName. ' ';
			$baseBinds = array($this->authUserIDFieldName => $this->authUserID);
		}
		// モデルリソースと特定条件を決める
		try{
			// 空のモデルを先ず作る
			$Model = $this->_getModel($this->restResourceModel);
			$fields = $Model->getFieldKeys();
			// REQUESTされているパラメータは条件分に利用する
			for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
				if(isset($requestParams[$fields[$fieldIdx]])){
					// GETパラメータでbaseクエリを書き換える
					if(is_array($requestParams[$fields[$fieldIdx]]) && isset($requestParams[$fields[$fieldIdx]]['mark']) && isset($requestParams[$fields[$fieldIdx]]['value'])){
						// =以外の条件を指定したい場合の特殊処理
						$baseQuery .= ' AND `' . $fields[$fieldIdx] . '` ' . $requestParams[$fields[$fieldIdx]]['mark'] . ' :' . $fields[$fieldIdx] . ' ';
						$bindValue = $requestParams[$fields[$fieldIdx]]['value'];
					}
					else{
						$baseQuery .= ' AND `' . $fields[$fieldIdx] . '` = :' . $fields[$fieldIdx] . ' ';
						$bindValue = $requestParams[$fields[$fieldIdx]];
					}
					if(NULL === $baseBinds){
						$baseBinds = array();
					}
					$baseBinds[$fields[$fieldIdx]] = $bindValue;
				}
				// DEEP-REST用のテーブルとフィールドの一覧をストックしておく
				if(TRUE === $this->deepRESTMode && TRUE === (TRUE === $this->restResource['me'] || $this->authUserIDFieldName != $fields[$fieldIdx])){
					$deepBaseResource = NULL;
					if(0 < strlen($this->restResourceRelayPrefix) && 0 === strpos($fields[$fieldIdx], $this->restResourceRelayPrefix) && (strlen($this->restResourceRelayPrefix.$fields[$fieldIdx]) -3) === strpos($this->restResourceRelayPrefix.$fields[$fieldIdx], '_id')){
						$deepBaseResource = substr(substr($fields[$fieldIdx], 0, -3), strlen($this->restResourceRelayPrefix));
					}
					else if((strlen($fields[$fieldIdx]) - (3 + strlen($this->restResourceRelaySuffix))) === strpos($fields[$fieldIdx], '_id'.$this->restResourceRelaySuffix)){
						$deepBaseResource = substr($fields[$fieldIdx], 0, - (3 + strlen($this->restResourceRelaySuffix)));
					}
					else if((strlen($fields[$fieldIdx]) -3) === strpos($fields[$fieldIdx], '_id')){
						$deepBaseResource = substr($fields[$fieldIdx], 0, -3);
					}
					if(NULL !== $this->restResourceUserTableName && $this->authUserIDFieldName == $fields[$fieldIdx]){
						$deepBaseResource = $this->restResourceUserTableName;
					}
					if(NULL !== $deepBaseResource && 0 < strlen($deepBaseResource)){
						debug(__LINE__.'deep??'.$deepBaseResource.'&'.$this->authUserIDFieldName.'&'.$fields[$fieldIdx]);
						$isDeepModel = TRUE;
						$deepModels[$fields[$fieldIdx]] = $deepBaseResource;
					}
				}
				// GETパラメータでbaseクエリを書き換える
				if(is_array($requestParams[$fields[$fieldIdx]]) && isset($requestParams[$fields[$fieldIdx]]['mark']) && isset($requestParams[$fields[$fieldIdx]]['value'])){
					// =以外の条件を指定したい場合の特殊処理
					$baseQuery .= ' AND `' . $fields[$fieldIdx] . '` ' . $requestParams[$fields[$fieldIdx]]['mark'] . ' :' . $fields[$fieldIdx] . ' ';
					$bindValue = $requestParams[$fields[$fieldIdx]]['value'];
				}
			}
			if(NULL === $baseBinds){
				$baseBinds = array();
			}
		}
		catch (Exception $Exception){
			// リソースが存在しない
			$this->httpStatus = 404;
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}
		// リソースの削除
		if(NULL !== $this->restResource['ids'] && count($this->restResource['ids']) >= 1){
			$query = $baseQuery;
			$binds = $baseBinds;
			debug($query);
			// id指定でループする
			for($IDIdx = 0; $IDIdx < count($this->restResource['ids']); $IDIdx++){
				if(strlen($Model->pkeyName) > 1){
					if(FALSE === strpos($query, '`' . $Model->pkeyName . '` = :' . $Model->pkeyName . ' ')){
						$query = $query . ' AND `' . $Model->pkeyName . '` = :' . $Model->pkeyName . ' ';
					}
					$binds[$Model->pkeyName] = $this->restResource['ids'][$IDIdx];
				}
				// 読み込み
				$Model->load($query, $binds);
				if((int)$Model->count > 0){
					// リソースの削除を実行
					$Model->remove();
					debug('removed!');
				}
			}
		}
		else{
			// 条件一致した全てのリソースを削除する
			$query = $baseQuery;
			$binds = $baseBinds;
			// 読み込み
			$Model->load($query, $binds);
			if($Model->count > 0){
				// リソースの削除を実行
				do {
					$Model->remove();
				} while (false !== $Model->next());
			}
		}
		return TRUE;
	}

	/**
	 * HEADメソッド
	 * @return boolean
	 */
	public function head(){
		$count = '0';
		$requestParams = $this->getRequestParams();
		$baseQuery = ' 1=1 ';
		$baseBinds = NULL;
		$rules = array('rules'=>array());;
		try{
			if(TRUE === $this->restResource['me'] && NULL !== $this->AuthUser && is_object($this->AuthUser) && strtolower($this->restResourceModel) == strtolower($this->AuthUser->tableName)){
				// 自分自身のAuthモデルに対しての処理とする
				$Model = $this->AuthUser;
				$fields = $Model->getFieldKeys();
				$count = '1';
			}
			else {
				$Model = $this->_getModel($this->restResourceModel);
				$fields = $Model->getFieldKeys();
				if(TRUE === $this->restResource['me']){
					// 認証ユーザーのリソース指定
					// bind使うので自力で組み立てる
					$baseQuery = ' `' . $Model->tableName . '`.`' . $this->authUserIDFieldName . '` = :' . $this->authUserIDFieldName . ' ';
					$baseBinds = array($this->authUserIDFieldName => $this->authUserID);
				}
				// REQUESTされているパラメータは条件文に利用する
				for($fieldIdx = 0; $fieldIdx < count($fields); $fieldIdx++){
					if(isset($requestParams[$fields[$fieldIdx]])){
						// GETパラメータでbaseクエリを書き換える
						if(is_array($requestParams[$fields[$fieldIdx]]) && isset($requestParams[$fields[$fieldIdx]]['mark']) && isset($requestParams[$fields[$fieldIdx]]['value'])){
							// =以外の条件を指定したい場合の特殊処理
							$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` ' . $requestParams[$fields[$fieldIdx]]['mark'] . ' :' . $fields[$fieldIdx] . ' ';
							$bindValue = $requestParams[$fields[$fieldIdx]]['value'];
						}
						else{
							$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` = :' . $fields[$fieldIdx] . ' ';
							$bindValue = $requestParams[$fields[$fieldIdx]];
						}
						if(NULL === $baseBinds){
							$baseBinds = array();
						}
						$baseBinds[$fields[$fieldIdx]] = $bindValue;
					}
					else if(isset($requestParams['LIKE']) && strlen($requestParams['LIKE']) > 0){
						$baseQuery .= ' OR `' . $Model->tableName . '`.`' . $fields[$fieldIdx] . '` LIKE \'%'.addslashes($requestParams['LIKE']).'%\' ';
					}
					// 有効フラグの自動参照制御
					if($this->restResourceAvailableKeyName == $fields[$fieldIdx]){
						$baseQuery .= ' AND `' . $Model->tableName . '`.`' . $this->restResourceAvailableKeyName . '` = :' . $fields[$fieldIdx] . ' ';
						$baseBinds[$fields[$fieldIdx]] = '1';
					}
				}
				if(TRUE === $this->rootREST && isset($requestParams['QUERY']) && strlen($requestParams['QUERY']) > 0){
					// XXX SQLインジェクション対策を後でTXに相談！
					$baseQuery .= ' AND ' . $requestParams['QUERY'] . ' ';
				}
				if(FALSE !== strpos($baseQuery, '1=1  OR ')){
					$baseQuery = str_replace('1=1  OR ', 'WHERE ', $baseQuery);
				}
				$query = $baseQuery;
				$binds = $baseBinds;
				// GROUP句指定があれば付け足す
				if(TRUE === $this->rootREST && isset($requestParams['GROUP']) && 0 < strlen($requestParams['GROUP'])){
					$query .= ' GROUP BY ' . $requestParams['GROUP'] . ' ';
				}
				// ORDER句指定があれば付け足す
				if(isset($requestParams['ORDER']) && 0 < strlen($requestParams['ORDER'])){
					$query .= ' ORDER BY ' . $requestParams['ORDER'] . ' ';
				}
				elseif(in_array($this->restResourceModifyDateKeyName, $fields)) {
					$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceModifyDateKeyName . '` DESC ';
				}
				elseif(in_array($this->restResourceCreateDateKeyName, $fields)) {
					$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $this->restResourceCreateDateKeyName . '` DESC ';
				}
				else {
					$query .= ' ORDER BY `' . $Model->tableName . '`.`' . $Model->pkeyName . '` DESC ';
				}
				if(TRUE === $this->rootREST && isset($requestParams['JOIN'])){
					$query = array('QUERY' => $query, 'JOIN' => $requestParams['JOIN']);
				}
				debug($query);
				$Model->load($query, $binds);
				$count = (string)$Model->count;
				if('' === $count){
					$count = '0';
				}
			}
			// JSバリデートで使えるようのRuleオブジェクトをおまけで作って上げる
			foreach($Model->describes as $key => $val){
				$rules['rules'][$key] = array('required'=>(($val['pkey'] || $val['null'])? FALSE : TRUE), 'email'=>((FALSE === strpos(strtolower($key),'mail')) ? FALSE : TRUE), 'url'=>((FALSE === strpos(strtolower($key),'url')) ? FALSE : TRUE));
				$rules['rules'][$key]['digits'] = FALSE;
				if(isset($val['type']) && 'int' === $val['type']){
					$rules['rules'][$key]['digits'] = TRUE;
				}
				if(isset($val['length'])){
					$rules['rules'][$key]['maxlength']=(int)$val['length'];
					$rules['rules'][$key]['minlength'] = (int)$val['length'];
				}
				if(isset($val['min-length'])){
					$rules['rules'][$key]['minlength']=(int)$val['min-length'];
				}
				$Model->describes[$key]['calender'] = FALSE;
				if($this->restResourceCreateDateKeyName == $key || $this->restResourceModifyDateKeyName == $key || FALSE !== strpos(strtolower($key),'date')){
					// ヘッダーでは日付フィールドである事を明確にして置く
					$Model->describes[$key]['calender'] = TRUE;
				}
			}
		}
		catch (Exception $Exception){
			// リソースが存在しない
			$this->httpStatus = 404;
			throw new RESTException($Exception->getMessage(), $this->httpStatus);
		}

		// 定義一覧をヘッダに詰めて返す
		return array('describes' => $Model->describes, 'count'=>$count, 'rules'=>$rules, 'comment'=>$Model->tableComment);
	}
}

?>