<?php

class GenericAppReceiptVerifier
{
	/**
	 *
	 * @param string $argProductID 課金アイテムID
	 * @param string $argBase64EncodedReceipt base64レシート
	 * @param string $argDeviceType デバイス(ios or android)
	 * @param string $argSignatureOrSecretKey iOS=シークレットキー Android=base64シグネチャ
	 * @param boolean $argAutorenewSubscription 自動継続購読アイテムフラグ
	 * @param string $argBase64PublicKey Google用base64公開鍵
	 * @param string $argPackageName GoogleレシートチェックAPI用パッケージID
	 * @param string $argClientId GoogleレシートチェックAPI用クライアントID
	 * @param string $argClientSecret GoogleレシートチェックAPI用クライアントシークレット
	 * @param string $argRefreshToken GoogleレシートチェックAPI用リフレッシュトークン
	 * @return FALSE|array('last_receipt' => lastreceipt[, 'expired' => bool(FALSE:期限内・有効|TRUE:期限切・無効), 'expire_date' => newexpireddate])
	 */
	public static function isEnabled($argProductID, $argBase64EncodedReceipt, $argDeviceType, $argSignatureOrSecretKey, $argAutorenewSubscription = FALSE, $argBase64PublicKey = NULL, $argPackageName = NULL, $argClientId = NULL, $argClientSecret = NULL, $argRefreshToken = NULL){
		static $recersive = FALSE;
		static $sandbox = FALSE;

		// Validate
		if (!is_string($argProductID) || !is_string($argBase64EncodedReceipt)) {
			return FALSE;
		}

		if (FALSE === $recersive){
			$sandbox = FALSE;
		}

		$result = array();
		if(strtolower($argDeviceType) === 'ios' || strtolower($argDeviceType) === 'iphone' || strtolower($argDeviceType) === 'ipad' || strtolower($argDeviceType) === 'ipod'){
			logging('receiptverify ios', 'receiptverify');
			// アップル レシートレコードのチェック
			if (FALSE === $sandbox){
				logging('receiptverify ios released', 'receiptverify');
				logging('receiptverify receip json {"receipt-data":"' . $argBase64EncodedReceipt . '", "password":"' . $argSignatureOrSecretKey . '"}', 'receiptverify');
				$ch  = curl_init();
				$url = 'https://buy.itunes.apple.com/verifyReceipt';
				curl_setopt($ch, CURLOPT_URL, $url);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_POST, TRUE);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"receipt-data":"' . $argBase64EncodedReceipt . '", "password":"' . $argSignatureOrSecretKey . '"}');
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_HEADER, FALSE);
				$body = curl_exec($ch);
				$data = json_decode($body, TRUE);
				if((string)$data['status'] === '21007' || (string)$data['status'] === '21008'){
					$sandbox = TRUE;
				}
			}

			if (TRUE === $sandbox){
				// sandboxレシートのため、sandboxに再度問い合わせ
				logging('receiptverify ios sansbox', 'receiptverify');
				$ch  = curl_init();
				$url = 'https://sandbox.itunes.apple.com/verifyReceipt';// サンドボックス（テスト用）
				curl_setopt($ch, CURLOPT_URL, $url);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_POST, TRUE);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"receipt-data":"' . $argBase64EncodedReceipt . '", "password":"' . $argSignatureOrSecretKey . '"}');
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_HEADER, FALSE);
				$body = curl_exec($ch);
				$data = json_decode($body, TRUE);
			}

			if(isset($data['receipt'])){
				logging('receiptverify receipt:' . var_export($data, TRUE), 'receiptverify');
			}
			if(isset($data['receipt']) && isset($data['receipt']['expires_date'])){
				logging('receiptverify expires_date:' . $data['receipt']['expires_date'], 'receiptverify');
			}

			// 有効判定
			if((string)$data['status'] === '0'){
				$status = FALSE;
				$lastExpireDateMS = "0";
				$lastExpireDate = "";
				$result['last_receipt'] = base64_decode($argBase64EncodedReceipt);
				if(FALSE === $argAutorenewSubscription){
					if(isset($data['receipt']) && isset($data['receipt']['product_id']) && $argProductID == $data['receipt']['product_id']){
						$status = TRUE;
					}
				}
				else if(FALSE !== $argAutorenewSubscription){
					for($receiptIdx=0; $receiptIdx < count($data['latest_receipt_info']); $receiptIdx++){
						// 指定されたプロダクトIDに一致するレシートがあるかどうか
						if(isset($data['latest_receipt_info'][$receiptIdx]) && isset($data['latest_receipt_info'][$receiptIdx]['product_id']) && $argProductID == $data['latest_receipt_info'][$receiptIdx]['product_id']){
							// 一旦有効
							$status = TRUE;
							// 定期購読の場合はプラスで期限判定
							if(FALSE !== $argAutorenewSubscription){
								$data['latest_receipt_info'][$receiptIdx]["expires_date_ms"];
								if((int)$lastExpireDateMS < (int)$data['latest_receipt_info'][$receiptIdx]["expires_date_ms"]){
									$lastExpireDateMS = $data['latest_receipt_info'][$receiptIdx]["expires_date_ms"];
									$lastExpireDate = $data['latest_receipt_info'][$receiptIdx]["expires_date"];
									logging('receiptverify idx='.$receiptIdx.' expired:' . $data['latest_receipt_info'][$receiptIdx]["expires_date"], 'receiptverify');
								}
							}
						}
					}
					if (FALSE === $status){
						return FALSE;
					}
					// 最新の定期購読期間と、その有効期限のチェック
					if("" === $lastExpireDate){
						// XXX 相当なイレギュラー！
						return FALSE;
					}
					$now = Utilities::date("YmdHis", NULL, NULL, "GMT");
					$result['expire_date'] = Utilities::date("Y-m-d H:i:s", $lastExpireDate, "GMT", "GMT");
					// デフォルトは期限切れ
					$result['expired'] = TRUE;
					if(Utilities::date("YmdHis", NULL, NULL, "GMT") < Utilities::date("YmdHis", $lastExpireDate, "GMT", "GMT")){
						logging('receiptverify 期限内！', 'receiptverify');
						$result['expired'] = FALSE;
					}
					logging('receiptverify expired:' . var_export($result['expired'], TRUE), 'receiptverify');
					logging('receiptverify now:' . Utilities::date("YmdHis", NULL, NULL, "GMT"), 'receiptverify');
					logging('receiptverify exp:' . Utilities::date("YmdHis", $lastExpireDate, "GMT", "GMT"), 'receiptverify');
					logging('receiptverify date:' . $result['expire_date'], 'receiptverify');

					if(TRUE === $result['expired'] && FALSE === $recersive && isset($data['latest_receipt'])){
						// latest_receiptで再帰処理して、それでも期限切れかを調べる
						$recersive = TRUE;
						logging('receiptverify recersive', 'receiptverify');
						return self::isEnabled($argProductID, $data['latest_receipt'], $argDeviceType, $argSignatureOrSecretKey, $argAutorenewSubscription);
					}
					// XXX デバッグ用の分岐
					if (TRUE === $recersive){
						logging('receiptverify end recersive', 'receiptverify');
					}
					// リカーシブルをしないように
					$recersive = FALSE;
				}
			}
		}
		elseif(strtolower($argDeviceType) === 'android'){
			logging('receiptverify android', 'receiptverify');

			if (NULL === $argBase64PublicKey) {
				// コンフィグから読み込みを試みる
				$ProjectConfigure = NULL;
				if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
					$ProjectConfigure = PROJECT_NAME . 'Configure';
				}
				if(NULL !== $ProjectConfigure && NULL !== $ProjectConfigure::constant('GOOGLE_PUBLIC_KEY')){
					$argBase64PublicKey = $ProjectConfigure::GOOGLE_PUBLIC_KEY;
				}
				elseif(class_exists('Configure') && NULL !== Configure::constant('GOOGLE_PUBLIC_KEY')){
					$argBase64PublicKey = Configure::GOOGLE_PUBLIC_KEY;
				}
				if (NULL === $argBase64PublicKey) {
					return FALSE;
				}
			}

			$pem = chunk_split($argBase64PublicKey, 64, "\n");
			$pem = "-----BEGIN PUBLIC KEY-----\n" . $pem . "-----END PUBLIC KEY-----\n";
			$pkbin = openssl_get_publickey($pem);

			logging('receiptverify pem:' . $pem, 'receiptverify');

			if (empty($pkbin)) {
				return FALSE;
			}

			debug('receiptverify pkbin:' . $pkbin);

			// レシートチェック
			$res = openssl_verify($argBase64EncodedReceipt, base64_decode($argSignatureOrSecretKey), $pkbin);
			debug('receiptverify body:' . $res);

			if ($res === 1) {

				if(TRUE === $argAutorenewSubscription){
					// 定期購読アイテムの購読期間チェック
					logging('receiptverify argAutorenewSubscription check', 'receiptverify');
					$recipt_array = json_decode($argBase64EncodedReceipt, true);

					// コンフィグから読み込みを試みる
					$ProjectConfigure = NULL;
					if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
						$ProjectConfigure = PROJECT_NAME . 'Configure';
					}
					// コンフィグから読み込みを試みる
					if (NULL === $argPackageName){
						if(NULL !== $ProjectConfigure && NULL !== $ProjectConfigure::constant('GPD_PACKAGE_NAME')){
							$argPackageName = $ProjectConfigure::GPD_PACKAGE_NAME;
						}
						elseif(class_exists('Configure') && NULL !== Configure::constant('GPD_PACKAGE_NAME')){
							$argPackageName = Configure::GPD_PACKAGE_NAME;
						}
						if (NULL === $argPackageName) {
							logging('receiptverify Not exist require parameter.', 'receiptverify');
							return FALSE;
						}
					}
					if (NULL === $argClientId){
						if(NULL !== $ProjectConfigure && NULL !== $ProjectConfigure::constant('GPD_CLIENT_ID')){
							$argClientId = $ProjectConfigure::GPD_CLIENT_ID;
						}
						elseif(class_exists('Configure') && NULL !== Configure::constant('GPD_CLIENT_ID')){
							$argClientId = Configure::GPD_CLIENT_ID;
						}
						if (NULL === $argClientId) {
							logging('receiptverify Not exist require parameter.', 'receiptverify');
							return FALSE;
						}
					}
					if (NULL === $argClientSecret){
						if(NULL !== $ProjectConfigure && NULL !== $ProjectConfigure::constant('GPD_CLIENT_SECRET')){
							$argClientSecret = $ProjectConfigure::GPD_CLIENT_SECRET;
						}
						elseif(class_exists('Configure') && NULL !== Configure::constant('GPD_CLIENT_SECRET')){
							$argClientSecret = Configure::GPD_CLIENT_SECRET;
						}
						if (NULL === $argClientSecret) {
							logging('receiptverify Not exist require parameter.', 'receiptverify');
							return FALSE;
						}
					}
					if (NULL === $argRefreshToken){
						if(NULL !== $ProjectConfigure && NULL !== $ProjectConfigure::constant('GPD_REFRESH_TOKEN')){
							$argRefreshToken = $ProjectConfigure::GPD_REFRESH_TOKEN;
						}
						elseif(class_exists('Configure') && NULL !== Configure::constant('GPD_REFRESH_TOKEN')){
							$argRefreshToken = Configure::GPD_REFRESH_TOKEN;
						}
						if (NULL === $argRefreshToken) {
							logging('receiptverify Not exist require parameter.', 'receiptverify');
							return FALSE;
						}
					}
					$gpdFacade = new GPDFacade($argPackageName, $argClientId, $argClientSecret, $argRefreshToken);
					$subs = $gpdFacade->getSubs($recipt_array['productId'], $recipt_array['purchaseToken']);
					$expiryTime = $subs->getExpiryTime();
					$result['expire_date'] = $expiryTime->format('Y-m-d H:i:s');
					$now = new DateTime('now', new DateTimeZone('GMT'));
					if ($expiryTime < $now) {
						// 期限切れ
						$result['expired'] = TRUE;
					} else {
						// 期間内
						$result['expired'] = FALSE;
					}
					logging('receiptverify expired:' . var_export($result['expired'], TRUE), 'receiptverify');
					logging('receiptverify now:' . $now->getTimestamp(), 'receiptverify');
					logging('receiptverify now_date:' . $now->format('Y-m-d H:i:s'), 'receiptverify');
					logging('receiptverify exp:' . $subs->getExpiryTimeSeconds(), 'receiptverify');
					logging('receiptverify exp_date:' . $result['expire_date'], 'receiptverify');
				}
				// 有効である
				$result['last_receipt'] = base64_decode($argBase64EncodedReceipt);;
			}
			else {
				// 署名が正しくない(0)またはエラー(-1)
				return FALSE;
			}
		}
		else {
			// ターゲット不明
			return FALSE;
		}

		// 終了
		return $result;
	}
}

?>