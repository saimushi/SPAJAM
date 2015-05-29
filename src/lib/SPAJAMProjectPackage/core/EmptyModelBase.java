/*
 *  %modelName%ModelBase
 *
 *  Copyright (c) 2014年 saimushi. All rights reserved.
 */

package com.unicorn.model;

import java.util.HashMap;

import android.content.Context;
import android.os.Handler;

public class %modelName%ModelBase extends ProjectModelBase {

%public%

%flags%

	/**
	 * コンストラクタです
	 * ProjectModelBaseのコンストラクタを呼び出しmodelNameに「%tableName%」をセットします
	 * @param argContext Contextが入っています
	 * @param argProtocol プロトコルが入っています
	 * @param argDomain ドメインが入っています
	 * @param argURLBase ドメイン以下のディレクトリ名が入っています
	 * @param argTokenKeyName Cookieに保存するトークンのkey名が入っています
	 * @param argCryptKey トークンの暗号化に使うKEYが入っています
	 * @param argCryptIV トークンの暗号化に使うIVが入っています
	 * @param argTimeout Timeoutまでの時間が入っています
	 */
	public %modelName%ModelBase(Context argContext, String argProtocol, String argDomain, String argURLBase,
			String argTokenKeyName, String argCryptKey, String argCryptIV, int argTimeout) {
		super(argContext, argProtocol, argDomain, argURLBase, argTokenKeyName, argCryptKey,
				argCryptIV,argTimeout);
		modelName = "%tableName%";
	}

%accesser%

	/**
	 * モデルを参照するメソッドです
	 * 通信結果を元に処理を行う場合はload(Hanler argCompletionHandler)を使用し、
	 * Hanler内で処理を分岐して下さい。
	 * @return IDが無指定の場合はfalse、それ以外はtrueを返却します。
	 */
	@Override
	public boolean load() {
		_load(null, null);
		return true;
	}

	/**
	 * モデルを参照するメソッドです
	 * 通信結果は引数として渡されたHandlerに渡されます。
	 * @param argCompletionHandler 通信後に呼び出すhandlerが入っています
	 * @return IDが無指定の場合はfalse、それ以外はtrueを返却します。
	 */
	@Override
	public boolean load(Handler argCompletionHandler) {
		completionHandler = argCompletionHandler;
		_load(null, null);
		return true;
	}

	/**
	 * モデルを保存するメソッドです
	 * @param argCompletionHandler 通信後に呼び出すhandlerが入っています
	 * @return trueを返却します。
	 */
	@Override
	public boolean save(Handler argCompletionHandler) {
		super.save(argCompletionHandler);
		save();
		return true;
	}

	/**
	 * モデルを保存するメソッドです
	 * @return trueを返却します。
	 */
	public boolean save() {
		HashMap<String, Object> argSaveParams = new HashMap<String, Object>();

		if (true == replaced) {
%save%
		}

		super.save(argsaveParams);
		return true;
	}

	/**
	 * モデルデータからMapを生成するメソッド
	 * @return このモデルを生成するために必要なMap
	 */
	@Override
	public HashMap<String, Object> convertModelData() {
		HashMap<String, Object> newMap = new HashMap<String, Object>();
%convert%
		return newMap;
	}

	/**
	 * setModelDataから呼ばれるメソッド
	 * 各モデルでOverrideして実装。モデル毎の専用変数にデータを入れて下さい
	 * @param map モデルにセットする元データ(jsonのMap) 
	 */
	@Override
	public void _setModelData(HashMap<String, Object> map) {
%set%
		resetReplaceFlagment();
	}

	/**
	 * このモデルの専用変数の更新フラグを全てリセットするメソッド
	 */
	public void resetReplaceFlagment() {
%reset%
		replaced = false;
	}
}
