public class X_Context {
	private static X_Context instance = null;
	private X_Log.Log log = null;
	public X_TriggerManager triggerManager = null;
	public enum ContextTypes { TriggerContext, ApexContext, ControllerContext }
	public ContextTypes contextType = null;
	public Boolean isInFuture = false;


	private X_Context(ContextTypes contextType) {
		this.contextType = contextType;
		this.log = new X_Log.Log();
		this.log.entries = new List<X_Log.LogLine>();
		this.log.start = DateTime.now();
		this.log.contextType = this.contextType.name();
		this.log.runningUserName = UserInfo.getUserName();
		this.log.identifier = X_Util.UUID();
		this.triggerManager = X_TriggerManager.getInstance();
		this.start();
	}

	public void addLogLine(X_Log.LogLine log) {
		this.log.entries.add(log);
	}

	private void start() {}

	public void end() {
		this.log.finish = DateTime.now();
		if (this.contextType == ContextTypes.TriggerContext || this.contextType == ContextTypes.ApexContext) {
			List<DevelopmentLogLine__c> logEntries = new List<DevelopmentLogLine__c>();

			DevelopmentLog__c log = new DevelopmentLog__c(ContextType__c= this.contextType.name(), Start__c= this.log.start, End__c= this.log.finish, User__c= UserInfo.getUserId());
			insert log;

			 for (X_Log.LogLine le : this.log.entries) {
				logEntries.add(new DevelopmentLogLine__c(Level__c = le.logLevel.name(), Log__c = log.Id, Object__c = '' + le.logObjects, Timestamp__c = le.timestamp, Trace__c = '' + le.trace));
			}
			insert logEntries;
			if (!this.isInFuture && !System.isFuture()) {
				X_Log.sendLogInFuture(JSON.serializePretty(this.log));
			}
		} else if (this.contextType == ContextTypes.ControllerContext) {
			// Cannot schedule future, not do DML from a controller, but we can however log do outbound calls
			X_Log.sendLog(JSON.serializePretty(this.log));
		}
	}

	public void flush() {
		X_Log.sendLog(JSON.serializePretty(this.log));
	}

	public void handleTrigger() {
		this.triggerManager.handle();
	}

	public static X_Context getInstance() {
		if (instance == null) {
			// Very good, we want to know whether this is a trigger context or otherwise
			if (Trigger.isExecuting) {
				instance = new X_Context(ContextTypes.TriggerContext);
			} else if (ApexPages.currentPage() != null) {
				instance = new X_Context(ContextTypes.ControllerContext);
			} else {
				instance = new X_Context(ContextTypes.ApexContext);
			}
		}
		return instance;
	}

}