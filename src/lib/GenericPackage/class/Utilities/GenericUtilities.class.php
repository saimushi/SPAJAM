<?php

define('START_SIGN_FORMAT_NUM', 0);
define('START_SIGN_FORMAT_JP_H', 1);// ひらがな
define('START_SIGN_FORMAT_JP_K', 2);// 漢字

/**
 * 関数群
 * @author saimushi
*/
class GenericUtilities {

	/**
	 * 2038年問題対応用の現在プロセス時間返却メソッド
	 * 1プロセス内では同じ値が常に返る事に注意！！
	 */
	public static function now($argTimezone=NULL){
		static $now = NULL;
		if(NULL === $now){
			$now = self:: date('Y-m-d H:i:s', null, null, $argTimezone);
		}
		return $now;
	}

	public static function gmnow(){
		static $gmnow = NULL;
		if(NULL === $gmnow){
			$gm = self:: date('P');
			$operator = substr($gm,0,1);
			if('+' === $operator){
				$operator = '-';
			}elseif('-' === $operator){
				$operator = '+';
			}
			$gm = substr($gm,1);
			$gms = explode(':', $gm);
			$gmnow = self::modifyDate($operator.$gms[0].'hour '.$operator.$gms[1].'minute', 'Y/m/d H:i:s', self::now());
		}
		return $gmnow;
	}

	/**
	 * 2038年問題対応用のdate関数互換メソッド
	 */
	public static function date($argFormat, $argDate=NULL, $argBeforeTimezone=NULL, $argAfterTimezone=NULL){
		static $DateInstance = array();
		$deftimezone = @date_default_timezone_get();
		if(strlen($deftimezone) > 0){
			$deftimezone = 'Asia/Tokyo';
			date_default_timezone_set($deftimezone);
		}
		if(NULL !== $argBeforeTimezone){
			if(strlen($deftimezone) > 0){
				date_default_timezone_set($argBeforeTimezone);
			}
		}
		if(!isset($DateInstance[$argDate.$argBeforeTimezone])){
			if(NULL === $argDate){
				$DateInstance[$argDate.$argBeforeTimezone] = new DateTime(NULL);
			}elseif(preg_match('/^[0-9]+$/',$argDate)){
				$DateInstance[$argDate.$argBeforeTimezone] = new DateTime('@'.$argDate);
				//$DateInstance[$argDate]->setTimestamp($argDate);
			}else{
				try{
					$DateInstance[$argDate.$argBeforeTimezone] = new DateTime($argDate);
				}catch (Exception $Exception){
					// NG
					return FALSE;
				}
			}
		}
		if(NULL !== $argAfterTimezone){
			$DateInstance[$argDate.$argBeforeTimezone]->setTimezone(new DateTimeZone($argAfterTimezone));
		}
		$date = $DateInstance[$argDate.$argBeforeTimezone]->format($argFormat);
		if(NULL !== $argAfterTimezone){
			$DateInstance[$argDate.$argBeforeTimezone]->setTimezone(new DateTimeZone($deftimezone));
		}
		return $date;
	}

	/**
	 * 2038年問題対応用のstrtotimeっぽいメソッド
	 */
	public static function modifyDate($argModify, $argFormat, $argDate=NULL, $argBeforeTimezone=NULL, $argAfterTimezone=NULL){
		try{
			$deftimezone = @date_default_timezone_get();
			if(strlen($deftimezone) > 0){
				$deftimezone = 'Asia/Tokyo';
				date_default_timezone_set($deftimezone);
			}
			if(NULL !== $argBeforeTimezone){
				if(strlen($deftimezone) > 0){
					date_default_timezone_set($argBeforeTimezone);
				}
			}
			if(NULL === $argDate){
				$DateInstance = new DateTime();
			}else{
				$DateInstance = new DateTime($argDate);
			}
			if(NULL !== $argAfterTimezone){
				$DateInstance->setTimezone(new DateTimeZone($argAfterTimezone));
			}
			$DateInstance->modify($argModify);
			$modifyedDate = $DateInstance->format($argFormat);
			unset($DateInstance);
			return $modifyedDate;
		}
		catch (Exception $Exception){
			// NG
			return FALSE;
		}
	}

	/**
	 * 有効な日付かどうかを評価する
	 * checkdateを拡張し、dateが解釈出来る全フォーマットに対応
	 */
	public static function checkDate($argDate){
		// どの書式でくるか解らないので取り敢えずDatetimeクラスに食わす
		$dateParses = date_parse($argDate);
		return checkdate($dateParses['month'],$dateParses['day'],$dateParses['year']);
	}

	/**
	 * 2038年問題対応用のdate関数互換メソッド
	 * 日付の妥当性と一緒に指定されたフォーマットとデータが一致するかどうか評価する
	 * あとDatetimeクラスが解釈出来る書式ならなんでもチェック出来るようにした
	 */
	public static function checkDateFormat($argDate,$argFormat){
		if(self::checkdate($argDate)){
			try{
				$deftimezone = @date_default_timezone_get();
				if(strlen($deftimezone) > 0){
					date_default_timezone_set('Asia/Tokyo');
				}
				$Date = new Datetime($argDate);
				if($argDate == $Date->format($argFormat)){
					return TRUE;
				}
			}catch (Exception $Exception){
				// NG
				return FALSE;
			}
		}
		return FALSE;
	}

	/**
	 * 星座を返す
	 * 1:やぎ座
	 * 2:みずかめ座
	 * 3:うお座
	 * 4:おうし座
	 * 5:おひつじ座
	 * 6:ふたご座
	 * 7:かに座
	 * 8:しし座
	 * 9:おとめ座
	 * 10:てんびん座
	 * 11:さそり座
	 * 12:いて座
	 */
	public static function getStarSign($argFormat=2, $argDate=NULL, $argBeforeTimezone=NULL, $argAfterTimezone=NULL){
		$deftimezone = @date_default_timezone_get();
		if(strlen($deftimezone) > 0){
			date_default_timezone_set($deftimezone);
		}
		if(NULL !== $argBeforeTimezone){
			if(strlen($deftimezone) > 0){
				date_default_timezone_set($argBeforeTimezone);
			}
		}
		if(NULL === $argDate){
			$DateInstance = new DateTime(NULL);
		}elseif(preg_match('/^[0-9]+$/',$argDate)){
			$DateInstance = new DateTime('@'.$argDate);
		}else{
			try{
				$DateInstance = new DateTime($argDate);
			}catch (Exception $Exception){
				// NG
				return FALSE;
			}
		}
		if(NULL !== $argAfterTimezone){
			$DateInstance->setTimezone(new DateTimeZone($argAfterTimezone));
		}
		// 星座をチェック()状態遷移
		$starsign = 0;
		$date = $DateInstance->format('md');
		if(1222 <= (int)$date || 120 >= (int)$date){
			$starsign = 1;
		}
		if(121 <= (int)$date && 218 >= (int)$date){
			$starsign = 2;
		}
		if(219 <= (int)$date && 320 >= (int)$date){
			$starsign = 3;
		}
		if(321 <= (int)$date && 419 >= (int)$date){
			$starsign = 4;
		}
		if(420 <= (int)$date && 520 >= (int)$date){
			$starsign = 5;
		}
		if(521 <= (int)$date && 621 >= (int)$date){
			$starsign = 6;
		}
		if(622 <= (int)$date && 722 >= (int)$date){
			$starsign = 7;
		}
		if(723 <= (int)$date && 823 >= (int)$date){
			$starsign = 8;
		}
		if(824 <= (int)$date && 922 >= (int)$date){
			$starsign = 9;
		}
		if(923 <= (int)$date && 1023 >= (int)$date){
			$starsign = 10;
		}
		if(1024 <= (int)$date && 1122 >= (int)$date){
			$starsign = 11;
		}
		if(1123 <= (int)$date && 1221 >= (int)$date){
			$starsign = 12;
		}
		if(NULL !== $argAfterTimezone){
			$DateInstance->setTimezone(new DateTimeZone($deftimezone));
		}
		// フォーマット変換
		if(START_SIGN_FORMAT_JP_H === $argFormat){
			switch ($starsign){
				case 1:
					$starsign = 'やぎ座';
					break;
				case 2:
					$starsign = 'みずかめ座';
					break;
				case 3:
					$starsign = 'うお座';
					break;
				case 4:
					$starsign = 'おひつじ座';
					break;
				case 5:
					$starsign = 'おうし座';
					break;
				case 6:
					$starsign = 'ふたご座';
					break;
				case 7:
					$starsign = 'かに座';
					break;
				case 8:
					$starsign = 'しし座';
					break;
				case 9:
					$starsign = 'おとめ座';
					break;
				case 10:
					$starsign = 'てんびん座';
					break;
				case 11:
					$starsign = 'さそり座';
					break;
				case 12:
					$starsign = 'いて座';
					break;
				default:
					$starsign = NULL;
					break;
			}
		}
		else if(START_SIGN_FORMAT_JP_K === $argFormat){
			switch ($starsign){
				case 1:
					$starsign = '山羊座';
					break;
				case 2:
					$starsign = '水瓶座';
					break;
				case 3:
					$starsign = '魚座';
					break;
				case 4:
					$starsign = '牡羊座';
					break;
				case 5:
					$starsign = '牡牛座';
					break;
				case 6:
					$starsign = '双子座';
					break;
				case 7:
					$starsign = '蟹座';
					break;
				case 8:
					$starsign = '獅子座';
					break;
				case 9:
					$starsign = '乙女座';
					break;
				case 10:
					$starsign = '天秤座';
					break;
				case 11:
					$starsign = '蠍座';
					break;
				case 12:
					$starsign = '射手座';
					break;
				default:
					$starsign = NULL;
					break;
			}
		}
		return $starsign;
	}

	/**
	 * メソッド呼び出し元のエラーとしてExceptionする際の
	 * Line情報を構成する
	 */
	public static function getBacktraceExceptionLine(){
		$traces = debug_backtrace();
		$class = $traces[2]['class'];
		$method = $traces[2]['function'];
		$line = $traces[1]['line'];
		return $class.PATH_SEPARATOR.$class.'::'.$method.PATH_SEPARATOR.$line;
	}

	/**
	 * AES暗号形式でデータを暗号化し、base64encodeする
	 * @param string エンコードする文字列
	 * @param string 暗号キー
	 * @param 16進数 IV
	 * @return string base64encodeされた暗号データ
	 */
	public static function doHexEncryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {
		return bin2hex(self::encryptAES($argValue, $argKey, $argIV, $argPrefix, $argSuffix));
	}

	/**
	 * base64decodeしてからAES暗号形式のデータを復号化する
	 * @param string デコードする文字列
	 * @param string 暗号キー
	 * @param 16進数 IV
	 * @return string 複合データ
	 */
	public static function doHexDecryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {
		return self::decryptAES(@pack("H*", $argValue), $argKey, $argIV, $argPrefix, $argSuffix);
	}

	/**
	 * AES暗号形式でデータを暗号化し、base64encodeする
	 * @param string エンコードする文字列
	 * @param string 暗号キー
	 * @param base64 IV
	 * @return string base64encodeされｔ暗号データ
	 */
	public static function do64EncryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {
		return base64_encode(self::encryptAES($argValue, $argKey, base64_decode($argIV), $argPrefix, $argSuffix));
	}

	/**
	 * base64decodeしてかっらAES暗号形式のデータを複合化する
	 * @param string デコードする文字列
	 * @param string 暗号キー
	 * @param base64 IV
	 * @return string 複合データ
	 */
	public static function do64DecryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {
		return self::decryptAES(base64_decode($argValue), $argKey, base64_decode($argIV), $argPrefix, $argSuffix);
	}

	/**
	 * AES暗号形式でデータを暗号化する
	 * @param 	$argValue 	エンコードする値
	 * @param 	$argKey 	暗号キー
	 * @param 	$argIv 		IV
	 * @return 	$encrypt 	暗号化データ
	 */
	public static function encryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {

		// パラメータセット
		// XXX パラメータは定数で可変出来るようにする
		$params = array(
				'value' 		=> $argValue,
				'key' 			=> $argKey,
				'iv' 			=> $argIV,
				'algorithm' 	=> 'rijndael-128',
				'mode' 			=> 'cbc',
				'prefix' 		=> $argPrefix,
				'suffix' 		=> $argSuffix,
		);

		// データを暗号化する
		$encrypt = Cipher :: encrypt($params);

		// エラー処理
		if (false === $encrypt || NULL === $encrypt) {
			return false;
		}
		return $encrypt;
	}

	/**
	 * AES暗号形式で暗号化されたデータを複号化する
	 * @param 	$argValue 	デコードする値
	 * @param 	$argKey 	暗号キー
	 * @param 	$argIv 		IV
	 * @return 	$encrypt 	複号化データ
	 */
	public static function decryptAES($argValue, $argKey, $argIV = null, $argPrefix = '', $argSuffix = '') {
		// パラメータセット
		// XXX パラメータは定数で可変出来るようにする
		$params = array(
				'value' 		=> $argValue,
				'key' 			=> $argKey,
				'iv' 			=> $argIV,
				'algorithm' 	=> 'rijndael-128',
				'mode' 			=> 'cbc',
				'prefix' 		=> $argPrefix,
				'suffix' 		=> $argSuffix,
		);

		// データを複合号化する
		$decrypt = Cipher :: decrypt($params);

		// エラー処理
		if (false === $decrypt || NULL === $decrypt) {
			return false;
		}
		return $decrypt;
	}

	public static function getRequestURL(){
		static $requestURL = NULL;
		if(NULL === $requestURL){
			if(strlen($_SERVER['QUERY_STRING']) > 0){
				$requestURL = substr($_SERVER["REQUEST_URI"],0,strlen($_SERVER["REQUEST_URI"]) - (strlen($_SERVER['QUERY_STRING'])+1));
			}else{
				$requestURL = $_SERVER["REQUEST_URI"];
			}
		}
		return $requestURL;
	}

	public static function getURIParams($argStartPoint=NULL){
		// パラメータ取得
		$params = array();
		$requestURL = self::getRequestURL();
		if(NULL !== $argStartPoint){
			$paramStartPoint = strpos($requestURL,$argStartPoint);
			if(FALSE === $paramStartPoint){
				// XXX エラー終了？？
				return FALSE;
			}
			$requestURL = substr($requestURL,$paramStartPoint+(strlen($argStartPoint)));
		}
		return explode('/',$requestURL);
	}

	public static function getRequestExtension(){
		static $extension = NULL;
		if(NULL === $extension){
			// アクセスされている拡張子を取っておく
			$extension = pathinfo(self::getRequestURL(),PATHINFO_EXTENSION);
		}
		return $extension;
	}

	/**
	 * 配列のkey名にstrtolowerを掛ける
	 */
	public static function lowerArrKeys($argument){
		if(is_array($argument)){
			foreach($argument as $key => $val){
				if(is_array($val)){
					$val = self::lowerArrKeys($val);
				}
				$argument[strtolower($key)] = $val;
				unset($argument[$key]);
			}
			return $argument;
		}
		return $argument;
	}

	/**
	 *
	 */
	public static function setRedirectHeader($argRedirectURL){
		header('location: '.$argRedirectURL);
	}

	/**
	 * 携帯クローラ判定
	 * @return	bool	true:クローラ、false:非クローラ
	 */
	public static function isMobileCrawler(){
		$crawler_arr = array(
				'Googlebot-Mobile',
				'moba-crawler',
				'mobile goo',
				'LD_mobile_bot',
				'froute.jp',
				'Y!J-SRD',
				'Y!J-MRD',
		);

		foreach ($crawler_arr as $val) {
			if (false !== strpos($_SERVER['HTTP_USER_AGENT'], $val)) {
				return TRUE;
			}
		}
		return FALSE;
	}

	/**
	 * 西暦の年月日を和暦の年月日に変換する
	 * 
	 * <p>(例)1986 11 16→昭和61年11月16日</p>
	 * 
	 * @param int $year 西暦の年
	 * @param int $month 月
	 * @param int $day 日
	 * @return string 和暦の年月日 妥当でない年月日、または明治より古い年号に該当する場合はfalse
	 */
	public static function convertToWareki($year, $month, $day) {
		if (!checkdate($month, $day, $year)) {
			return false;
		}
		if ($year < 1869) {
			// 明治より古い
			return false;
		}
		$date = intval($year . sprintf("%02d", $month) . sprintf("%02d", $day));
		if ($date >= 19890108) {
			$name = "平成";
			$y = $year - 1988;
		} elseif ($date >= 19261225) {
			$name = "昭和";
			$y = $year - 1925;
		} elseif ($date >= 19120730) {
			$name = "大正";
			$y = $year - 1911;
		} else {
			$name = "明治";
			$y = $year - 1868;
		}
		if ($y === 1) {
			return $name."元年".$month."月".$day."日";
		}
		return $name.$y."年".$month."月".$day."日";
	}
}

?>