<?php

// AWS利用クラスの定義
use Aws\Common\Aws;
use Aws\Common\Enum\Region;
use Aws\Sns\SnsClient;

/**
 * Amazon Simple Notification Service(Amazon SNS)を利用してモバイルデバイスに対してプッシュ通知を行います。
 *
 * @author saimushi
 * @see <a href="http://aws.amazon.com/sns/">Amazon Simple Notification Service</a>
 * @see <a href="http://docs.aws.amazon.com/aws-sdk-php/guide/latest/service-sns.html">AWS SDK for PHP documentation</a>
 */
class GenericAWSNotification
{
	/**
	 * @var integer 初期化フラグ
	 */
	protected $_initialized = FALSE;

	/**
	 * @var Aws Amazon SDKのインスタンス
	 */
	protected $_AWS = NULL;

	/**
	 * @var AWSリージョン値
	 */
	protected $_region = NULL;

	/**
	 * @var string ManagementConsoleで登録したアプリ(APNS_SANDBOX:開発用)
	 */
	protected $_arnBase = NULL;

	/**
	 * 初期化します。
	 *
	 * Configureの値をもとにAmazon SNSの初期化を行います。
	 */
	protected function _init(){
		if(FALSE === $this->_initialized){
			$baseArn = NULL;
			$apiKey = NULL;
			$apiSecret = NULL;
			$region = NULL;
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_SNS_ARN_BASE')){
				$baseArn = Configure::AWS_SNS_ARN_BASE;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_KEY')){
				$apiKey = Configure::AWS_KEY;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_SNS_API_KEY')){
				$apiKey = Configure::AWS_SNS_API_KEY;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_SECRET')){
				$apiSecret = Configure::AWS_SECRET;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_SNS_API_SECRET')){
				$apiSecret = Configure::AWS_SNS_API_SECRET;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_REGION')){
				$region = Configure::AWS_REGION;
			}
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_SNS_REGION')){
				$region = Configure::AWS_SNS_REGION;
			}
			elseif(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
				$ProjectConfigure = PROJECT_NAME . 'Configure';
				if(NULL !== $ProjectConfigure::constant('AWS_SNS_ARN_BASE')){
					$baseArn = $ProjectConfigure::AWS_SNS_ARN_BASE;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_KEY')){
					$apiKey = $ProjectConfigure::AWS_KEY;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_SNS_API_KEY')){
					$apiKey = $ProjectConfigure::AWS_SNS_API_KEY;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_SECRET')){
					$apiSecret = $ProjectConfigure::AWS_SECRET;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_SNS_API_SECRET')){
					$apiSecret = $ProjectConfigure::AWS_SNS_API_SECRET;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_REGION')){
					$region = $ProjectConfigure::AWS_REGION;
				}
				if(NULL !== $ProjectConfigure::constant('AWS_SNS_REGION')){
					$region = $ProjectConfigure::AWS_SNS_REGION;
				}
			}
			$regions = Region::values();
			if(!isset($regions[$region])){
				return FALSE;
			}
			$this->_region = $regions[$region];
			$arns = explode('://', $baseArn);
			$this->_arnBase = 'arn:aws:sns:'.$arns[0].':app/%target_pratform%/'.$arns[1];
			$this->_initialized = TRUE;
			if (NULL === $this->_AWS) {
				$this->_AWS = Aws::factory(array(
						'key'    => $apiKey,
						'secret' => $apiSecret,
						//'region' => constant('Region::'.$region)
						'region' => $this->_region
				))->get('sns');
			}
		}
	}

	/**
	 * Push通知先(EndpointArn)を登録します。
	 *
	 * @param string $argDevicetoken デバイストークン
	 * @param string $argDeviceType デバイスタイプ
	 * 		<ul>
	 * 			<li>iOS</li>
	 * 			<li>iPhone</li>
	 * 			<li>iPad</li>
	 * 			<li>iPod</li>
	 * 			<li>Android</li>
	 * 		</ul>
	 * @return Model|boolean 結果もしくはfalse
	 */
	public function createPlatformEndpoint($argDevicetoken, $argDeviceType, $argSandbox=FALSE) {
		$this->_init();
		$targetPratform = 'APNS_SANDBOX';
		logging('notify ismode='.var_export($argSandbox, true), 'push');
		debug('notify mode=test!');
		logging('notify mode=test!', 'push');
		if(FALSE === $argSandbox && TRUE === ('iOS' === $argDeviceType || 'iPhone' === $argDeviceType || 'iPad' === $argDeviceType || 'iPod' === $argDeviceType)){
			// 本番用のiOSPush通知
			debug('notify mode=release!');
			logging('notify mode=release!', 'push');
			$targetPratform = 'APNS';
		}
		else if('Android' === $argDeviceType){
			// Android用はココ！
			$targetPratform = 'GCM';
		}
		$arn = str_replace('%target_pratform%', $targetPratform, $this->_arnBase);
		logging('create endpoint arn='.$arn, 'push');
		$options = array(
				'PlatformApplicationArn' => $arn,
				'Token'                  => $argDevicetoken,
		);
		try {
			logging('PlatformApplicationArn='.$arn, 'push');
			$res = $this->_AWS->createPlatformEndpoint($options);
		} catch (Exception $e) {
			logging($e->__toString(), 'push');
			return FALSE;
		}
		logging('create endpoint res=', 'push');
		logging($res, 'push');
		return $res;
	}

	/**
	 * メッセージを通知します。
	 *
	 * @param string $argDeviceIdentifier デバイス識別子
	 * @param string $argDeviceType デバイスタイプ
	 * 		<ul>
	 * 			<li>iOS</li>
	 * 			<li>iPhone</li>
	 * 			<li>iPad</li>
	 * 			<li>iPod</li>
	 * 			<li>Android</li>
	 * 		</ul>
	 * @param string $argMessage メッセージ
	 * @param integer $argBadge バッジ数
	 * @param string $argCustomURLScheme カスタムURLスキーマ
	 * @return Model|boolean 結果もしくはfalse
	 */
	public function pushMessage($argDeviceIdentifier, $argDeviceType, $argMessage, $argBadge=1, $argCustomURLScheme=NULL, $argSandbox=FALSE) {
		$message = array('alert'=>$argMessage, 'badge' => $argBadge, 'sound' => 'default');
		if(NULL !== $argCustomURLScheme){
			$message['scm'] = $argCustomURLScheme;
		}
		return $this->pushJson($argDeviceIdentifier, $argDeviceType, $message, $argSandbox);
	}

	/**
	 * メッセージを通知します。
	 *
	 * @param string $argDeviceIdentifier デバイス識別子
	 * @param string $argDeviceType デバイスタイプ
	 * 		<ul>
	 * 			<li>iOS</li>
	 * 			<li>iPhone</li>
	 * 			<li>iPad</li>
	 * 			<li>iPod</li>
	 * 			<li>Android</li>
	 * 		</ul>
	 * @param array $argments メッセージ詳細
	 * 		<table>
	 * 			<tr>
	 * 				<td><b>key</b></td>
	 * 				<td><b>type</b></td>
	 * 				<td><b>require</b></td>
	 * 				<td><b>default</b></td>
	 * 				<td><b>description</b></td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>alert</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td></td>
	 * 				<td>メッセージ</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>badge</td>
	 * 				<td>integer</td>
	 * 				<td>true</td>
	 * 				<td>1</td>
	 * 				<td>バッジ数</td>
	 * 			</tr>
	 * 			<tr>
	 * 				<td>sound</td>
	 * 				<td>string</td>
	 * 				<td>true</td>
	 * 				<td>default</td>
	 * 				<td>通知音</td>
	 * 			</tr>
	 * 		</table>
	 * @return Model|boolean 結果もしくはfalse
	 */
	public function pushJson($argDeviceIdentifier, $argDeviceType, $argments, $argSandbox=FALSE) {
		$this->_init();
		$newEndpoint = NULL;
		$deviceEndpoint = $argDeviceIdentifier;
		logging('endpoint='.$deviceEndpoint, 'push');
		if(FALSE === strpos($argDeviceIdentifier, 'arn:aws:sns:')){
			// エンドポイント指定では無いので、先ずはAESにEndpoint登録をする
			logging('create endpoint:'.$deviceEndpoint.':'.$argDeviceType, 'push');
			$res = $this->createPlatformEndpoint($argDeviceIdentifier, $argDeviceType, $argSandbox);
			logging('pushJson for create endpoint res=', 'push');
			logging($res, 'push');
			if(FALSE !== $res){
				$newEndpoint = $res['EndpointArn'];
				$deviceEndpoint = $newEndpoint;
			}
		}
		logging('$deviceEndpoint='.$deviceEndpoint, 'push');
		try {
			$targetPratform = 'APNS_SANDBOX';
			$json = array('MessageStructure' => 'json', 'TargetArn' => trim($deviceEndpoint));
			$json['Message'] = json_encode(array($targetPratform => json_encode(array('aps' => $argments))));
			if(TRUE === ('iOS' === $argDeviceType || 'iPhone' === $argDeviceType || 'iPad' === $argDeviceType || 'iPod' === $argDeviceType)){
				if(FALSE === $argSandbox){
					// 本番用のiOSPush通知
					$targetPratform = 'APNS';
					$json['Message'] = json_encode(array($targetPratform => json_encode(array('aps' => $argments))));
				}
				if(FALSE !== strpos($deviceEndpoint, '/APNS/')){
					// 本番用のiOSPush通知
					$targetPratform = 'APNS';
					$json['Message'] = json_encode(array($targetPratform => json_encode(array('aps' => $argments))));
				}
				if(FALSE !== strpos($deviceEndpoint, '/APNS_SANDBOX/')){
					// テスト用のiOSPush通知
					$targetPratform = 'APNS_SANDBOX';
					$json['Message'] = json_encode(array($targetPratform => json_encode(array('aps' => $argments))));
				}
			}
			else if('Android' === $argDeviceType){
				// Android用はココ！
				$targetPratform = 'GCM';
				$json['Message'] = json_encode(array($targetPratform => json_encode(array('data' => $argments))));
			}
			logging($json, 'push');
			$res = $this->_AWS->publish($json);
		}
		catch (Exception $e) {
			logging($e->__toString(), 'push');
			return FALSE;
		}
		if(!is_array($res)){
			$res = array('res' => $res);
		}
		if(NULL !== $newEndpoint){
			$res['endpoint'] = $newEndpoint;
		}
		return $res;
	}
}

?>