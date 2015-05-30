<?php

// メモリーを大量に使うよっ！！
ini_set("memory_limit" ,"128M");

class FamiliarImageFilter
{
	public $REST;

	public function filterGet($argImageUrl){
		return $argImageUrl;
	}

	public function filterPost($argImageUrl){
		return "dummy.jpg";
	}

	public function filterPut($argImageUrl){
		$PUT = $this->REST->getRequestParams();
		if(isset($PUT["main_image"])){
			file_put_contents(Configure::ROOT_PATH.'apidocs/image/familiar' . $PUT['familiar_id'] . '.jpg', $PUT['main_image']);
			return "main.jpg";
		}
		return "dummy.jpg";
	}
}

?>