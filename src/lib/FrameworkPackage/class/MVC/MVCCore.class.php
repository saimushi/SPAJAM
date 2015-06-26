<?php

/**
 * MVCモデルをフレームワークとして提供するクラス
 */
class MVCCore {
	public static $appVersion = NULL;
	public static $appDispayVersion = NULL;
	public static $outputType;
	public static $deviceType = NULL;
	public static $appleReviewd = FALSE;
	public static $maintenanceNow = FALSE;
	public static $mustAppVersioned = TRUE;
	public static $appNotifyMessage = NULL;
	public static $appBadgeNum = NULL;
	public static $accessed = NULL;
	public static $CurrentController;
	public static $flowXMLBasePath = '';
	public static $flowXMLPaths;
	public static $isConsoleMode = FALSE;
	
	/**
	 * WebインターフェースでのMVCのメイン処理
	 *
	 * @param
	 *        	boolean DIコンテナで実行するかどうか
	 * @throws Exception
	 */
	public static function webmain($argFlowXMLBasePath = '') {
		$ProjectConfigure = NULL;
		if (defined ( 'PROJECT_NAME' ) && strlen ( PROJECT_NAME ) > 0 && class_exists ( PROJECT_NAME . 'Configure' )) {
			$ProjectConfigure = PROJECT_NAME . 'Configure';
		}
		debug ( 'mvccore $ProjectConfigure=' . var_export ( $ProjectConfigure, TRUE ) );
		
		self::$accessed = Utilities::date ( 'Y-m-d H:i:s', NULL, NULL, 'GMT' );
		
		self::$flowXMLBasePath = $argFlowXMLBasePath;
		
		logging ( $_REQUEST, 'post' );
		logging ( $_COOKIE, 'cookie' );
		logging ( $_SERVER, 'server' );
		debug ( 'mvccore requestParam=' . var_export ( $_REQUEST, TRUE ) );
		debug ( 'mvccore cookie=' . var_export ( $_COOKIE, TRUE ) );
		
		$actionMethodName = 'execute';
		if (isset ( $_GET ['_a_'] ) && strlen ( $_GET ['_a_'] ) > 0) {
			$actionMethodName = $_GET ['_a_'];
		}
		// $_GET['_o_']がコントローラで消されてしまうかも知れないので一回取っておく
		// 正式なOutputType定義はコントローラ処理終了後
		$outputType = 'html';
		if (isset ( $_GET ['_o_'] ) && strlen ( $_GET ['_o_'] ) > 0) {
			$outputType = $_GET ['_o_'];
		}
		self::$outputType = $outputType;
		// アプリケーション情報の取得
		$serverUserAgent = $_SERVER ['HTTP_USER_AGENT'];
		$appleReviewd = FALSE;
		$deviceType = 'PC';
		if (false != strpos ( strtolower ( $serverUserAgent ), 'iphone' )) {
			$deviceType = 'iPhone';
		} elseif (false != strpos ( strtolower ( $serverUserAgent ), 'ipad' )) {
			$deviceType = 'iPad';
		} elseif (false != strpos ( strtolower ( $serverUserAgent ), 'ipod' )) {
			$deviceType = 'iPod';
		} elseif (false != strpos ( strtolower ( $serverUserAgent ), 'android' )) {
			$deviceType = 'Android';
		}
		debug ( 'mvccore deviceType=' . $deviceType );
		
		// XXX MUST_IOSAPP_VERSION_FLAG_FILEこの辺のフラグファイルをプロジェクト毎に設定出来るように拡張
		// アプリの必須バージョンチェック
		$updateURL = NULL;
		if (isset ( $_GET ['_v_'] )) {
			debug ( 'mvccore appversion=' . $_GET ['_v_'] );
			if (NULL !== $ProjectConfigure && TRUE === defined ( $ProjectConfigure . '::MUST_IOSAPP_VERSION_FLAG_FILE' ) && ('iPhone' === $deviceType || 'iPad' === $deviceType || 'iPod' === $deviceType)) {
				debug ( 'mvccore ' . $ProjectConfigure::MUST_IOSAPP_VERSION_FLAG_FILE );
				if (TRUE === is_file ( $ProjectConfigure::MUST_IOSAPP_VERSION_FLAG_FILE )) {
					debug ( 'mvccore ' . $ProjectConfigure::MUST_IOSAPP_VERSION_FLAG_FILE );
					$mustVirsionStr = @file_get_contents ( $ProjectConfigure::MUST_IOSAPP_VERSION_FLAG_FILE );
					if (0 < strlen ( $mustVirsionStr )) {
						$matches = NULL;
						if (preg_match ( '/([0-9.]+)/', $mustVirsionStr, $matches )) {
							$mustVirsionNum = ( int ) str_replace ( '.', '', $matches [1] );
							debug ( 'mvccore mustVirsionNum=' . $mustVirsionNum );
							debug ( 'mvccore nowversion=' . ( int ) str_replace ( '.', '', $_GET ['_v_'] ) );
							if ($mustVirsionNum > ( int ) str_replace ( '.', '', $_GET ['_v_'] )) {
								// 必須バージョンに達していない
								self::$mustAppVersioned = FALSE;
								if (TRUE === defined ( $ProjectConfigure . '::IOS_UPDATE_URL' ) && 0 < strlen ( $ProjectConfigure::IOS_UPDATE_URL )) {
									$updateURL = $ProjectConfigure::IOS_UPDATE_URL;
								} else if (TRUE === defined ( $ProjectConfigure . '::IOS_DOWNLOAD_URL' ) && 0 < strlen ( $ProjectConfigure::IOS_DOWNLOAD_URL )) {
									$updateURL = $ProjectConfigure::IOS_DOWNLOAD_URL;
								}
							}
						}
					}
				}
			} elseif (TRUE === Configure::constant ( 'MUST_IOSAPP_VERSION_FLAG_FILE' ) && ('iPhone' === $deviceType || 'iPad' === $deviceType || 'iPod' === $deviceType)) {
				if (TRUE === is_file ( Configure::MUST_IOSAPP_VERSION_FLAG_FILE )) {
					debug ( 'mvccore ' . Configure::MUST_IOSAPP_VERSION_FLAG_FILE );
					$mustVirsionStr = @file_get_contents ( Configure::MUST_IOSAPP_VERSION_FLAG_FILE );
					if (0 < strlen ( $mustVirsionStr )) {
						$matches = NULL;
						if (preg_match ( '/([0-9.]+)/', $mustVirsionStr, $matches )) {
							$mustVirsionNum = ( int ) str_replace ( '.', '', $matches [1] );
							debug ( 'mvccore mustVirsionNum=' . $mustVirsionNum );
							debug ( 'mvccore nowversion=' . ( int ) str_replace ( '.', '', $_GET ['_v_'] ) );
							if ($mustVirsionNum > ( int ) str_replace ( '.', '', $_GET ['_v_'] )) {
								// 必須バージョンに達していない
								self::$mustAppVersioned = FALSE;
								if (TRUE === defined ( Configure . '::IOS_UPDATE_URL' ) && 0 < strlen ( Configure::IOS_UPDATE_URL )) {
									$updateURL = Configure::IOS_UPDATE_URL;
								} else if (TRUE === defined ( Configure . '::IOS_DOWNLOAD_URL' ) && 0 < strlen ( Configure::IOS_DOWNLOAD_URL )) {
									$updateURL = Configure::IOS_DOWNLOAD_URL;
								}
							}
						}
					}
				}
			}
			if (NULL !== $ProjectConfigure && TRUE === defined ( $ProjectConfigure . '::MUST_ANDROIDAPP_VERSION_FLAG_FILE' ) && ('android' === $deviceType || 'Android' === $deviceType)) {
				if (TRUE === is_file ( $ProjectConfigure::MUST_ANDROIDAPP_VERSION_FLAG_FILE )) {
					debug ( 'mvccore ' . $ProjectConfigure::MUST_ANDROIDAPP_VERSION_FLAG_FILE );
					$mustVirsionStr = @file_get_contents ( $ProjectConfigure::MUST_ANDROIDAPP_VERSION_FLAG_FILE );
					if (0 < strlen ( $mustVirsionStr )) {
						$matches = NULL;
						if (preg_match ( '/([0-9.]+)/', $mustVirsionStr, $matches )) {
							$mustVirsionNum = ( int ) str_replace ( '.', '', $matches [1] );
							debug ( 'mvccore mustVirsionNum=' . $mustVirsionNum );
							debug ( 'mvccore nowversion=' . ( int ) str_replace ( '.', '', $_GET ['_v_'] ) );
							if ($mustVirsionNum > ( int ) str_replace ( '.', '', $_GET ['_v_'] )) {
								// 必須バージョンに達していない
								self::$mustAppVersioned = FALSE;
								if (TRUE === defined ( $ProjectConfigure . '::ANDROID_UPDATE_URL' ) && 0 < strlen ( $ProjectConfigure::ANDROID_UPDATE_URL )) {
									$updateURL = $ProjectConfigure::ANDROID_UPDATE_URL;
								} else if (TRUE === defined ( $ProjectConfigure . '::ANDROID_DOWNLOAD_URL' ) && 0 < strlen ( $ProjectConfigure::ANDROID_DOWNLOAD_URL )) {
									$updateURL = $ProjectConfigure::ANDROID_DOWNLOAD_URL;
								}
							}
						}
					}
				}
			} else if (TRUE === Configure::constant ( 'MUST_ANDROIDAPP_VERSION_FLAG_FILE' ) && ('android' === $deviceType || 'Android' === $deviceType)) {
				if (TRUE === is_file ( Configure::MUST_ANDROIDAPP_VERSION_FLAG_FILE )) {
					debug ( 'mvccore ' . Configure::MUST_ANDROIDAPP_VERSION_FLAG_FILE );
					$mustVirsionStr = @file_get_contents ( Configure::MUST_ANDROIDAPP_VERSION_FLAG_FILE );
					if (0 < strlen ( $mustVirsionStr )) {
						$matches = null;
						if (preg_match ( '/([0-9.]+)/', $mustVirsionStr, $matches )) {
							$mustVirsionNum = ( int ) str_replace ( '.', '', $matches [1] );
							if ($mustVirsionNum > ( int ) str_replace ( '.', '', $_GET ['_v_'] )) {
								// 必須バージョンに達していない
								self::$mustAppVersioned = FALSE;
								if (TRUE === defined ( Configure . '::ANDROID_UPDATE_URL' ) && 0 < strlen ( Configure::ANDROID_UPDATE_URL )) {
									$updateURL = Configure::ANDROID_UPDATE_URL;
								} else if (TRUE === defined ( Configure . '::ANDROID_DOWNLOAD_URL' ) && 0 < strlen ( Configure::ANDROID_DOWNLOAD_URL )) {
									$updateURL = Configure::ANDROID_DOWNLOAD_URL;
								}
							}
						}
					}
				}
			}
		}
		
		// アップルレビューバージョンの存在チェック
		// if(TRUE === ('iPhone' === $deviceType || 'iPad' === $deviceType || 'iPod' === $deviceType) && isset($_GET['_v_'])){
		// $appReviewFilePath = NULL;
		// if(TRUE === defined($ProjectConfigure.'::APPLE_REVIEW_FLAG_FILE')){
		// $appReviewFilePath = $ProjectConfigure::APPLE_REVIEW_FLAG_FILE;
		// }
		// elseif(TRUE === defined('Configure::APPLE_REVIEW_FLAG_FILE')){
		// $appReviewFilePath = Configure::APPLE_REVIEW_FLAG_FILE;
		// }
		// if(TRUE === is_file($appReviewFilePath.$_GET['_v_'])){
		// debug('mvccore '.Configure::APPLE_REVIEW_FLAG_FILE.$_GET['_v_']);
		// $appleReviewd = TRUE;
		// debug('mvccore isAppleReview');
		// }
		// }
		
		// アプリバージョン
		$version = NULL;
		if (isset ( $_GET ['_v_'] ) && strlen ( $_GET ['_v_'] ) > 0) {
			$version = $_GET ['_v_'];
		}
		debug ( 'mvccore version=' . $version );

		$dispversion = NULL;
		if (isset ( $_GET ['_dv_'] ) && strlen ( $_GET ['_dv_'] ) > 0) {
			$dispversion = $_GET ['_dv_'];
		}
		
		self::$appVersion = $version;
		self::$appDispayVersion = $dispversion;
		self::$deviceType = $deviceType;
		self::$appleReviewd = $appleReviewd;
		
		// 強制メンテナンスモードの判定
		$maintenance = FALSE;
		if (NULL !== $ProjectConfigure && TRUE === defined ( $ProjectConfigure . '::MAINTENANCE_FLAG_FILE' )) {
			debug ( 'mvccore ' . $ProjectConfigure::MAINTENANCE_FLAG_FILE );
			if (TRUE === is_file ( $ProjectConfigure::MAINTENANCE_FLAG_FILE )) {
				$maintenance = TRUE;
			}
		} else if (TRUE === Configure::constant ( 'MAINTENANCE_FLAG_FILE' )) {
			debug ( 'mvccore ' . Configure::MAINTENANCE_FLAG_FILE );
			if (TRUE === is_file ( Configure::MAINTENANCE_FLAG_FILE )) {
				$maintenance = TRUE;
			}
		}
		
		$res = FALSE;
		
		// 実行
		try {
			
			// 強制メンテナンスモードの判定
			if (TRUE === $maintenance && FALSE === self::$appleReviewd) {
				// メンテナンス中(アップルのレビュワーだけは通しておいてしまう！)
				$httpStatus = 503;
				$res = FALSE;
				self::$maintenanceNow = $maintenance;
				throw new Exception ( 'maintenace now.' );
			}
			
			$httpStatus = 200;
			// コントロール対象を取得
			$res = self::loadMVCModule ();
			if (FALSE === $res) {
				// フィルター処理
				if (self::loadMVCFilter ( 'StaticPrependFilter' )) {
					$PrependFilter = new StaticPrependFilter ();
					$allowed = $PrependFilter->execute ();
					if (FALSE === $allowed) {
						// XXX フィルターエラー
						throw new Exception ( 'access denied.' );
					}
					elseif (TRUE !== $allowed){
						$res = $allowed;
					}
				}
				if (FALSE === $res) {
					// ただのhtml表示かも知れないのを調べる
					$paths = parse_url($_SERVER ['REQUEST_URI']);
					debug('DOCUMENT_ROOT='. $_SERVER ['DOCUMENT_ROOT']);
					debug('pasths=');
					debug($paths);
					debug($_SERVER ['DOCUMENT_ROOT'] . 'static/' . $paths ['path']);
					if (isset ( $_SERVER ['DOCUMENT_ROOT'] ) && isset ( $paths ['path'] ) && is_file ( $_SERVER ['DOCUMENT_ROOT'] . $paths ['path'] )) {
						// そのままスタティックファイルとして表示
						$res = file_get_contents ( $_SERVER ['DOCUMENT_ROOT'] . $paths ['path'] );
					}
					elseif (isset ( $_SERVER ['DOCUMENT_ROOT'] ) && isset ( $paths ['path'] ) && is_file ( $_SERVER ['DOCUMENT_ROOT'] . '/static/' . $paths ['path'] )) {
						// そのままスタティックファイルとして表示
						$res = file_get_contents ( $_SERVER ['DOCUMENT_ROOT'] . '/static/' . $paths ['path'] );
					}
					elseif (isset ( $_SERVER ['DOCUMENT_ROOT'] ) && isset ( $paths ['path'] ) && is_file ( $_SERVER ['DOCUMENT_ROOT'] . dirname($paths ['path']) . '/static/' . basename($paths ['path']) )) {
						// そのままスタティックファイルとして表示
						$res = file_get_contents ( $_SERVER ['DOCUMENT_ROOT'] . dirname($paths ['path']) . '/static/' . basename($paths ['path']) );
					}
					elseif (isset ( $_SERVER ['DOCUMENT_ROOT'] ) && isset ( $paths ['path'] ) && is_file ( $_SERVER ['DOCUMENT_ROOT'] . $paths ['path'] . 'index.html' )) {
						// そのままスタティックファイルとして表示
						$res = file_get_contents ( $_SERVER ['DOCUMENT_ROOT'] . $paths ['path'] . 'index.html');
					}
					elseif (isset ( $_SERVER ['DOCUMENT_ROOT'] ) && !isset ( $paths ['path'] ) && is_file ( $_SERVER ['DOCUMENT_ROOT'] . '/static/index.html' )) {
						// そのままスタティックファイルとして表示
						$res = file_get_contents ( $_SERVER ['DOCUMENT_ROOT']  . '/static/index.html');
					} else {
						// エラー
						$httpStatus = 404;
						throw new Exception ( 'controller class faild.' );
					}
				}
				// フィルター処理
				if (self::loadMVCFilter ( 'StaticAppendFilter' )) {
					$AppendFilter = new StaticAppendFilter ();
					$allowed = $AppendFilter->execute ();
					if (FALSE === $allowed) {
						// XXX フィルターエラー
						throw new Exception ( 'access denied.' );
					}
				}
			} else {
				$controlerClassName = $res;
				// フィルター処理
				$allowed = NULL;
				$filres = self::loadMVCFilter ( 'MVCPrependFilter' );
				debug ( 'mvccore ' . $filres );
				if (FALSE !== $filres && 0 < strlen ( $filres )) {
					$PrependFilter = new MVCPrependFilter ();
					$allowed = $PrependFilter->execute ();
					if (FALSE === $allowed) {
						// XXX フィルターエラー
						throw new Exception ( 'access denied.' );
					}
				}
				self::$CurrentController = new $controlerClassName ();
				debug ( 'mvccore method=' . $_SERVER ['REQUEST_METHOD'] );
				if (isset ( $_SERVER ['REQUEST_METHOD'] )) {
					self::$CurrentController->requestMethod = strtoupper ( $_SERVER ['REQUEST_METHOD'] );
				}
				self::$CurrentController->controlerClassName = $controlerClassName;
				self::$CurrentController->outputType = $outputType;
				self::$CurrentController->deviceType = self::$deviceType;
				self::$CurrentController->appVersion = self::$appVersion;
				self::$CurrentController->appleReviewd = self::$appleReviewd;
				self::$CurrentController->mustAppVersioned = self::$mustAppVersioned;
				self::$CurrentController->allowed = $allowed;
				$res = self::$CurrentController->$actionMethodName ();
				if (FALSE === $res) {
					throw new Exception ( $actionMethodName . ' executed faild.' );
				}
				// フィルター処理
				if (self::loadMVCFilter ( 'MVCAppendFilter' )) {
					$AppendFilter = new MVCAppendFilter ();
					$allowed = $AppendFilter->execute ();
					if (FALSE === $allowed) {
						// XXX フィルターエラー
						throw new Exception ( 'access denied.' );
					}
				}
			}
		} catch ( Exception $Exception ) {
			// リターンは強制的にFALSE
			$res = FALSE;
			// statusコードがアレバそれを使う
			if (isset ( self::$CurrentController->httpStatus ) && $httpStatus != self::$CurrentController->httpStatus) {
				$httpStatus = self::$CurrentController->httpStatus;
			} else if (200 === $httpStatus) {
				// インターナルサーバエラー
				$httpStatus = 500;
			}
		}
		
		// Output
		try {
			if (NULL !== self::$accessed) {
				header ( 'Accessed: ' . self::$accessed );
			}
			if (TRUE === self::$maintenanceNow) {
				header ( 'Maintenance: 1' );
			}
			if (FALSE === self::$mustAppVersioned) {
				header ( 'AppMustUpdate: 1' );
				if (isset ( $updateURL ) && NULL !== $updateURL && 0 < strlen ( $updateURL )) {
					header ( 'AppMustUpdateURL: ' . $updateURL );
				}
			}
			if (NULL !== self::$appBadgeNum) {
				header ( 'AppBadgeNum: ' . self::$appBadgeNum );
			}
			if (NULL !== self::$appNotifyMessage) {
				if (is_array ( self::$appNotifyMessage )) {
					self::$appNotifyMessage = json_encode ( self::$appNotifyMessage );
				}
				header ( 'AppNotifyMessage: ' . self::$appNotifyMessage );
			}
			if (200 !== $httpStatus && 201 !== $httpStatus && 202 !== $httpStatus) {
				// 200版以外のステータスコードの場合の出力処理
				header ( 'HTTP', TRUE, $httpStatus );
				if (FALSE === $res && isset ( $Exception )) {
					$html = '';
					if ('json' === $outputType) {
						// exceptionのログ出力
						if (! class_exists ( 'PHPUnit_Framework_TestCase', FALSE )) {
							logging ( $Exception->getMessage () . PATH_SEPARATOR . var_export ( debug_backtrace (), TRUE ), 'backtrace' );
							logging ( $Exception->getMessage (), 'exception' );
						}
						// jsonでエラーメッセージを出力
						header ( 'Content-type: text/javascript; charset=UTF-8' );
						$res = array (
								'error' => $Exception->getMessage () 
						);
						if (isset ( self::$CurrentController->validateError ) && 0 < strlen ( self::$CurrentController->validateError )) {
							$res ['validate_error'] = self::$CurrentController->validateError;
						}
						$res = json_encode ( $res );
						if (TRUE == self::$CurrentController->jsonUnescapedUnicode) {
							$res = unicode_encode ( $res );
							// スラッシュのエスケープをアンエスケープする
							$res = preg_replace ( '/\\\\\//', '/', $res );
						}
						debug ( 'mvccore ' . var_export ( $res, TRUE ) );
						exit ( $res );
					} elseif ('xml' === $outputType) {
						// exceptionのログ出力
						if (! class_exists ( 'PHPUnit_Framework_TestCase', FALSE )) {
							logging ( $Exception->getMessage () . PATH_SEPARATOR . var_export ( debug_backtrace (), TRUE ), 'backtrace' );
							logging ( $Exception->getMessage (), 'exception' );
						}
						// XMLでエラーメッセージを出力
						header ( 'Content-type:Content- type: application/xml; charset=UTF-8' );
						exit ( '<?xml version="1.0" encoding="UTF-8" ?>' . convertObjectToXML ( array (
								'error' => $Exception->getMessage () 
						) ) );
					} elseif ('html' === $outputType) {
						$Tpl = self::loadTemplate ( 'error' );
						if (is_object ( $Tpl )) {
							$dispatch = false;
							$html = $Tpl->execute ();
						}
						// XXX メンテナンス中のhtml振り分けはココで実装！
					}
					_systemError ( 'Exception :' . $Exception->getMessage (), $httpStatus, $html, $Exception->getTrace());
				}
			} else {
				$isBinary = FALSE;
				if (isset ( self::$CurrentController->outputType )) {
					$outputType = self::$CurrentController->outputType;
				}
				if ('html' === $outputType) {
					// htmlヘッダー出力
					header ( 'Content-type: text/html; charset=UTF-8' );
					if (is_array ( $res )) {
						// html出力なのに配列は出力テンプレートの自動判別を試みる
					}
				} elseif ('txt' === $outputType) {
					// textヘッダー出力
					header ( 'Content-type: text/plain; charset=UTF-8' );
					if (is_array ( $res )) {
						$res = var_export ( $res, TRUE );
					}
				} elseif ('json' === $outputType) {
					// jsonヘッダー出力
					header ( 'Content-type: text/javascript; charset=UTF-8' );
					if (is_array ( $res )) {
						$res = json_encode ( $res );
					}
					if (TRUE == self::$CurrentController->jsonUnescapedUnicode) {
						$res = unicode_encode ( $res );
						// スラッシュのエスケープをアンエスケープする
						$res = preg_replace ( '/\\\\\//', '/', $res );
					}
				} elseif ('xml' === $outputType) {
					// jsonヘッダー出力
					header ( 'Content-type:Content- type: application/xml; charset=UTF-8' );
					if (is_array ( $res )) {
						$res = '<?xml version="1.0" encoding="UTF-8" ?>' . convertObjectToXML ( $res );
					}
				} elseif ('csv' === $outputType) {
					// csvヘッダー出力
					header ( 'Content-type: application/octet-stream; charset=SJIS' );
					if (is_array ( $res )) {
						// XXX csvといいつつtsvを吐き出す
						$res = mb_convert_encoding ( convertObjectToCSV ( $res, PHP_TAB ), 'SJIS', 'UTF-8' );
					}
				} elseif ('jpg' === $outputType || 'jpeg' === $outputType) {
					// jpgヘッダー出力
					header ( 'Content-type: image/jpeg' );
					$isBinary = TRUE;
				} elseif ('png' === $outputType) {
					// pngヘッダー出力
					header ( 'Content-type: image/png' );
					$isBinary = TRUE;
				} elseif ('gif' === strtolower ( $outputType )) {
					// gifヘッダー出力
					header ( 'Content-type: image/gif' );
					$isBinary = TRUE;
				} elseif ('bmp' === strtolower ( $outputType )) {
					// bmpヘッダー出力
					header ( 'Content-type: image/bmp' );
					$isBinary = TRUE;
				}
				// 描画処理
				if (TRUE === $isBinary && is_string ( $res )) {
					header ( 'Content-length: ' . strlen ( $res ) );
				}
				debug ( 'mvccore returned lastRES' );
				echo $res;
				if (TRUE === self::$isConsoleMode) {
					// コンソールモード時は、最後に改行して終わる
					echo PHP_EOL;
				}
				if (2048 < strlen ( $res )) {
					logging ( substr ( $res, 0, 2048 ) . '...', 'responce' );
					// logging($res, 'responce');
				} else {
					logging ( $res, 'responce' );
				}
			}
		} catch ( Exception $Exception ) {
			// かなりのイレギュラー！ 普通はココを通らない！！
			_systemError ( 'Exception :' . $Exception->getMessage () );
		}
		
		// 明示的終了
		exit ();
	}
	public static function consolemain($argFlowXMLBasePath = '') {
		debug ( 'mvccore is console' );
		self::$isConsoleMode = TRUE;
		// サーバー変数のエミュレート
		if (! isset ( $_SERVER ['HTTP_USER_AGENT'] )) {
			$_SERVER ['HTTP_USER_AGENT'] = 'UNICORN/' . Configure::FW_VERSION;
		}
		if (! isset ( $_SERVER ['HTTP_ACCEPT_LANGUAGE'] ) && isset ( $_SERVER ['LANG'] )) {
			$_SERVER ['HTTP_ACCEPT_LANGUAGE'] = $_SERVER ['LANG'];
		}
		if (! isset ( $_SERVER ['REMOTE_ADDR'] )) {
			$_SERVER ['REMOTE_ADDR'] = '127.0.0.1';
		}
		if (! isset ( $_SERVER ['REQUEST_URI'] )) {
			$projectName = 'project/';
			if (defined ( 'PROJECT_NAME' )) {
				$projectName = PROJECT_NAME . '/';
			}
			$_SERVER ['REQUEST_URI'] = 'http://localhost/' . $projectName . $_SERVER ['SCRIPT_FILENAME'];
		}
		if (! isset ( $_SERVER ['REQUEST_METHOD'] )) {
			$_SERVER ['REQUEST_METHOD'] = 'GET';
		}
		// argc argvからv・c変数をエミュレート
		if (! isset ( $_GET ['_c_'] ) && isset ( $_SERVER ['argv'] ) && isset ( $_SERVER ['argv'] [2] )) {
			debug ( 'mvccore ' . var_export ( $_SERVER, true ) );
			if (FALSE !== strpos ( $_SERVER ['argv'] [2], '_c_' ) || FALSE !== strpos ( $_SERVER ['argv'] [2], '_o_' ) || FALSE !== strpos ( $_SERVER ['argv'] [2], '_a_' )) {
				$params = NULL;
				// QUERYSTRING形式で指定されている場合
				parse_str ( $_SERVER ['argv'] [2], $params );
				if (NULL !== $params && isset ( $params ['_c_'] )) {
					$_GET = $params;
				}
			} else {
				// c o a の順番で指定されている場合
				if (! isset ( $_GET )) {
					$_GET = array ();
				}
				$keys = array (
						'',
						'',
						'_c_',
						'_o_',
						'_a_' 
				);
				for($argIdx = 2; $argIdx < $_SERVER ['argc']; $argIdx ++) {
					$_GET [$keys [$argIdx]] = $_SERVER ['argv'] [$argIdx];
				}
			}
			debug ( 'mvccore emulate GET=' . var_export ( $_GET, true ) );
		}
		if (! isset ( $_GET ['_o_'] )) {
			// バッチの標準出力はtext形式
			$_GET ['_o_'] = 'txt';
		}
		self::webmain ( $argFlowXMLBasePath = '' );
	}
	
	/**
	 * MVCクラスモジュールの読み込み処理
	 *
	 * @param
	 *        	string クラス名
	 * @param
	 *        	string クラスの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @param
	 *        	string クラスの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @return mixed 成功時は対象のクラス名 失敗した場合はFALSEを返す
	 */
	public static function loadMVCModule($argClassName = NULL, $argClassExistsCalled = FALSE, $argTargetPath = '') {
		static $currentTargetPath = '';
		
		$targetPath = '';
		if (NULL !== $argClassName) {
			$controlerClassName = $argClassName;
		} else {
			// コントロール対象を自動特定
			$controlerClassName = 'Index';
			if (isset ( $_GET ['_c_'] ) && strlen ( $_GET ['_c_'] ) > 0) {
				$controlerClassName = str_replace ( '-', '_', ucfirst ( $_GET ['_c_'] ) );
				if (FALSE !== strpos ( $_GET ['_c_'], '/' ) && strlen ( $_GET ['_c_'] ) > 1) {
					$matches = NULL;
					if (preg_match ( '/(.*)\/([^\/]*)$/', $_GET ['_c_'], $matches ) && is_array ( $matches ) && isset ( $matches [2] )) {
						$controlerClassName = str_replace ( '-', '_', ucfirst ( $matches [2] ) );
						if (isset ( $matches [1] ) && strlen ( $matches [1] ) > 0) {
							$targetPath = $matches [1] . '/';
							if ('' === $currentTargetPath) {
								$currentTargetPath = $targetPath;
							}
						}
					}
				}
			}
		}
		if ('' !== $argTargetPath) {
			$targetPath = $argTargetPath;
		}
		if ('' === $targetPath) {
			$targetPath = $currentTargetPath;
		}
		$version = '';
		if (isset ( $_GET ['_v_'] ) && strlen ( $_GET ['_v_'] ) > 0) {
			$version = $_GET ['_v_'];
		}
		debug ( 'mvccore path=' . $targetPath );
		debug ( 'mvccore class=' . $controlerClassName );
		
		if (! class_exists ( $controlerClassName, FALSE )) {
			// コントローラを読み込み
			if ('' !== $version) {
				// バージョン一致のファイルを先ず走査する
				loadModule ( 'default.controlmain.' . $targetPath . $version . '/' . $controlerClassName, TRUE );
			}
			if (! class_exists ( $controlerClassName, FALSE )) {
				loadModule ( 'default.controlmain.' . $targetPath . $controlerClassName, TRUE );
			}
			if (! class_exists ( $controlerClassName, FALSE )) {
				loadModule ( 'default.controlmain.' . $controlerClassName, TRUE );
			}
			if (class_exists ( $controlerClassName, FALSE )) {
				// FlowGenerateする必要がなさそうなのでココで終了
				return $controlerClassName;
			} else if ('' === self::$flowXMLBasePath) {
				// エラー終了
				return FALSE;
			} else {
				// ココからはFlow処理
				if (TRUE === self::$flowXMLBasePath) {
					// self::$flowXMLBasePathがTRUEとなっていた場合はConfigureにFLOWXML_PATH定義が無いか調べる
					if (class_exists ( 'Configure', FALSE ) && NULL !== Configure::constant ( 'FLOWXML_PATH' )) {
						self::$flowXMLBasePath = Configure::FLOWXML_PATH;
					}
				}
				// Flow出来ない！
				if ('' === self::$flowXMLBasePath) {
					// エラー終了
					return FALSE;
				}
				// XML定義の存在チェック
				// クラス名は分解しておく
				$classHint = explode ( '_', $controlerClassName );
				debug ( 'mvccore ' . $targetPath );
				debug ( 'mvccore ' . var_export ( $classHint, TRUE ) );
				$classXMLName = $classHint [0];
				debug ( 'mvccore ' . $classXMLName );
				$flowXMLPath = '';
				if ('' !== $version) {
					// バージョン一致のファイルを先ず走査する
					if (file_exists_ip ( self::$flowXMLBasePath . '/' . $targetPath . $version . '/' . $classXMLName . '.flow.xml' )) {
						$flowXMLPath = self::$flowXMLBasePath . '/' . $targetPath . $version . '/' . $classXMLName . '.flow.xml';
					}
				}
				if ('' === $flowXMLPath) {
					// バージョン関係ナシのファイルを走査する
					if (file_exists_ip ( self::$flowXMLBasePath . '/' . $targetPath . $classXMLName . '.flow.xml' )) {
						$flowXMLPath = self::$flowXMLBasePath . '/' . $targetPath . $classXMLName . '.flow.xml';
					}
				}
				debug ( 'mvccore ' . $flowXMLPath );
				if ('' === $flowXMLPath) {
					// エラー終了
					return FALSE;
				}
				// flowファイルの履歴を残しておく
				self::$flowXMLPaths [] = array (
						'class' => $controlerClassName,
						'xml' => $flowXMLPath 
				);
				// Flowに応じたクラス定義の自動生成を委任
				loadModule ( 'Flow' );
				if (FALSE === Flow::generate ( $flowXMLPath, $controlerClassName, $targetPath )) {
					// エラー終了
					return FALSE;
				}
				if (! class_exists ( $controlerClassName, FALSE )) {
					// エラー終了
					return FALSE;
				}
			}
		}
		
		return $controlerClassName;
	}
	
	/**
	 * MVCフィルターモジュールの読み込み処理
	 *
	 * @param
	 *        	string クラス名
	 * @param
	 *        	string クラスの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @param
	 *        	string クラスの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @return mixed 成功時は対象のクラス名 失敗した場合はFALSEを返す
	 */
	public static function loadMVCFilter($argFilterName, $argTargetPath = '') {
		if(isset($_SERVER['_filter_']) && TRUE == ('0' === $_SERVER['_filter_'] || 'false' === strtolower($_SERVER['_filter_']))){
			// FIlterの明示的な利用拒否
			return FALSE;
		}
		$filterClassName = $argFilterName;
		if (! class_exists ( $filterClassName, FALSE )) {
			$targetPath = '';
			if ('' !== $argTargetPath) {
				$targetPath = $argTargetPath;
			}
			// FILTERのパス指定があるかどうか
			if(isset($_SERVER['_filter_']) && '0' !== $_SERVER['_filter_'] && 'false' !== strtolower($_SERVER['_filter_']) && 0 < strlen($_SERVER['_filter_'])){
				$filterPath = $_SERVER['_filter_'];
				if ('' !== $targetPath){
					$filterPath = '/'.$_SERVER['_filter_'];
				}
				$targetPath = $targetPath.$filterPath;
			}
			$version = '';
			if (isset ( $_GET ['_v_'] ) && strlen ( $_GET ['_v_'] ) > 0) {
				$version = $_GET ['_v_'];
			}
			// コントローラを読み込み
			if ('' !== $version) {
				// バージョン一致のファイルを先ず走査する
				loadModule ( 'default.controlmain.Filter/' . $targetPath . $version . '/' . $filterClassName, TRUE );
			}
			if (! class_exists ( $filterClassName, FALSE )) {
				loadModule ( 'default.controlmain.Filter/' . $targetPath . $filterClassName, TRUE );
			}
			if (! class_exists ( $filterClassName, FALSE )) {
				loadModule ( 'default.controlmain.Filter/' . $filterClassName, TRUE );
			}
			if (! class_exists ( $filterClassName )) {
				return FALSE;
			}
		}
		return $filterClassName;
	}
	
	/**
	 * クラス名に該当するhtmlを探しだして指定のテンプレートクラスに詰めて返す
	 *
	 * @param
	 *        	string クラス名
	 * @param
	 *        	string htmlの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @return boolean
	 */
	public static function loadTemplate($argClassName = NULL, $argFileExistsCalled = FALSE, $argTargetPath = '', $argViewType = FALSE, $argTemplateEngine = 'HtmlViewAssignor') {
		static $currentTargetPath = '';
		
		if (FALSE === $argViewType) {
			$argViewType = '.html';
		}
		if (NULL === $argViewType) {
			// XXX 拡張子未指定と判断！
			$argViewType = '';
		}
		
		$targetPath = '';
		if (NULL !== $argClassName) {
			$controlerClassName = $argClassName;
		} else {
			// コントロール対象を自動特定
			$controlerClassName = 'Index';
			debug ( 'mvccore _c_=' . $_GET ['_c_'] );
			if (isset ( $_GET ['_c_'] ) && strlen ( $_GET ['_c_'] ) > 0) {
				$controlerClassName = ucfirst ( $_GET ['_c_'] );
				if (FALSE !== strpos ( $_GET ['_c_'], '/' ) && strlen ( $_GET ['_c_'] ) > 1) {
					$matches = NULL;
					if (preg_match ( '/(.*)\/([^\/]*)$/', $_GET ['_c_'], $matches ) && is_array ( $matches ) && isset ( $matches [2] )) {
						$controlerClassName = ucfirst ( $matches [2] );
						if (isset ( $matches [1] ) && strlen ( $matches [1] ) > 0) {
							$targetPath = $matches [1] . '/';
							if ('' === $currentTargetPath) {
								$currentTargetPath = $targetPath;
							}
						}
					}
				}
			}
		}
		if ('' === $currentTargetPath) {
			// コントロール対象ディレクトリを自動特定
			debug ( 'mvccore check target dir _c_=' . $_GET ['_c_'] );
			if (isset ( $_GET ['_c_'] ) && strlen ( $_GET ['_c_'] ) > 0) {
				if (FALSE !== strpos ( $_GET ['_c_'], '/' ) && strlen ( $_GET ['_c_'] ) > 1) {
					$matches = NULL;
					if (preg_match ( '/(.*)\/([^\/]*)$/', $_GET ['_c_'], $matches ) && is_array ( $matches ) && isset ( $matches [2] )) {
						if (isset ( $matches [1] ) && strlen ( $matches [1] ) > 0) {
							$targetPath = $matches [1] . '/';
							$currentTargetPath = $targetPath;
						}
					}
				}
			}
		}
		if ('' !== $argTargetPath) {
			$targetPath = $argTargetPath;
		}
		if ('' === $targetPath) {
			$targetPath = $currentTargetPath;
		}
		
		$version = NULL;
		if (isset ( $_GET ['_v_'] ) && strlen ( $_GET ['_v_'] ) > 0) {
			$version = $_GET ['_v_'];
		}
		debug ( 'mvccore template path=' . $targetPath );
		debug ( 'mvccore template=' . $controlerClassName );

		$HtmlView = NULL;
		
		// htmlを読み込み
		if (NULL !== $version) {
			$basePath = $targetPath . $version . '/';
			if ('' === $targetPath && '/' === $basePath) {
				$basePath = $targetPath;
			}
			if (TRUE === file_exists_ip ( $basePath . $controlerClassName . $argViewType )) {
				if (TRUE === $argFileExistsCalled) {
					return $basePath . $controlerClassName . $argViewType;
				}
				// Viewインスタンスの生成
				$HtmlView = new $argTemplateEngine ( $basePath . $controlerClassName . $argViewType );
			} elseif (TRUE === file_exists_ip ( $basePath . strtolower ( $controlerClassName ) . $argViewType )) {
				if (TRUE === $argFileExistsCalled) {
					return $basePath . strtolower ( $controlerClassName ) . $argViewType;
				}
				// Viewインスタンスの生成
				$HtmlView = new $argTemplateEngine ( $basePath . strtolower ( $controlerClassName ) . $argViewType );
			}
			// ターゲットを抜いて見る
			if (NULL === $HtmlView) {
				$basePath = $version . '/';
				if ('' === $targetPath && '/' === $basePath) {
					$basePath = $targetPath;
				}
				if (TRUE === file_exists_ip ( $basePath . $controlerClassName . $argViewType )) {
					if (TRUE === $argFileExistsCalled) {
						return $basePath . $controlerClassName . $argViewType;
					}
					// Viewインスタンスの生成
					$HtmlView = new $argTemplateEngine ( $basePath . $controlerClassName . $argViewType );
				} elseif (TRUE === file_exists_ip ( $basePath . strtolower ( $controlerClassName ) . $argViewType )) {
					if (TRUE === $argFileExistsCalled) {
						return $basePath . strtolower ( $controlerClassName ) . $argViewType;
					}
					// Viewインスタンスの生成
					$HtmlView = new $argTemplateEngine ( $basePath . strtolower ( $controlerClassName ) . $argViewType );
				}
			}
		}
		
		if (NULL === $HtmlView) {
			$basePath = $targetPath . '/';
			if ('' === $targetPath && '/' === $basePath) {
				$basePath = $targetPath;
			}
			// バージョンを抜いてインクルード
			if (TRUE === file_exists_ip ( $basePath . $controlerClassName . $argViewType )) {
				if (TRUE === $argFileExistsCalled) {
					return $basePath . $controlerClassName . $argViewType;
				}
				// Viewインスタンスの生成
				$HtmlView = new $argTemplateEngine ( $basePath . $controlerClassName . $argViewType );
			} elseif (TRUE === file_exists_ip ( $basePath . strtolower ( $controlerClassName ) . $argViewType )) {
				if (TRUE === $argFileExistsCalled) {
					return $basePath . strtolower ( $controlerClassName ) . $argViewType;
				}
				// Viewインスタンスの生成
				$HtmlView = new $argTemplateEngine ( $basePath . strtolower ( $controlerClassName ) . $argViewType );
			} else {
				// ターゲットを抜いて見る
				if (NULL === $HtmlView) {
					$basePath =  '';
					// バージョンを抜いてインクルード
					if (TRUE === file_exists_ip ( $basePath . $controlerClassName . $argViewType )) {
						if (TRUE === $argFileExistsCalled) {
							return $basePath . $controlerClassName . $argViewType;
						}
						// Viewインスタンスの生成
						$HtmlView = new $argTemplateEngine ( $basePath . $controlerClassName . $argViewType );
					} elseif (TRUE === file_exists_ip ( $basePath . strtolower ( $controlerClassName ) . $argViewType )) {
						if (TRUE === $argFileExistsCalled) {
							return $basePath . strtolower ( $controlerClassName ) . $argViewType;
						}
						// Viewインスタンスの生成
						$HtmlView = new $argTemplateEngine ( $basePath . strtolower ( $controlerClassName ) . $argViewType );
					} else {
						// エラー終了
						return FALSE;
					}
				}
			}
		}
		
		return $HtmlView;
	}
	
	/**
	 * クラス名に該当するhtmlを探しだしてViewクラスに詰めて返す
	 *
	 * @param
	 *        	string クラス名
	 * @param
	 *        	string htmlの読み込事にエラーが在る場合にbooleanを返すかどうか
	 * @return boolean
	 */
	public static function loadView($argClassName = NULL, $argFileExistsCalled = FALSE, $argTargetPath = '', $argViewType = FALSE) {
		return self::loadTemplate ( $argClassName, $argFileExistsCalled, $argTargetPath, $argViewType );
	}
}

?>