public with sharing class ConstructorPoliciesUtils {
	public class ApplicationException extends Exception {
	}

	private static Map<String, Schema.SObjectType> globalDescribe;
	private static Map<String, Schema.DescribeSObjectResult> objectDescriptionMap;
	private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldsDescriptionMap;

	public static void performException(Exception exp) {
		system.debug(LoggingLevel.ERROR, exceptionDump(exp));
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, retrieveErrors(exp));
		ApexPages.addMessage(myMsg);
	}

	private static String retrieveErrors(Exception ex) {
		String msg = ex.getMessage();
		if (msg.lastIndexOf('first error:') > 0)
			msg = msg.subString(msg.lastIndexOf('first error:') + 'first error:'.length(), (msg.length() - 1));
		if (msg.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') > 0)
			msg = msg.subString(
				msg.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length(),
				(msg.length() - 1)
			);
		return msg;
	}

	private static string exceptionDump(Exception exp) {
		return 'stack : ' + exp.getStackTraceString() + '\n message :' + exp.getMessage() + '\n type :' + exp.getTypeName();
	}

	public static String addQoutationToStringOfNames(String inputString) {
		String names = '';
		for (String currentName : inputString.split('\\s*,\\s*')) {
			if (names != '')
				names += ', ';
			names += '\'' + currentName + '\'';
		}
		return names;
	}

	public static Boolean isNullOrEmpty(String str) {
		return str == null || str == '';
	}

	public static boolean isListNullOrEmpty(list<object> inlist) {
		return inlist == null || inlist.isEmpty();
	}

	public static String getFieldSetCsvString(String fieldsCsv, List<Schema.FieldSetMember> fieldSet) {
		if (fieldsCsv == null)
			fieldsCsv = '';
		for (Schema.FieldSetMember fieldSetMember : fieldSet) {
			if (fieldsCsv != '')
				fieldsCsv += ',';
			fieldsCsv += fieldSetMember.getFieldPath();
		}
		return fieldsCsv;
	}

	public static SelectOption defaultPicklistValue(String objectName, String fieldName) {
		Schema.DescribeFieldResult fieldResult = getFieldDescription(objectName, fieldName);
		list<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry picklistEntry : picklistValues) {
			if (picklistEntry.isDefaultValue()) {
				return new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel());
			}
		}
		return new SelectOption(picklistValues[0].getValue(), picklistValues[0].getLabel());
	}

	public static Schema.DescribeFieldResult getFieldDescription(String objectName, String fieldName) {
		if (fieldsDescriptionMap == null)
			fieldsDescriptionMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
		if (!fieldsDescriptionMap.containsKey(objectName))
			fieldsDescriptionMap.put(objectName, new Map<String, Schema.DescribeFieldResult>());
		if (!fieldsDescriptionMap.get(objectName).containsKey(fieldName)) {
			Schema.SObjectField field = getSObjectFieldsMap(objectName).get(fieldName);
			System.debug(LoggingLevel.INFO, 'objectName = ' + objectName + ' fieldName = ' + fieldName);
			if (field == null) {
				System.debug(LoggingLevel.INFO, getSObjectFieldsMap(objectName).keySet());
				System.debug(LoggingLevel.INFO, 'objectName = ' + objectName + ' fieldName = ' + fieldName);
			}
			Schema.DescribeFieldResult describeField = field.getDescribe();
			fieldsDescriptionMap.get(objectName).put(fieldName, describeField);
		}
		return fieldsDescriptionMap.get(objectName).get(fieldName);
	}

	public static Map<String, Schema.SObjectField> getSObjectFieldsMap(String objectName) {
		if (globalDescribe == null)
			globalDescribe = Schema.getGlobalDescribe();
		if (objectDescriptionMap == null)
			objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();

		if (!objectDescriptionMap.containsKey(objectName)) {
			SObjectType objToken = globalDescribe.get(objectName);
			objectDescriptionMap.put(objectName, objToken.getDescribe());
		}

		return objectDescriptionMap.get(objectName).fields.getMap();
	}
}