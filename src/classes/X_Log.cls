public class X_Log {
	/* Enums and classes */
	public enum LogLevel { ERROR, WARN, INFO, DEBUG }

	public class Log {
		public List<LogLine> entries { get; set; }
		public String identifier { get; set; }
		public String contextType { get; set; }
		public String runningUserName { get; set; }
		public DateTime start { get; set; }
		public DateTime finish { get; set; }
	}

	public class LogLine {
		public DateTime timestamp { get; set; }
		public Map<String, Object> logObjects { get; set; }
		public Boolean success { get; set; }
		public String errorMessage { get; set; }
		public LogLevel logLevel { get; set; }
		public Caller trace { get; set; }
	}

	/* Public functions */
	static public void log(LogLevel logLevel, Map<String,Object> logObjects) {
		if (!Test.isRunningTest()) {
			LogLine le = new LogLine();
			le.timestamp = DateTime.now();
			le.logObjects = logObjects;
			le.logLevel = logLevel;
			le.trace = getCaller();
			le.success = true;
			try {
				String testJson = JSON.serialize(le.logObjects);
			} catch (Exception e) {
				le.logObjects = null;
				le.errorMessage = e.getMessage();
				le.success = false;
			}
			X_Context.getInstance().addLogLine(le);
		}
	}

	@future(callout=true)
	public static void sendLogInFuture(String serializedLog) {
		if (!System.isFuture()) {
			X_Log.sendLog(serializedLog);
		}
	}

	public static void sendLog(X_Log.Log log) {
		if (!Test.isRunningTest()) {
			sendLog(JSON.serializePretty(log));
		}
	}

	public static void sendLog(String serializedLog) {
		String endpoint = X__c.getInstance('LOG_ENDPOINT').Value__c;
		if (endpoint != null) {
			Map<String,String> headers = new Map<String,String>();
			headers.put('Content-Type', 'application/json');
			X_HTTP.Response response = X_HTTP.send(endpoint, 'POST', serializedLog, headers);
		}
	}

	public static LogLevel getLogLevelFromString(String s) {
		List<LogLevel> levels = LogLevel.values();
		for (LogLevel ll : levels) {
			if (ll.name().toLowerCase() == s.toLowerCase()) {
				return ll;
			}
		}
		return LogLevel.INFO;
	}

	/* Helper functions */
	public class Caller {
		public Caller(Method callingMethod) {
			this.callingMethod = callingMethod;
		}

		public override String toString() {
			 return toString('', '');
		}

		public String toString(String stack, String prepend) {
			prepend += '>';
			stack += prepend + callingMethod.toString() + (origin == null ? '' : '\n');
			if (origin != null) {
				return origin.toString(stack, prepend);
			}
			return stack;
		}
		Method callingMethod { get; set; }
		Caller origin { get; set; }
	}

	public class Method {
		public Method(String className, String methodName, Integer lineNumber) {
			this.className = className;
			this.methodName = methodName;
			this.lineNumber = lineNumber;
		}
		public override String toString() {
			return this.className + '.' + this.methodName + ':'+this.lineNumber;
		}
		String className { get; set; }
		String methodName { get; set; }
		Integer lineNumber { get; set; }
	}


	static private Caller getCaller() {
		Caller result = null;
		Caller lastItem = null;
		List<String> stack = new List<String>();
		try {
			X.dummyException(null);
		} catch (Exception e) {
			List<String> fullStack = e.getStacktraceString().split('\n');
			for (String s : fullStack) {
				System.debug('s: ' + s + ' Result ' + result + ' Test: ' + (result == null && s.contains('Class.X.debug') == false && s.contains('Class.X_Log.getCaller') == false && s.contains('Class.X.log') == false && s.contains('Class.X_Log') == false));
				if (result == null && s.contains('Class.X.dummyException') == false && s.contains('Class.X.debug') == false && s.contains('Class.X_Log.getCaller') == false && s.contains('Class.X.log') == false && s.contains('Class.X_Log') == false) {
					result = buildCaller(s);
					lastItem = result;
				} else if (result != null) {
					lastItem.origin = buildCaller(s);
					lastItem = lastItem.Origin;
				}
			}
		}

		return result;
	}

	static private Caller buildCaller(String s) {
		System.debug('S:' + s);
		if (s == null || s == '' || !s.contains('line')) {
			return null;
		}
		// This is ugly, use some real regex here
		List<String> s1 = s.split(':');
		List<String> s2 = s.split('line ');
		List<String> s3 = s2.get(1).split(',');
		List<String> s4 = s1.get(0).split('\\.');

		Integer lineNumber = Integer.valueOf(s3.get(0));
		String methodName = s4.get(s4.size()-1);
		s4.remove(s4.size()-1);
		String className = String.join(s4, '.');

		Method m = new Method(className, methodName, lineNumber);
		return new Caller(m);
	}
}