<?php

// AWS利用クラスの定義
use Aws\Common\Aws;
use Aws\Common\Enum\Region;
use Aws\S3\Enum\CannedAcl;
use Aws\S3\Exception\S3Exception;
use Guzzle\Http\EntityBody;

/**
 * Amazon Simple Storage Service(Amazon S3)を利用したストレージクラス。
 *
 * @author saimushi
 * @see <a href="http://aws.amazon.com/s3/">Amazon Simple Notification Service</a>
 * @see <a href="http://docs.aws.amazon.com/aws-sdk-php/guide/latest/service-s3.html">AWS SDK for PHP documentation</a>
 */
class GenericAWSS3
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
	 * @var 作業ファイル保存先ディレクトリパス
	 */
	protected $_tmpPath = NULL;

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
			if(class_exists('Configure') && NULL !== Configure::constant('AWS_S3_TMP_DIR')){
				$this->_tmpPath = Configure::AWS_S3_TMP_DIR;
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
				if(class_exists('Configure') && NULL !== $ProjectConfigure::constant('AWS_S3_TMP_DIR')){
					$this->_tmpPath = $ProjectConfigure::AWS_S3_TMP_DIR;
				}
			}
			$this->_initialized = TRUE;
			if (NULL === $this->_AWS) {
				$regions = Region::values();
				if(!isset($regions[$region])){
					return FALSE;
				}
				$this->_region = $regions[$region];
				$this->_AWS = Aws::factory(array(
						'key'    => $apiKey,
						'secret' => $apiSecret,
						'region' => $this->_region,
						'curl.options' => array(
								'CURLOPT_CONNECTTIMEOUT' => 300
						)
				))->get('s3');
			}
		}
	}

	/**
	 * ファイル( or バイナリ)を指定されたS3バケットに保存します。
	 */
	public function saveBinary($argFileKey, $argFileMimeType, $argBinary, $argPublic=TRUE, $argTimeout=300) {
		$this->_init();
		if(NULL === $this->_tmpPath){
			// XXX 定義エラー
			// 一次領域の定義が無い時、saveBinaryは機能しない！
			return FALSE;
		}
		// 一次領域に保存
		$filePath = $this->_tmpPath.'/s3tmp'.sha1($argFileKey.time());
		@file_put_contents($filePath, $argBinary);
		$res = $this->save($argFileKey, $argFileMimeType, $filePath, $argPublic, $argTimeout);
		// ゴミ掃除
		@unlink($filePath);
		return $res;
	}

	/**
	 * 指定されたファイルパス上のファイルを指定されたS3バケットに保存します。
	 */
	public function save($argFileKey, $argFileMimeType, $argFilePath, $argPublic=TRUE, $argTimeout=300) {
		$filePath = NULL;
		$this->_init();
		// S3の指定バケットにファイルをアップロードする
		try {
			$paths = explode('/', $argFileKey);
			$bucket = $paths[0];
			$bucketKey = substr($argFileKey, strlen($bucket)+1);
			$property = array('Bucket' => $bucket,
					'Key'    => $bucketKey,
					'Body' => EntityBody::factory(fopen($argFilePath, "r")),
					'ContentType' => $argFileMimeType,
					// XXX この辺の設定のカスタマイズは後々！？
					// 非永続型アップロード
					'StorageClass' => 'REDUCED_REDUNDANCY',
					// 'ServerSideEncryption' => 'AES256', 暗号はせずにファイルをアップロード
			);
			if (TRUE === $argPublic){
				$property['ACL'] = CannedAcl::PUBLIC_READ;
			}
			$response = $this->_AWS->putObject($property);
			$filePath = 'https://s3-' . $this->_region . '.amazonaws.com/' . $bucket . '/' . $bucketKey;
		}
		catch (S3Exception $Exception) {
			debug('s3 exception!');
			logging($Exception->__toString(), 'excption');
			// S3へのアップロード失敗
			return FALSE;
		}
		return $filePath;
	}
}

?>