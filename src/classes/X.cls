public class X {
	public static Map<String,Object> logStack = null;
	public static X_Log.LogLevel logLevel = null;

	/* Grouped logging */
	public static void cl(String logLevelString) { // commence
		// Figure out what loglevel we actually want;
		logLevel = X_Log.getLogLevelFromString(logLevelString);
		logStack = new Map<String,Object>();
	}
	public static void cl() { // commence
		cl('DEBUG');
	}
	public static void fl() { // flush
		X_Log.log(logLevel, logStack);
		logStack = null;
		logLevel = null;
	}
	public static void l(Object o) {
		logStack.put('' + logStack.keySet().size(), o);
	}
	public static void l(String s, Object o) {
		logStack.put(s, o);
	}

	/* Convenience logging */
	public static void log(X_Log.LogLevel level, String s, Object o) {
		Map<String,Object> stack = new Map<String,Object>();
		if (s == null || s == '') {
			s = '1: ';
		}
		stack.put(s, o);
		X_Log.Log(level, stack);
	}
	public static void debug(String s) {
		X.log(X_Log.LogLevel.DEBUG, null, s);
	}
	public static void debug(Object o) {
		X.log(X_Log.LogLevel.DEBUG, null, o);
	}
	public static void debug(String s, Object o) {
		X.log(X_Log.LogLevel.DEBUG, s, o);
	}
	public static void info(String s) {
		X.log(X_Log.LogLevel.INFO, null, s);
	}
	public static void info(Object o) {
		X.log(X_Log.LogLevel.INFO, null, o);
	}
	public static void info(String s, Object o) {
		X.log(X_Log.LogLevel.INFO, s, o);
	}

	public static void start() {
		X_Context context = X_Context.getInstance();
	}
	public static void end() {
		X_Context.getInstance().end();
	}
	public static void flush() {
		X_Context.getInstance().flush();
	}
	public static void exception(Object o) {
		throw new XException('' + o);
	}
	public static void dummyException(Object o) {
		throw new XException('' + o);
	}
	public static Map<String,sObject> indexBy(List<sObject> objects, String prop) {
		Map<String, sObject> result = new Map<String,sObject>();
		for (sObject obj : objects) {
			result.put((String) obj.get(prop), obj);
		}
		return result;
	}
	public static Date convertStringToDate(String s, String seperator, String format) {
		if (format == 'dmy') {
			List<String> split = s.split(seperator);
			Date d = Date.newInstance(Integer.valueOf(split.get(2)), Integer.valueOf(split.get(1)), Integer.valueOf(split.get(0)));
			return d;
		} else if (format == 'mdy') {
			List<String> split = s.split(seperator);
			Date d = Date.newInstance(Integer.valueOf(split.get(2)), Integer.valueOf(split.get(0)), Integer.valueOf(split.get(1)));
			return d;
		} else {
			return null;
		}
	}
	public static Organization currentOrg {
		get {
			if (currentOrg == null) {
				currentOrg = [SELECT Id, IsSandbox, InstanceName from Organization];
			}
			return currentOrg;
		}
		private set;
	}
	public static Boolean isSandbox() {
		return currentOrg.IsSandbox;
	}

	/* Exception class */
	public class XException extends Exception {}

	/* Response classes */

	public virtual class Response {
		public Response() {
			this(null, null, null);
		}

		public Response(Boolean success) {
			this(success, null, null);
		}

		public Response(Boolean success, List<Error> errors) {
			this(success, errors, null);
		}

		public Response(Boolean success, List<Error> errors, Object data) {
			this.success = success;
			this.errors = errors;
			this.data = data;
		}

		public Boolean success { get {
			if (success == null) { return true; }
			return success;
		} set; }
		public List<Error> errors { get; set; }
		public Object data { get; set; }
		public Blob getResult()  {
			return Blob.valueOf(JSON.serializePretty(this));
		}
	}

	public virtual class Error {
		public String text;
		public String code;
		public Object detail;

		public Error() {
			this(null, null);
		}

		public Error(String code) {
			this(code, null);
		}

		public Error(String code, Object detail) {
			this.code = code;
			this.detail = detail;
			this.text = errorToText.get(this.code);
		}

		public Error(String code, Object detail, String text) {
			this.code = code;
			this.detail = detail;
			this.text = text;
		}
	}

	public static Map<String,String> errorToText = new Map<String,String>{
			'TEST_CODE' => 'TEST TEXT'
	};

}