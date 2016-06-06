public with sharing class X_CSV {
	public List<Row> rows = null;
	public List<Column> columns = null;

	public String seperator = null;
	public String quoteType = null;
	public String newLineType = null;
	public Boolean firstRowContainsHeaders = null;
	public Pattern csvPattern = null;

	public Blob data = null;

	public X_CSV() {
		this(',', '"', '\r\n', true);
	}

	public X_CSV(String seperator, String quoteType, String newLineType, Boolean firstRowContainsHeaders) {
		this.seperator = seperator;
		this.quoteType = quoteType;
		this.newLineType = newLineType;
		this.firstRowContainsHeaders = firstRowContainsHeaders;
		this.csvPattern = this.buildPattern();
	}

	public class Column {
		String name;
		String type;
		List<Value> values;

		public Column(String name, String type) {
			this.name = name;
			this.type = type;
			this.values = new List<Value>();
		}
	}

	public class Row {
		List<Value> values;

		public Row() {
			this.values = new List<Value>();
		}

		public Map<String,Object> getAsMap() {
			Map<String,Object> rowMap = new Map<String,Object>();
			for (Value v : this.values) {
				rowMap.put(v.column.name, v.value);
			}
			return rowMap;
		}

		public Boolean isEmpty() {
			Boolean isEmpty = true;
			for (Value v : this.values) {
				if (v.value != null && v.value != '') {
					isEmpty = false;
					break;
				}
			}
			return isEmpty;
		}
	}

	public class Value {
		Column column;
		Object value;
		Row row;

		public Value(Object value, Column column, Row row) {
			this.value = value;
			this.column = column;
			this.row = row;
		}
	}

	public List<Map<String,Object>> getAsMap() {
		List<Map<String,Object>> result = new List<Map<String,Object>>();
		for (Row row : this.rows) {
			result.add(row.getAsMap());
		}
		return result;
	}

	public static X_CSV parse(String s) {
		return X_CSV.parse(Blob.valueOf(s));
	}

	public static X_CSV parse(Blob b) {
		X_CSV instance = new X_CSV();
		instance.data = b;
		instance.doParse();

		return instance;
	}

	public static X_CSV build(List<String> columnNames, Map<String,String> mapping, List<sObject> data) {
		X_CSV instance = new X_CSV();
		instance.doBuild(columnNames, data , mapping);
		return instance;
	}

	public static X_CSV build(List<String> columnNames, List<Map<String,Object>> data) {
		X_CSV instance = new X_CSV();
		instance.doBuild(columnNames, data);
		return instance;
	}

	public String outputAsCSV() {
		String result = '';
		List<String> rows = new List<String>();

		List<String> columnFields = new List<String>();
		for (Column c : this.columns) {
			columnFields.add(this.buildCSVField(c.name));
		}
		rows.add(String.join(columnFields, this.seperator));

		for (Row row : this.rows) {
			List<String> rowFields = new List<String>();
			for (Value v : row.values) {
				rowFields.add(this.buildCSVField(v.value));
			}
			rows.add(String.join(rowFields, this.seperator));
		}

		result = String.join(rows, this.newLineType);

		return result;
	}

	private String buildCSVField(Object o) {
		return buildCSVField(String.valueOf(o));
	}

	private String buildCSVField(String s) {
		if (s == null) {
			return '' + this.quoteType + this.quoteType;
		}
		return this.quoteType + s.replaceAll('"', '""') + this.quoteType;
	}

	private void doBuild(List<String> columnNames, List<sObject> data, Map<String,String> mapping) {
		this.columns = new List<Column>();
		this.rows = new List<Row>();

		for (String s : columnNames) {
			this.columns.add(new Column(s, 'String'));
		}

		for (sObject obj : data) {
			Integer i = 0;
			Row row = new Row();

			for (String s : columnNames) {
				row.values.add(new Value(obj.get(mapping.get(s)), this.columns.get(i), row));
			}
			this.rows.add(row);
			i++;
		}
	}

	private void doBuild(List<String> columnNames, List<Map<String,Object>> data) {
		this.columns = new List<Column>();
		this.rows = new List<Row>();

		for (String s : columnNames) {
			this.columns.add(new Column(s, 'String'));
		}

		for (Map<String,Object> item : data) {
			Integer i = 0;
			Row row = new Row();

			for (String s : columnNames) {
				row.values.add(new Value(item.get(s), this.columns.get(i), row));
			}
			this.rows.add(row);
			i++;
		}
	}

	private void doParse() {
		List<String> csvRows = this.splitIntoCSVRows(this.data.toString());
		// Build columns from first row
		this.columns = this.getColumns(csvRows.get(0));
		this.rows = new List<Row>();
		for (Integer i = 1; i < csvRows.size(); i++) {
			this.rows.add(this.parseLine(csvRows.get(i), this.columns));
		}
		List<Row> newRows = new List<Row>();
		for (Integer i = 0; i < this.rows.size(); i++) {
			if (this.rows.get(i).isEmpty() == false) {
				newRows.add(this.rows.get(i));
			}
		}
		this.rows = newRows;
	}

	private List<String> splitIntoCSVRows(String entireCsv) {
		return entireCsv.split(this.newLineType);
	}

	private Row parseLine(String csvLine, List<Column> columns) {
		Row row = new Row();
		List<String> values = this.parseCSVLine(csvLine);
		for (Integer i = 0; i < values.size(); i++) {
			Value v = new Value(values.get(i), columns.get(i), row);
			row.values.add(v);
			this.columns.get(i).values.add(v);
		}
		return row;
	}

	private List<Column> getColumns(String headerRow) {
		List<String> values = this.parseCSVLine(headerRow);
		List<Column> result = new List<Column>();
		for (String s : values) {
			result.add(new Column(s, 'String'));
		}
		return result;
	}

	private List<String> parseCSVLine(String stringRow) {
		List<String> matches = new List<String>();
		// We could try to split() here, but that screws up greatly if there are seperators inside quoted things
		Matcher matcher = this.csvPattern.matcher(stringRow);
		String match;
		while (matcher.find()) {
			match = matcher.group(1);
			if (match != null) {
				matches.add(match);
			}
			else {
				matches.add(matcher.group(2));
			}
		}

		return matches;
	}

	private Pattern buildPattern() {
		return Pattern.compile('(?:^|,)\\s*(?:(?:(?=")"([^"].*?)")|(?:(?!")(.*?)))(?=,|$)');
	}
}