public class X_TriggerManager {
	private static final X_TriggerManager instance = new X_TriggerManager();
	private List<ITriggerHandler> activeTriggers = new List<ITriggerHandler>();
	private List<ITriggerHandler> finishedTriggers = new List<ITriggerHandler>();
	public static X_TriggerManager getInstance() {
		return instance;
	}

	public interface ITriggerHandler {
		void run();
	}

	virtual public class TriggerHandler implements ITriggerHandler {
		private Boolean isExecuting;
		private Boolean isInsert;
		private Boolean isUpdate;
		private Boolean isDelete;
		private Boolean isUndelete;
		private Boolean isBefore;
		private Boolean isAfter;
		public List<sObject> newsObjs;
		public List<sObject> oldsObjs;
		public Map<Id,sObject> newsobjMap;
		public Map<Id,sObject> oldsobjMap;
		public Integer size;
		public String triggerType;
		public Boolean isDone;
		public String uuid = X_Util.UUID();

		public void run() {
			this.isExecuting = Trigger.isExecuting;
			this.isInsert = Trigger.isInsert;
			this.isUpdate = Trigger.isUpdate;
			this.isDelete = Trigger.isDelete;
			this.isUndelete = Trigger.isUndelete;
			this.isBefore = Trigger.isBefore;
			this.isAfter = Trigger.isAfter;
			this.newsObjs = Trigger.new;
			this.oldsObjs = Trigger.old;
			this.size = Trigger.size;
			this.newsObjMap = new Map<Id,sObject>();
			this.oldsObjMap = new Map<Id,sObject>();
			this.isDone = false;

			if (this.newsObjs != null) {
				for (sObject sObj : this.newsObjs) {
					this.newsObjMap.put(sObj.Id, sObj);
				}
			} else {
				this.newsObjs = new List<sObject>();
			}

			if (this.oldsObjs != null) {
				for (sObject sObj : this.oldsObjs) {
					this.oldsObjMap.put(sObj.Id, sObj);
				}
			} else {
				this.oldsObjs = new List<sObject>();
			}

			this.start();
			if (this.isBefore && this.isInsert) {
				this.triggerType = 'beforeInsert';
				this.beforeInsert();
			} else if (this.isBefore && this.isUpdate) {
				this.triggerType = 'beforeUpdate';
				this.beforeUpdate();
			} else if (this.isBefore && this.isDelete) {
				this.triggerType = 'beforeDelete';
				this.beforeDelete();
			} else if (this.isAfter && this.isInsert) {
				this.triggerType = 'afterInsert';
				this.afterInsert();
			} else if (this.isAfter && this.isUpdate) {
				this.triggerType = 'afterUpdate';
				this.afterUpdate();
			} else if (this.isAfter && this.isDelete) {
				this.triggerType = 'afterDelete';
				this.afterDelete();
			} else if (this.isAfter && this.isUndelete) {
				this.triggerType = 'afterUndelete';
				this.afterUndelete();
			}
			this.printTriggerType();
			this.done();
			this.isDone = true;
		}


		private void printTriggerType() {
			if (this.oldsObjs != null) {
				//X.debug('TriggerType: ' + this.triggerType + ' for ' + this.oldsObjs.get(0).getSObjectType());
			} else {
				//X.debug('OldsObjs is null');
			}
		}

		virtual public void beforeInsert() {}
		virtual public void beforeUpdate() {}
		virtual public void beforeDelete() {}
		virtual public void afterInsert() {}
		virtual public void afterUpdate() {}
		virtual public void afterDelete() {}
		virtual public void afterUndelete() {}
		virtual public void start() {}
		virtual public void done() {}
	}

	public void handle() {
		Schema.SObjectType sObjType;
		Schema.DescribeSObjectResult sObjDescribe;
		String sObjName;

		if (!Trigger.isDelete) {
			if (Trigger.new.size() > 0) {
				sObjType = Trigger.new.get(0).getSObjectType();
			} else {
				sObjType = Trigger.old.get(0).getSObjectType();
			}
		} else {
			sObjType = Trigger.old.get(0).getSObjectType();
		}

		sObjDescribe = sObjType.getDescribe();
		sObjName = sObjDescribe.getName().replace('__c', '');

		Type relatedClass = Type.forName('OBJ_' +  sObjName + '.TriggerHandler');
		ITriggerHandler inst = (ITriggerHandler) relatedClass.newInstance();
		this.activeTriggers.add(inst);
		inst.run();
		this.activeTriggers.remove(this.activeTriggers.size()-1); // remove last trigger ...
		this.finishedTriggers.add(inst);

		X_Context ctx = X_Context.getInstance();
		if (this.activeTriggers.size() == 0 && Trigger.isAfter && ctx.contextType == X_Context.ContextTypes.TriggerContext) {
			ctx.end();
		}

	}
}