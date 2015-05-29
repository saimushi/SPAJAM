<?php
require_once __DIR__ . '/HttpClient.php';

/**
 * GoogleのOAuthを利用するためのアダプター
 *
 * @author c1718
 */
class GoogleOAuthAdapter {
	const BASE_URL = 'https://accounts.google.com/o/oauth2/token';
	private $clientId;
	private $clientSecret;

	/**
	 *
	 * @param string $clientId クライアントID
	 * @param string $clientSecret クライアントシークレット
	 */
	public function __construct($clientId, $clientSecret) {
		$this->clientId = $clientId;
		$this->clientSecret = $clientSecret;
	}

	/**
	 * リフレッシュトークンを生成する
	 *
	 * @param string $code OAuth認証時に発行されたコード
	 * @param string $redirectUri クライアントID作成時に登録したリダイレクトURI
	 * @return string リフレッシュトークン
	 * @throws Exception Googleからエラーが返されたとき
	 * @see https://developers.google.com/android-publisher/authorization
	 */
	public function generateRefreshToken($code, $redirectUri) {
		$client = new HttpClient(self::BASE_URL);
		$params = array();
		$params['grant_type'] = 'authorization_code';
		$params['code'] = $code;
		$params['client_id'] = $this->clientId;
		$params['client_secret'] = $this->clientSecret;
		$params['redirect_uri'] = $redirectUri;
		$response = $client->post($params);
		if ($response->getStatus() !== 200) {
			throw new Exception($response->getBody(), $response->getStatus());
		}
		$object = json_decode($response->getBody());
		return $object->refresh_token;
	}

	/**
	 * リフレッシュトークンを使用して新しいアクセストークンを取得する
	 *
	 * @param string $refreshToken リフレッシュトークン
	 * @return string アクセストークン
	 * @throws Exception Googleからエラーが返されたとき
	 * @see https://developers.google.com/android-publisher/authorization
	 */
	public function getNewAccessToken($refreshToken) {
		$client = new HttpClient(self::BASE_URL);
		$params = array();
		$params['grant_type'] = 'refresh_token';
		$params['client_id'] = $this->clientId;
		$params['client_secret'] = $this->clientSecret;
		$params['refresh_token'] = $refreshToken;
		$response = $client->post($params);
		if ($response->getStatus() !== 200) {
			throw new Exception($response->getBody(), $response->getStatus());
		}
		$object = json_decode($response->getBody());
		return $object->access_token;
	}
}