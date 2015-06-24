<?php

/**
 * フィルター
 * @author saimushi
 */
class BasePrependFilter {
	public function execute($argRequestParams=NULL){
		$allow = NULL;
		$denyHTTP = FALSE;
		$denyALLIP = FALSE;
		if(class_exists('Configure') && NULL !== Configure::constant('DENY_HTTP')){
			$denyHTTP = Configure::DENY_HTTP;
		}
		if(class_exists('Configure') && NULL !== Configure::constant('DENY_ALL_IP')){
			$denyALLIP = Configure::DENY_ALL_IP;
		}
		if(defined('PROJECT_NAME') && strlen(PROJECT_NAME) > 0 && class_exists(PROJECT_NAME . 'Configure')){
			$ProjectConfigure = PROJECT_NAME . 'Configure';
			if(NULL !== $ProjectConfigure::constant('DENY_HTTP')){
				$denyHTTP = $ProjectConfigure::DENY_HTTP;
			}
			if(NULL !== $ProjectConfigure::constant('DENY_ALL_IP')){
				$denyALLIP = $ProjectConfigure::DENY_ALL_IP;
			}
		}
		if(isset($_SERVER['DENY_HTTP']) && 1 === (int)strtolower($_SERVER['DENY_HTTP'])){
				// $_SERVERが最強 $_SERVERがあれば$_SERVERに必ず従う
				$denyHTTP = 1;
		}
		if(isset($_SERVER['DENY_ALL_IP']) && 0 < strlen($_SERVER['DENY_ALL_IP'])){
			// $_SERVERが最強 $_SERVERがあれば$_SERVERに必ず従う
			$denyALLIP = $_SERVER['DENY_ALL_IP'];
		}

		debug('MVCPrependFilter denyHTTP='.$denyHTTP);
		debug('MVCPrependFilter denyALLIP='.$denyALLIP);
		debug($_SERVER);

		// SSLチェック
		if(FALSE !== $denyHTTP && 0 !== $denyHTTP && "0" !== $denyHTTP){
			debug('MVCPrependFilter denyHTTP check');
			debug('MVCPrependFilter denyHTTP='.$denyHTTP);
			if(!(isset($_SERVER['HTTPS']) && 'on' === $_SERVER['HTTPS'])){
				$allow = FALSE;
			}
			else {
				$allow = TRUE;
			}
			debug('MVCPrependFilter denyHTTP ALLOW='.$allow);
		}
		// IPアドレスチェック
		if(FALSE !== $denyALLIP && 0 !== $denyALLIP && "0" !== $denyALLIP){
			debug('MVCPrependFilter denyALLIP check');
			debug('MVCPrependFilter denyALLIP='.$denyALLIP);
			// ローカルIPでは無い
			// XXX ネットマスクで許可設定をしたい場合はこの辺りを拡張する
			if('::1' !== $_SERVER['REMOTE_ADDR'] && '127.0.0.1' !== $_SERVER['REMOTE_ADDR'] && FALSE === strpos($denyALLIP, $_SERVER['REMOTE_ADDR'])){
				$allow = FALSE;
			}
			else {
				$allow = TRUE;
			}
			debug('MVCPrependFilter denyALLIP ALLOW='.$allow);
		}
		debug('MVCPrependFilter ALLOW='.$allow);
		return $allow;
	}
}

?>