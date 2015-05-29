<?php

// 4行目と5行目はインストーラによって自動で書き換えられる事に注意して下さい！
$fwmpkgName = "FrameworkManager";
$fwpath = dirname(dirname(dirname(dirname(dirname(__FILE__)))))."/lib/FrameworkPackage";
// ※ココより上はインストーラーから自動で書き換えられるので、行を移動しないで下さい！内容は変えてもいいです。

if (isset($pkgName)){
	$fwmpkgName = $pkgName;
}

// 出力エンコードの明示指定
mb_http_output("UTF-8");

// 内部文字エンコードの明示指定
mb_internal_encoding("UTF-8");

// フレームワーク利用を開始する
// PROJECT_NAMEは任意指定のパラメータ
// コレの値とプロジェクト用のメインConfigureの名前を合わせておくと、色々な設定の自動走査・解決をしてくれる
define("PROJECT_NAME", $fwmpkgName);
define("MANAGER_DOCUMENT_ROOT_PATH", dirname(__FILE__).'/');
// フレームワークのコアファイルを読み込み
require_once $fwpath."/core/UNICORN";

$conName = PROJECT_NAME."Configure";

$flowPath = NULL;
if (defined($conName."::FLOWXML_PATH")){
	$flowPath = $conName::FLOWXML_PATH;
}

// 管理画面用のAuth::initをする
if (!isset($useAPI)){
	Auth::init();
	Auth::$authTable = getConfig('TOOL_AUTH_TBL_NAME');
	Auth::$authPKeyField = getConfig('TOOL_AUTH_PKEY_FIELD_NAME');
	Auth::$authIDField = getConfig('TOOL_AUTH_ID_FIELD_NAME');
	Auth::$authPassField = getConfig('TOOL_AUTH_PASS_FIELD_NAME');
	Auth::$authIDEncrypted = getConfig('TOOL_AUTH_ID_ENCRYPTED');
	Auth::$authPassEncrypted = getConfig('TOOL_AUTH_PASS_ENCRYPTED');
}

// フレームワークのMVCフレームワーク機能(FLOW版)を使う
Core::webmain($flowPath);

?>