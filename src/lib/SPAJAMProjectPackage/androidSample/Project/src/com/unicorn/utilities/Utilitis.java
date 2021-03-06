package com.unicorn.utilities;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Calendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * どこからでも呼べる便利メソッドの集まりです
 * @author c1363
 */
public class Utilitis {

	/**
	 * １６進数文字列をbyte[]に変換するメソッド
	 * @param s　文字列
	 * @return　変換後のbyte[]
	 */
	public static byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s
					.charAt(i + 1), 16));
		}
		return data;
	}

	/**
	 * 文字列をbyte[]に変換するメソッド
	 * @param hex
	 * @return　変換後のbyte[]
	 */
	public static byte[] asByteArray(String hex) {
		byte[] bytes = null;
		try {
			bytes = hex.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		// バイト配列を返す。
		return bytes;
	}

	// Converting a bytes array to string of hex character
	public static String byteArrayToHexString(byte[] b) {
		int len = b.length;
		String data = new String();

		for (int i = 0; i < len; i++) {
			data += Integer.toHexString((b[i] >> 4) & 0xf);
			data += Integer.toHexString(b[i] & 0xf);
		}
		return data;
	}

	// "YmdHis"の文字列からLineLikeな時間(Y/m/d H:i)を取得
	public static String getLineLikeDateString(String argDateString) {
		String year = argDateString.substring(0, 4);
		String month = argDateString.substring(4, 6);
		String date = argDateString.substring(6, 8);
		String hour = argDateString.substring(8, 10);
		String minute = argDateString.substring(10, 12);

		String dateString = "";

		// カレンダーオブジェクト
		Calendar cal = Calendar.getInstance();
		int nowYear = cal.get(Calendar.YEAR);
		int nowMonth = cal.get(Calendar.MONTH) + 1;
		int nowDate = cal.get(Calendar.DATE);

		if (!(Integer.valueOf(year).intValue() == nowYear)) {
			dateString = year + "/" + month + "/" + date;
		} else {
			if (!(Integer.valueOf(month).intValue() == nowMonth && Integer.valueOf(date).intValue() == nowDate)) {
				dateString = month + "/" + date;
			} else {
				dateString = hour + ":" + minute;
			}
		}

		return dateString;
	}

	// "YmdHis"の文字列から時間(Y/m/d H:i)を取得
	public static String getDateString(String argDateString) {
		String year = argDateString.substring(0, 4);
		String month = argDateString.substring(4, 6);
		String date = argDateString.substring(6, 8);
		String hour = argDateString.substring(8, 10);
		String minute = argDateString.substring(10, 12);

		String dateString = "";

		dateString = year + "/" + month + "/" + date + " " + hour + ":" + minute;

		return dateString;
	}

	public static boolean isNetworkConnected(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		if (ni != null) {
			return cm.getActiveNetworkInfo().isConnected();
		}
		return false;
	}

	public static ProgressDialog getProgressDialog(Context context, String text) {
		ProgressDialog dialog = new ProgressDialog(context);
		dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		dialog.setMessage(text);
		dialog.setCancelable(true);
		return dialog;
	}

	public static int getResoruceIdFromName(Context context, String name, String resourceType) {
		return context.getResources().getIdentifier(name, resourceType, context.getPackageName());
	}
	
	// ファイル→バイトデータ
	public static byte[] file2data(Context context, String fileName) throws Exception {
			int size;
			byte[] w = new byte[1024];
			InputStream in = null;
			ByteArrayOutputStream out = null;
			try {
				// ファイル入力ストリームのオープン
				in = context.openFileInput(fileName);

				// バイト配列の読み込み
				out = new ByteArrayOutputStream();
				while (true) {
					size = in.read(w);
					if (size <= 0)
						break;
					out.write(w, 0, size);
				}
				out.close();

				// ファイル入力ストリームのクローズ
				in.close();

				// ByteArrayOutputStreamオブジェクトのバイト配列化
				return out.toByteArray();
			} catch (Exception e) {
				try {
					if (in != null)
						in.close();
					if (out != null)
						out.close();
				} catch (Exception e2) {
				}
				throw e;
			}
		}
	
	//dialogをActivityに管理させる為にactivityを渡す必要あり
	public static void showAlert(Context context, String msg,Activity activity) {
		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
		alertDialogBuilder.setMessage(msg);
		alertDialogBuilder.setPositiveButton("OK",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
					}
				});
		alertDialogBuilder.setCancelable(true);
		AlertDialog alertDialog = alertDialogBuilder.create();
		if(activity != null){
			alertDialog.setOwnerActivity(activity);
		}
		alertDialog.show();
	}
}
