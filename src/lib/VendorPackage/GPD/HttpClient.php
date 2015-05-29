<?php

/**
 * HTTPクライアント
 * @author c1718
 *
 */
class HttpClient {
	private $url;
	private $sslVerifyPeer;
	private $sslVerifyHost;

	/**
	 *
	 * @param string $url URL
	 */
	public function __construct($url = '') {
		$this->url = $url;
		$this->sslVerifyPeer = true;
		$this->sslVerifyHost = true;
	}

	/**
	 * デフォルトは<code>true</code>
	 *
	 * @param boolean $verify SSL証明書の検証をする場合は<code>true</code>。検証しない場合は<code>false</code>。
	 *       
	 */
	public function setSSLVerifyPeer($verify) {
		$this->sslVerifyPeer = $verify;
	}

	/**
	 * デフォルトは<code>true</code>
	 *
	 * @param boolean $verify SSL証明書の一般名がホスト名と一致することを検証する場合は<code>true</code>。検証しない場合は<code>false</code>
	 */
	public function setSSLVerifyHost($verify) {
		$this->sslVerifyHost = $verify;
	}

	/**
	 * GETリクエストする
	 *
	 * @param array $querys クエリ文字列
	 * @return HttpResponse レスポンス
	 */
	public function get($querys) {
		$url = $this->url . '?' . http_build_query($querys);
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, $this->sslVerifyPeer);
		// http://php.net/manual/ja/function.curl-setopt.php
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, $this->sslVerifyHost ? 2 : 0);
		$body = curl_exec($ch);
		$response = new HttpResponse(curl_getinfo($ch), $body);
		curl_close($ch);
		return $response;
	}

	/**
	 * POSTリクエストする
	 *
	 * @param array $fields POSTパラメータ
	 * @return HttpResponse レスポンス
	 */
	public function post($fields) {
		$ch = curl_init($this->url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, $this->sslVerifyPeer);
		// http://php.net/manual/ja/function.curl-setopt.php
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, $this->sslVerifyHost ? 2 : 0);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
		$body = curl_exec($ch);
		$response = new HttpResponse(curl_getinfo($ch), $body);
		curl_close($ch);
		return $response;
	}
}

/**
 * HTTPレスポンス
 *
 * @author c1718
 */
class HttpResponse {
	private $info;
	private $body;

	/**
	 *
	 * @param array $info
	 * @param string $body
	 */
	public function __construct($info, $body) {
		$this->info = $info;
		$this->body = $body;
	}

	/**
	 *
	 * @return int ステータスコード
	 */
	public function getStatus() {
		return (int) $this->info['http_code'];
	}

	/**
	 *
	 * @return string ボディ
	 */
	public function getBody() {
		return $this->body;
	}
}