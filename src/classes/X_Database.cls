public class X_Database {
	public static Map<String, Schema.SObjectType> globalDescribe {
		get {
			if (globalDescribe == null) {
				Map<String, Schema.SObjectType> tmpDescribe = Schema.getGlobalDescribe();
				Map<String, Schema.SObjectType> lowerCaseDescribe = new Map<String, Schema.SObjectType>();
				for (String s : tmpDescribe.keySet()) {
					lowerCaseDescribe.put(s.toLowerCase(), tmpDescribe.get(s));
				}
				globalDescribe = lowerCaseDescribe;
			}
			return globalDescribe;
		}
		private set;
	}
	public static Map<String,List<String>> typeToFields {
		get {
			if (typeToFields == null) {
				typeToFields = new Map<String,List<String>>();
			}
			return typeToFields;
		}
		private set;
	}
	public static List<String> objectFields(String objectName) {
		List<String> cacheResult = typeToFields.get(objectName);
		if (cacheResult != null) {
			return cacheResult;
		} else {
			List<String> fields = new List<String>();
			Schema.DescribeSObjectResult describeResult = globalDescribe.get(objectName.toLowerCase()).getDescribe();
			Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
			for (String fs : fieldMap.keySet()) {
				fields.add(fs);
			}
			typeToFields.put(objectName.toLowerCase(), fields);
			return fields;
		}
	}
	public static Map<String,String> prefixToType {
		get {
			if (prefixToType == null) {
				prefixToType = new Map<String,String>();
				for (String s : globalDescribe.keySet()) {
					prefixToType.put(globalDescribe.get(s).getDescribe().getKeyPrefix(), s);
				}
			}
			return prefixToType;
		}
		private set;
	}

	public static List<sObject> query(String objectName) {
		return query(objectName, (String) null, (List<String>) null);
	}

	public static List<sObject> query(String objectName, String whereClause) {
		return query(objectName, whereClause, (List<String>) null);
	}
	public static List<sObject> query(String objectName, String whereClause, List<String> joinObjects) {
		String fields = String.join(objectFields(objectName), ',');

		if (joinObjects != null) {
			for (String s : joinObjects) {
				List<String> split = s.split(':');
				String obj = split.get(0);
				String relationship = split.get(1);
				for (String field : objectFields(obj)) {
					fields += ', ' + relationship + '.' + field;
				}
			}
		}

		String query = 'SELECT ' + fields + ' FROM ' + objectName;
		if (whereClause != null && whereClause != '') {
			query += ' WHERE ' + whereClause;
		}

		return doQuery(query);
	}
	public static List<sObject> query(String objectName, Set<Id> idSet) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSetToStringSet(idSet)}, (List<String>) null);
	}
	public static List<sObject> query(String objectName, Set<String> idSet) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSet}, (List<String>) null);
	}
	public static List<sObject> query(String objectName, Set<Id> idSet, List<String> joinObjects) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSetToStringSet(idSet)}, joinObjects);
	}
	public static List<sObject> query(String objectName, Set<Id> idSet, List<String> joinObjects, List<String> sortAndLimit) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSetToStringSet(idSet)}, joinObjects, sortAndLimit);
	}
	public static List<sObject> query(String objectName, Set<String> idSet, List<String> joinObjects) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSet}, joinObjects);
	}
	public static List<sObject> query(String objectName, Set<String> idSet, List<String> joinObjects, List<String> sortAndLimit) {
		return query(objectName, (String) null, new Map<String,Set<String>>{'Id' => idSet}, joinObjects, sortAndLimit);
	}
	public static List<sObject> query(String objectName, Map<String,Set<String>> whereInIdSet) {
		return query(objectName, (String) null, whereInIdSet, (List<String>) null);
	}
	public static List<sObject> query(String objectName, Map<String,Set<String>> whereInIdSet, List<String> joinObjects) {
		return query(objectName, (String) null, whereInIdSet, joinObjects);
	}
	public static List<sObject> query(String objectName, Map<String,Set<String>> whereInIdSet, List<String> joinObjects, List<String> sortAndLimit) {
		return query(objectName, (String) null, whereInIdSet, joinObjects, sortAndLimit);
	}
	public static List<sObject> query(String objectName, String whereClause, Map<String,Set<String>> whereInIdSet) {
		return query(objectName, whereClause, whereInIdSet, (List<String>) null);
	}
	public static List<sObject> query(String objectName, String whereClause, Map<String,Set<String>> whereInIdSet, List<String> joinObjects) {
		return query(objectName, whereClause, whereInIdSet, joinObjects, null);
	}
	public static List<sObject> query(String objectName, String whereClause, Map<String,Set<String>> whereInIdSet, List<String> joinObjects, List<String> sortAndLimit) {
		 String fields = String.join(objectFields(objectName), ',');

		if (joinObjects != null) {
			for (String s : joinObjects) {
				List<String> split = s.split(':');
				String obj = split.get(0);
				String relationship = split.get(1);
				for (String field : objectFields(obj)) {
					fields += ', ' + relationship + '.' + field;
				}
			}
		}

		String query = 'SELECT ' + fields + ' FROM ' + objectName;
		if (whereClause != null && whereClause != '') {
			query += ' WHERE ' + whereClause;
		}
		Set<String> idSet1 = null;
		Set<String> idSet2 = null;
		Set<String> idSet3 = null;
		Set<String> idSet4 = null;
		Set<String> idSet5 = null;

		if (whereInIdSet != null) {
			if (query.contains('WHERE')) {
				query += ' AND ';
			} else {
				query += ' WHERE ';
			}
			Integer i = 1;
			List<String> queryParts = new List<String>();
			for (String key : whereInIdSet.keySet()) {
				queryParts.add(' ' + key + ' IN :idSet'+String.valueOf(i));
				if (i == 1) {
					idSet1 = whereInIdSet.get(key);
				} else if (i == 2) {
					idSet2 = whereInIdSet.get(key);
				} else if (i == 3) {
					idSet3 = whereInIdSet.get(key);
				} else if (i == 4) {
					idSet4 = whereInIdSet.get(key);
				} else if (i == 5) {
					idSet5 = whereInIdSet.get(key);
				}
				i++;
			}
			query += String.join(queryParts, ' AND ');
		}

		if (sortAndLimit != null ) {
			if (sortAndLimit.size() > 0) {
				query += ' ' + String.join(sortAndLimit, ' ');
			}
		}

		return Database.query(query);
	}

	public static List<sObject> rawQuery(String query) {
		return doQuery(query);
	}

	public static sObject record(Id recordId) {
		String sObjectType = getSObjectType(recordId);
		List<sObject> results = query(sObjectType, new Set<String>{recordId});
		return results.get(0);
	}

	public static Set<Id> getIdSet(List<sObject> input) {
		Set<Id> idSet = new Set<Id>();
		for (sObject so : input) {
			idSet.add(so.Id);
		}
		return idSet;
	}
	public static Set<Id> idListToIdSet(List<Id> input) {
		Set<Id> idSet = new Set<Id>();
		for (Id targetId : input) {
			idSet.add(targetId);
		}
		return idSet;
	}
	public static Set<String> stringListToStringSet(List<String> input) {
		Set<String> idSet = new Set<String>();
		for (String targetId : input) {
			idSet.add(targetId);
		}
		return idSet;
	}
	public static Set<String> idSetToStringSet(Set<Id> input) {
		Set<String> idSet = new Set<String>();
		for (Id targetId : input) {
			idSet.add(String.valueOf(targetId));
		}
		return idSet;
	}
	public static Set<Id> extractIds(List<sObject> sObjects, String field) {
		Set<Id> idSet = new Set<Id>();
		for (sObject so : sObjects) {
			idSet.add((Id) so.get(field));
		}
		return idSet;
	}
	public static List<String> buildFieldQueryString(String objectName, String path) {
		List<String> fields = new List<String>();
		for (String field : objectFields(objectName.toLowerCase())) {
			fields.add(path + '.' + field);
		}
		return fields;
	}

	public static String getSObjectType(Id targetId) {
		String targetPrefix = String.valueOf(targetId).substring(0,3);
		return prefixToType.get(targetPrefix);
	}

	public static List<sObject> doQuery(String query) {
		return Database.query(query);
	}

	public static void ins(List<sObject> sObjects) {
		Database.insert(sObjects);
	}

	public static void ins(sObject sObj) {
		Database.insert(sObj);
	}

	public static void upd(List<sObject> sObjects) {
		Database.update(sObjects);
	}

	public static void upd(sObject sObj) {
		Database.update(sObj);
	}

	public static void del(List<sObject> sObjects) {
		Database.delete(sObjects);
	}

	public static void del(sObject sObj) {
		Database.delete(sObj);
	}

	public static void ups(List<sObject> sObjects) {
		Database.upsert(sObjects);
	}

	public static void ups(sObject sObj) {
		Database.upsert(sObj);
	}

	public static void ups(List<sObject> sObjects, Schema.SObjectField externalIdField) {
		Database.upsert(sObjects, externalIdField);
	}

	public static void ups(sObject sObj, Schema.SObjectField externalIdField) {
		Database.upsert(sObj, externalIdField);
	}
}