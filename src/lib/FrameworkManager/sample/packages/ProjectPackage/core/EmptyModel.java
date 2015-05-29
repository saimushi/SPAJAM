/*
 *  %modelName%Model
 *  自由に拡張可能です
 *
 *  Copyright (c) 2014年 saimushi. All rights reserved.
 */

package com.unicorn.model;

public class %modelName%Model extends %modelName%ModelBase {

	/**
	 * 短縮コンストラクタ
	 * @param argContext Contextが入っています
	 */
	public %modelName%ModelBase(Context argContext) {
		super(argContext, Constant.PROTOCOL, Constant.DOMAIN_NAME, Constant.URL_BASE,
				Constant.COOKIE_TOKEN_NAME, Constant.SESSION_CRYPT_KEY, Constant.SESSION_CRYPT_IV, Constant.TIMEOUT);
	}
}
