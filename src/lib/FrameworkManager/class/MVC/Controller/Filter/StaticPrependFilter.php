<?php

class StaticPrependFilter extends BasePrependFilter {
	public function execute($argRequestParams = NULL) {
		// スタティックファイルに対しても通常機能と同じアクセス制限を掛ける
		if (FALSE === parent::execute ( $argRequestParams )) {
			return FALSE;
		}
		// フローが有効な場合のスタティックフィルターかどうか
		if ('' === MVCCore::$flowXMLBasePath) {
			// フロー以外は無視
			return TRUE;
		}
		// スタティックファイルのAuthを代行
		if (Auth::isCertification () === TRUE) {
			return TRUE;
		}
		// Auth出来なかったのでバックフローにスタティックファイルへのFlowを登録してログイン画面へ遷移
		// Backflowの初期化
		if(NULL === Flow::$params){
			Flow::$params = array();
		}
		if(NULL === Flow::$params['backflow']){
			Flow::$params['backflow'] = array();
		}
		// 現在実行中のFlowをBackflowとして登録しておく
		$query = '';
		foreach($_GET as $key => $val){
			if('_c_' !== $key && '_a_' !== $key && '_o_' !== $key){
				if(strlen($query) > 0){
					$query .= '&';
				}
				$query .= $key.'='.$val;
			}
		}
		Flow::$params['backflow'][] = array('section' => pathInfoEX($_SERVER ['REQUEST_URI'], 'filename'), 'target' => '', 'query' => htmlspecialchars($query));
		debug('backflows=');
		debug(Flow::$params['backflow']);
		$controlerClassName = Core::loadMVCModule ('Login');
		Core::$CurrentController = new $controlerClassName ();
		if (isset ( $_SERVER ['REQUEST_METHOD'] )) {
			Core::$CurrentController->requestMethod = strtoupper ( $_SERVER ['REQUEST_METHOD'] );
		}
		Core::$CurrentController->controlerClassName = $controlerClassName;
		Core::$CurrentController->outputType = Core::$outputType;
		Core::$CurrentController->deviceType = Core::$deviceType;
		Core::$CurrentController->appVersion = Core::$appVersion;
		Core::$CurrentController->appleReviewd = Core::$appleReviewd;
		Core::$CurrentController->mustAppVersioned = Core::$mustAppVersioned;
		$res = Core::$CurrentController->execute ();
		return $res;
	}
}
?>