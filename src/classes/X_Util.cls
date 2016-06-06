public class X_Util {

	public static String UUID() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
	}

	public static String getTimestamp(String format) {
		return getTimestamp(format, null);
	}

	public static String getTimestamp(String format, String seperator) {
		return formatDate(Date.today(), format, seperator);
	}

	public static String formatDate(Date d, String format, String seperator) {
		if (seperator == null) {
			seperator = '';
		}
		if (format == 'YYYYmmdd') {
			String YYYY = String.valueOf(d.year());
			String mm = d.month() > 9 ? String.valueOf(d.month()) : '0' + String.valueOf(d.month());
			String dd = d.day() > 9 ? String.valueOf(d.day()) : '0' + String.valueOf(d.day());
			return YYYY + seperator  + mm + seperator + dd;
		}
		if (format == 'ddmmYYYY') {
			String YYYY = String.valueOf(d.year());
			String mm = d.month() > 9 ? String.valueOf(d.month()) : '0' + String.valueOf(d.month());
			String dd = d.day() > 9 ? String.valueOf(d.day()) : '0' + String.valueOf(d.day());
			return YYYY + seperator  + mm + seperator + dd;
		}
		return null;
	}

	public static Boolean isNullOrEmpty(Object o) {
		if (o == null) {
			return true;
		}
		if (String.valueOf(o) == '') {
			return true;
		}
		return false;
	}

}