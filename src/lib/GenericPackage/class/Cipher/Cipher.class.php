<?php

/**
 * 暗号化処理を行います。
 * 
 * ブロックアルゴリズムをサポートするmcryptライブラリを利用しています。
 * @author T.Morita
 * @see <a href="http://php.net/manual/ja/book.mcrypt.php">Mcrypt</a>
 */
class Cipher {

	/**
	 * @var string 初期化ベクトルの処理時の設定値を格納
	 */
	protected static $iv = NULL;

	/**
	 * コンストラクタ
	 */
	public function __construct() {
		//
	}

	/**
	 * デストラクタ
	 */
	public function __destruct() {
		//
	}

	/**
	 * データを暗号化する
	 * @param array $arguments 暗号情報
	 * 		<table>
	 * 			<tr>
	 * 				<td><b>key</b></td>
	 * 				<td><b>type</b></td>
	 * 				<td><b>require</b></td>
	 * 				<td><b>default</b></td>
	 * 				<td><b>description</b></td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>value</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td></td>
	 * 				<td>対象データ</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>key</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td></td>
	 * 				<td>暗号キー</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>iv</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>指定されない場合生成される</td>
	 * 				<td>初期化ベクトル</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>algorithm</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>rijndael-128</td>
	 * 					<td>MCRYPT_暗号名 定数のいずれか、 あるいはアルゴリズム名をあらわす文字列。</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>mode</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>cbc</td>
	 * 				<td>定数 MCRYPT_MODE_モード名、あるいは文字列 "ecb", "cbc", "cfb", "ofb", "nofb" ,"stream" のいずれか。</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>prefix</td>
	 * 				<td>string</td>
	 * 				<td>false</td><td></td>
	 * 				<td>接頭にパディングする文字列</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>suffix</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td></td>
	 * 				<td>接尾にパディングする文字列</td>
	 * 			</tr>
	 * 		</table>
	 * 		パディング防止が必要な場合は、'prefix'と'suffix'を指定する。<br>
	 * 		'prefix'と'suffix'には、メタ文字( . \ + * ? [ ^ ] ( $ ) )のみ指定できます。
	 * @return string|boolean 暗号化されたデータもしくはfalse
	 */
	public static function encrypt($arguments) {
		// 引数のチェック
		if (false === isset($arguments['value']) || 0 === strlen($arguments['value']) || false === isset($arguments['key']) || 0 === strlen($arguments['key'])) {
			return false;
		}

		if (false === isset($arguments['algorithm']) || 0 === strlen($arguments['algorithm'])) {
			$arguments['algorithm'] = 'rijndael-128';
		}

		if (false === isset($arguments['mode']) || 0 === strlen($arguments['mode'])){
			$arguments['mode'] = 'cbc';
		}

		// XXX log処理入れる
		if (isset($arguments['prefix']) && isset($arguments['suffix'])) {
			$value = $arguments['prefix'].$arguments['value'].$arguments['suffix'];
		} elseif (false === isset($arguments['prefix']) && false === isset($arguments['suffix'])) {
			$value = $arguments['value'];
		} else {
			return false;
		}

		// 暗号モジュールをオープン
		$cipherHandler = mcrypt_module_open($arguments['algorithm'], $algorithm_directory = '', $arguments['mode'], $mode_directory = '');

		// pad
		$value = self::pad($value, mcrypt_enc_get_iv_size($cipherHandler));

		// IVの初期化処理
		self::$iv = NULL;
		if(isset($arguments['iv'])){
			self::$iv = $arguments['iv'];
		}
		// IVが指定されていない場合、IV を作成
		if (NULL === self::$iv) {
			self::$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($cipherHandler), MCRYPT_DEV_RANDOM);
		}

		// 暗号化処理を初期化
		mcrypt_generic_init($cipherHandler, $arguments['key'], self::$iv);

		// データを暗号化
		$encryptedData = mcrypt_generic($cipherHandler, $value);

		// 暗号化ハンドラを終了
		mcrypt_generic_deinit($cipherHandler);

		// モジュールをクローズ
		mcrypt_module_close($cipherHandler);

		return $encryptedData;
	}

	/**
	 * データを復号化する
	 * @param array $arguments 復号情報
	 * 		<table>
	 * 			<tr>
	 * 				<td><b>key</b></td>
	 * 				<td><b>type</b></td>
	 * 				<td><b>require</b></td>
	 * 				<td><b>default</b></td>
	 * 				<td><b>description</b></td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>value</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td></td>
	 * 				<td>対象データ</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>key</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td></td>
	 * 				<td>暗号キー</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>iv</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>指定されない場合生成される</td>
	 * 				<td>初期化ベクトル</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>algorithm</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>rijndael-128</td>
	 * 					<td>MCRYPT_暗号名 定数のいずれか、 あるいはアルゴリズム名をあらわす文字列。</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>mode</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td>cbc</td>
	 * 				<td>定数 MCRYPT_MODE_モード名、あるいは文字列 "ecb", "cbc", "cfb", "ofb", "nofb" ,"stream" のいずれか。</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>prefix</td>
	 * 				<td>string</td>
	 * 				<td>false</td><td></td>
	 * 				<td>接頭にパディングする文字列</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>suffix</td>
	 * 				<td>string</td>
	 * 				<td>false</td>
	 * 				<td></td>
	 * 				<td>接尾にパディングする文字列</td>
	 * 			</tr>
	 * 		</table>
	 * 		パディング防止が必要な場合は、'prefix'と'suffix'を指定する。<br>
	 * 		'prefix'と'suffix'には、メタ文字( . \ + * ? [ ^ ] ( $ ) )のみ指定できます。
	 * @return string|boolean 復号化されたデータもしくはfalse
	 */
	public static function decrypt($arguments) {
		// 引数のチェック
		if (false === isset($arguments['value']) || 0 === strlen($arguments['value']) || false === isset($arguments['key']) || 0 === strlen($arguments['key'])) {
			return false;
		}

		if (false === isset($arguments['algorithm']) || 0 === strlen($arguments['algorithm'])) {
			$arguments['algorithm'] = 'rijndael-128';
		}

		if (false === isset($arguments['mode']) || 0 === strlen($arguments['mode'])){
			$arguments['mode'] = 'cbc';
		}

		// 暗号モジュールをオープン
		$cipherHandler = mcrypt_module_open($arguments['algorithm'], $algorithm_directory = '', $arguments['mode'], $mode_directory = '');

		// 暗号化処理を初期化
		mcrypt_generic_init($cipherHandler, $arguments['key'], $arguments['iv']);

		// データを複号化
		$decryptedData = mdecrypt_generic($cipherHandler, $arguments['value']);

		// 暗号化ハンドラを終了
		mcrypt_generic_deinit($cipherHandler);

		// モジュールをクローズ
		mcrypt_module_close($cipherHandler);

		// unpad
		$decryptedData = self::unpad($decryptedData);
		
		// XXX log処理入れる
		if (isset($arguments['prefix']) && isset($arguments['suffix'])) {
			//$decryptedData = trim($decryptedData);
			if (preg_match('/'.quotemeta($arguments['prefix']).'(.*)'.quotemeta($arguments['suffix']).'/', $decryptedData, $matches)) {
				$decryptedData = $matches[1];
			}
			return $decryptedData;
		} elseif (false === isset($arguments['prefix']) && false === isset($arguments['suffix'])) {
			return $decryptedData;
		} else {
			return false;
		}
	}

	/**
	 * 現在設定されている、最後に使用されたIV(初期化ベクトル)を返す
	 * @return string 初期化ベクトル
	 */
	public static function getNowIV(){
		return self::$iv;
	}

	/**
	 * PKCSでpadする(5、7に有効)
	 * @param string $text 対象文字列
	 * @param integer $blocksize ブロックサイズ
	 * @return string padされた文字列
	 * @see <a href="http://ja.wikipedia.org/wiki/PKCS">PKCS</a>
	 */
	public static function pad($text, $blocksize){
		$pad = $blocksize - (strlen($text) % $blocksize);
		return $text . str_repeat(chr($pad), $pad);
	}

	/**
	 * PKCSでunpadする(5、7に有効)
	 * @param string $text 対象文字列
	 * @return string unpadされた文字列
	 * @see <a href="http://ja.wikipedia.org/wiki/PKCS">PKCS</a>
	 */
	public static function unpad($text){
		$pad = ord($text{strlen($text)-1});
		if ($pad > strlen($text)) return false;
		if (strspn($text, chr($pad), strlen($text) - $pad) != $pad) return false;
		return substr($text, 0, -1 * $pad);
	}
}

?>