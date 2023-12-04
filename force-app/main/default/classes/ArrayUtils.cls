public with sharing class ArrayUtils {

	/**
		tests whether the list is null or empty
	*/
	 public static boolean isMapNullOrEmpty(map<Id, sObject> pMap) {
    	return pMap == null || pMap.isEmpty();  
    } 
	
	public static boolean isListNullOrEmpty(list<object> inlist){
		return inlist==null || inlist.isEmpty(); 
	}
	
	public static boolean isSetNullOrEmpty(set<object> inset){
		return inset==null || inset.isEmpty(); 
	}
	
	public static boolean isSetNullOrEmpty(set<String> inset){
		return inset==null || inset.isEmpty(); 
	}
	public static boolean isSetNullOrEmpty(set<Id> inset){
		return inset==null || inset.isEmpty(); 
	}
	
	public static String serializeToCsv(list<String> inlist, String seperator){
   		if(isListNullOrEmpty(inlist))return null;
   		String retval='';
   		for(String val:inlist){
   			retval+= val + seperator;
   		}
		retval = retval.substring(0,retval.lastIndexOf(seperator));
		return retval;
	}
	
	public static list<Schema.PicklistEntry> getPicklistEntries(String entityName,String fieldName, map<String, Schema.SObjectType> gd){
    	Schema.SObjectType targetType = gd.get(entityName);
    	map<String, Schema.SObjectField> fieldsMap = targetType.getDescribe().fields.getMap();
    	Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
    	return fieldDesc.getPicklistValues();
    }
	
    public static map<String,String> getPicklistValues(String entityName, String pickListField, map<String, Schema.SObjectType> gd){
		list<Schema.PicklistEntry> ple = getPicklistEntries(entityName, pickListField, gd);
		map<String,String> retmap = new map<String,String>();
		for (Schema.PicklistEntry p:ple) {
			retmap.put(p.getValue(), p.getLabel());
		}
		return retmap;			
	}
	
	public static list<Schema.PicklistEntry> getPicklistEntries(String fieldName, Schema.SObjectType targetType){
    	map<String, Schema.SObjectField> fieldsMap = targetType.getDescribe().fields.getMap();
    	Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
    	return fieldDesc.getPicklistValues();
    }
	public static map<String,String> getPicklistValues(String pickListField, Schema.SObjectType targetType){
		list<Schema.PicklistEntry> ple = getPicklistEntries(pickListField, targetType);
		map<String,String> retmap = new map<String,String>();
		for (Schema.PicklistEntry p:ple) {
			retmap.put(p.getValue(), p.getLabel());
		}
		return retmap;			
	}
}