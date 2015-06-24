<?php

abstract class MVCControllerBase implements MVCController {

	public $controlerClassName = "";
	public $httpStatus = 200;
	public $outputType = "html";
	public $requestMethod = "GET";
	public $restResource = '';
	public $jsonUnescapedUnicode = TRUE;

	public $deviceType = "PC";
	public $appVersion = "1.0.0";
	public $appleReviewd = FALSE;
	public $mustAppVersioned = FALSE;
	public $filtered = NULL;

	public function execute(){
		return FALSE;
	}
}

?>