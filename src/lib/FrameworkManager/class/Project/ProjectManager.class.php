<?php

class ProjectManager
{
	public static function createProject($argProjectName=''){
		$conName = PROJECT_NAME."Configure";
		debug('$argProjectName='.$argProjectName);
		$samplePackage = $conName::SAMPLE_PROJECT_PACKAGE_PATH;
		$newProjectName = str_replace('Package', '', ucfirst($argProjectName.basename($samplePackage)));
		debug('$newProjectName='.$newProjectName);
		// 移動先のパス
		$movePath = dirname($conName::PROJECT_ROOT_PATH).'/'.$newProjectName.'Package';
		debug('$movePath='.$movePath);
		if(!dir_copy($samplePackage, $movePath)){
			return FALSE;
		}
		// プロジェクト名が指定されている場合は、デフォルトの定義を書き換えて上げる為の処理
		if('' !== $argProjectName){
			// config.xmlのファイル名を書き換える
			$newConfigXMLPath = $movePath.'/core/' . $newProjectName . '.config.xml';
			rename($movePath . '/core/Project.config.xml', $newConfigXMLPath);
			// package.xmlのファイル名を書き換える
			rename($movePath . '/core/Project.package.xml', $movePath.'/core/' . $newProjectName . '.package.xml');
			// config.xml内のプロジェクト名を書き換える
			$configXMLStr = file_get_contents($newConfigXMLPath);
			$configXMLStr = str_replace(array('<Project>', '</Project>'), array('<'.$newProjectName.'>', '</'.$newProjectName.'>'), $configXMLStr);
			// 新しい定義で書き換え
			file_put_contents($newConfigXMLPath, $configXMLStr);
			// 重いのでコマメにunset
			unset($configXMLStr);
			// RESRAPI-index内のプロジェクト名を書き換える
			$apidocPath = $movePath.'/apidocs';
			$apiIndexStr = file_get_contents($apidocPath.'/index.php');
			$apiIndexStr = str_replace('$projectpkgName = "Project";', '$projectpkgName = "'.ucfirst($newProjectName).'";', $apiIndexStr);
			// 新しい定義で書き換え
			file_put_contents($movePath.'/apidocs/index.php', $apiIndexStr);
			// 重いのでコマメにunset
			unset($apiIndexStr);

			// iOSサンプル内のプロジェクト内のRESTfulAPIの向け先を変える
			$iosdefineStr = file_get_contents($movePath.'/iOSSample/Project/SupportingFiles/define.h');
			// REQUEST_URI と $movePath からローカルのドキュメントルートPathを特定する
			$tmpPath = dirname(dirname($_SERVER["REQUEST_URI"]));
			$tmpPaths = explode('/lib/'.PROJECT_NAME.'/', $tmpPath);
			$documentRoot = $tmpPaths[0];
			$movePaths = explode('/lib/'.$newProjectName.'Package', $movePath);
			$tmpPaths = explode($documentRoot, $movePaths[0]);
			$baseURL = $documentRoot.'/lib/'.$newProjectName.'Package/apidocs/';
			if (isset($tmpPaths[1]) && 0 < strlen($tmpPaths[1])){
				$baseURL = $documentRoot.'/'.$tmpPaths[1].'/lib/'.$newProjectName.'Package/apidocs/';
			}
			$iosdefineStr = str_replace('#   define URL_BASE @"/workspace/UNICORN-project/lib/FrameworkManager/template/managedocs/api/"', '#   define URL_BASE @"'.$baseURL.'"', $iosdefineStr);
			// 新しい定義で書き換え
			file_put_contents($movePath.'/iOSSample/Project/SupportingFiles/define.h', $iosdefineStr);
			// 重いのでコマメにunset
			unset($iosdefineStr);

			// XXX Android用の処理
		}
		return TRUE;
	}

	public static function migrateAppModel($argTargetProjectName, $argTargetPlatform){
		$DBO = DBO::sharedInstance(getConfig('DB_DSN', $argTargetProjectName));
		$tables = $DBO->getTables();
		for ($tblIdx=0; $tblIdx < count($tables); $tblIdx++){
			// テーブル毎にマイグレーション
			AppMigrationManager::generateModel($DBO, $tables[$tblIdx], $argTargetProjectName, $argTargetPlatform);
		}
		return TRUE;
	}
}

?>