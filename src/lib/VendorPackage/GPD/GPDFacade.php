<?php
require_once __DIR__ . '/GoogleOAuthAdapter.php';
require_once __DIR__ . '/GPDAdapter.php';

/**
 * Google Play Developer APIに接続するための窓口
 *
 * @author c1718
 */
class GPDFacade {
	private $gpdAdapter;
	private $googleOAuthAdapter;
	private $refreshToken;

	/**
	 *
	 * @param string $packageName パッケージ名
	 * @param string $clientId クライアントID
	 * @param string $clientSecret クライアントシークレット
	 * @param string $refreshToken リフレッシュトークン
	 */
	public function __construct($packageName, $clientId, $clientSecret, $refreshToken) {
		$this->gpdAdapter = new GPDAdapter($packageName);
		$this->googleOAuthAdapter = new GoogleOAuthAdapter($clientId, $clientSecret);
		$this->refreshToken = $refreshToken;
	}

	/**
	 * 定期購読の購入情報を取得する
	 *
	 * @param string $productId 定期購読の商品ID
	 * @param string $purchaseToken 購入レシート内にあるトークン
	 * @throws Exception 失敗したとき
	 * @return GPDPurchaseSubs 購入情報
	 */
	public function getSubs($productId, $purchaseToken) {
		if (empty($this->refreshToken)) {
			throw new Exception("RefreshToken is empty.");
		}
		// 毎回アクセストークン取得する
		$accessToken = $this->googleOAuthAdapter->getNewAccessToken($this->refreshToken);
		if (empty($accessToken)) {
			throw new Exception('Failed get accessToken.');
		}
		return $this->gpdAdapter->getSubs($productId, $purchaseToken, $accessToken);
	}
}