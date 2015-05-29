<?php
require_once __DIR__ . '/HttpClient.php';
require_once __DIR__ . '/GPDPurchaseSubs.php';

/**
 * Google Play Developer APIのアダプター
 *
 * @author c1718
 *        
 */
class GPDAdapter {
	const BASE_URL = 'https://www.googleapis.com/androidpublisher/v2/applications/';
	private $packageName;

	/**
	 *
	 * @param string $packageName パッケージ名
	 */
	public function __construct($packageName) {
		$this->packageName = $packageName;
	}

	/**
	 *
	 * 定期購読の購入情報を取得する
	 *
	 * @param string $subscriptionId 定期購読の商品ID
	 * @param string $token 購入レシート内にあるトークン
	 * @param string $accessToken APIにアクセスするためのトークン
	 * @return GPDPurchaseSubs 定期購読の購入情報
	 * @see https://developers.google.com/android-publisher/api-ref/purchases/subscriptions/get
	 */
	public function getSubs($subscriptionId, $token, $accessToken) {
		$path = sprintf('%s/purchases/subscriptions/%s/tokens/%s', $this->packageName, 
			$subscriptionId, $token);
		$client = new HttpClient(self::BASE_URL . $path);
		$params = array();
		$params['access_token'] = $accessToken;
		$response = $client->get($params);
		if ($response->getStatus() !== 200) {
			throw new Exception($response->getBody(), $response->getStatus());
		}
		$json = $response->getBody();
		return new GPDPurchaseSubs($json);
	}
}