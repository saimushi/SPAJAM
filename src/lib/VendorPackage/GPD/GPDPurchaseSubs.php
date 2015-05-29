<?php

/**
 * 定期購読の購入情報
 * @author c1718
 * @see https://developers.google.com/android-publisher/api-ref/purchases/subscriptions
 *
 */
class GPDPurchaseSubs {
	private $kind;
	private $startTimeMillis;
	private $expiryTimeMillis;
	private $autoRenewing;

	/**
	 *
	 * @param string $json JSON文字列
	 */
	public function __construct($json) {
		$array = json_decode($json, true);
		$this->kind = $this->getValue($array, 'kind', '');
		$this->startTimeMillis = $this->getValue($array, 'startTimeMillis', '0');
		$this->expiryTimeMillis = $this->getValue($array, 'expiryTimeMillis', '0');
		$this->autoRenewing = $this->getValue($array, 'autoRenewing', false);
	}

	private function getValue($array, $key, $default = '') {
		if (array_key_exists($key, $array)) {
			return $array[$key];
		}
		return $default;
	}

	/**
	 * 「androidpublisher service」での種類を表す文字列
	 *
	 * @return string 「androidpublisher#subscriptionPurchase」固定
	 */
	public function getKind() {
		return $this->kind;
	}

	/**
	 *
	 * @return int 開始エポックタイム(ミリ秒は切り捨て)
	 */
	public function getStartTimeSeconds() {
		if (strlen($this->startTimeMillis) < 4) {
			// 1秒未満
			return 0;
		}
		$str = substr($this->startTimeMillis, 0, - 3);
		return intval($str);
	}

	/**
	 *
	 * @return DateTime 開始日時(GMT)
	 */
	public function getStartTime() {
		$dt = new DateTime('now', new DateTimeZone('GMT'));
		$dt->setTimestamp($this->getStartTimeSeconds());
		return $dt;
	}

	/**
	 *
	 * @return int 期限切れエポックタイム(ミリ秒は切り捨て)
	 */
	public function getExpiryTimeSeconds() {
		if (strlen($this->expiryTimeMillis) < 4) {
			// 1秒未満
			return 0;
		}
		$str = substr($this->expiryTimeMillis, 0, - 3);
		return intval($str);
	}

	/**
	 *
	 * @return DateTime 期限切れ日時(GMT)
	 */
	public function getExpiryTime() {
		$dt = new DateTime('now', new DateTimeZone('GMT'));
		$dt->setTimestamp($this->getExpiryTimeSeconds());
		return $dt;
	}

	/**
	 * 現在の有効期限の時間に達したときにサブスクリプションが自動的に更新されるかどうか
	 *
	 * @return boolean 自動的に更新される場合は<code>true</code>
	 */
	public function isAutoRenewing() {
		return $this->autoRenewing;
	}
}