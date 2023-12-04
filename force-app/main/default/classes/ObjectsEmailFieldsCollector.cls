public with sharing class ObjectsEmailFieldsCollector {
	
	private static Map<String, Schema.SObjectType> globalDescribe;
	private static Map<String, Schema.DescribeSObjectResult> objectDescriptionMap;
	
	private static final Integer MAX_DEPTH = 1; // TODO: Take value from custom label 
	
	public static Map<String, Schema.SObjectField> getSObjectFieldsMap(String objectName){
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
	
	public static Integer depth = 0;
	public static List<string> getEmailFieldsForObject(String objectName, List<String> fieldsToExclude){
        list<string> emailFields = new list<string>();
        list<string> lookupEmailFields = new list<string>();
        
       	System.debug('Processing object ' + objectName);
        Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();
                
        Map<String, Schema.SObjectField> fieldsMap = getSObjectFieldsMap(objectName);
        Set<String> fields = fieldsMap.keySet();
        String relationshipName;
        
		if (objectName == 'Contact' || objectName == 'Account'){
	      	//System.debug('Adding Name field');
       		//emailFields.add('Name');
		}
		
        for (String field: fields){
        	//System.debug('Processing field ' + field);
            SOBjectField f = fieldsMap.get(field);
            Schema.DescribeFieldResult fdr = f.getDescribe();
            
            if (fdr.getLabel() != 'Deleted' && fdr.isAccessible()){                
	            Schema.DisplayType fieldType = fdr.getType();
	            if (fieldType == Schema.DisplayType.Email){
	            	emailFields.add(fdr.getName());
		        	//System.debug('Adding field ' + field + ' as email');
	            } else if (fieldType == Schema.DisplayType.Reference){
	            	String relObjectName = fdr.getReferenceTo()[0].getDescribe().getName();
	            	if (fieldsToExclude != null){
	            		boolean exclude = false;
	            		for (String exFld: fieldsToExclude)
	            			if (exFld == fdr.getName()){
	            				System.debug('Excluded: ' + exFld);
	            				exclude = true;
	            				break;
	            			}
	            		if (exclude)
	            			continue;
	            	}
	            			
	            	if (fdr.getName() == 'parentId' 
	            		|| relObjectName == 'User' 
	            		|| relObjectName == 'Group'
	            		|| fdr.getName() == 'reportstoid'
	            		|| fdr.getName() == 'masterrecordid'
	            		|| fdr.getName() == 'whoid'
	            		|| fdr.getName() == 'whatid'
	            		)
	            		continue;
					if (++depth > MAX_DEPTH){
		           		depth--;
				       	System.debug('Skipped field ' + fdr.getName() + ' in object ' + objectName);
					} else {
			        	//System.debug('Processing field ' + field + ' as lookup');
		            	String relName = fdr.getRelationshipName();
		            	for(string refEmailField: getEmailFieldsForObject(relObjectName, null)){
		               		lookupEmailFields.add(relName+'.'+refEmailField);
		           		}
		           		depth--;
					}
	        	}
            }
        }
        //system.debug(emailFields);
        emailFields.addAll(lookupEmailFields);
        return emailFields;
    }
	
	public static List<EmailRecipient> getEmailFieldsForObjectRelatedLists(ID pId){
		List<EmailRecipient> emailAddrs = new List<EmailRecipient>();
		String objectName = pId.getSobjectType().getDescribe().getName();
        List<Schema.ChildRelationship> childRels = Schema.getGlobalDescribe().get(objectName).getDescribe().getChildRelationships();
        for (Schema.ChildRelationship rel: childRels){
        	depth++;
        	String objName = rel.getChildSObject().getDescribe().getName();
        	if (objName == 'Contact' || objName == 'Account'){
        		String relFieldName = rel.getField().getDescribe().getName();
        		list<string> emailFields = getEmailFieldsForObject(objName, new List<String>{relFieldName});
        		emailAddrs.addAll(getEmailAddrs(objName,pId, relFieldName, emailFields));
        	}
        	depth--;
        }
        
        return emailAddrs;
	}
	

	public static List<EmailRecipient> getEmailAddrs(String objectName, ID pId, String idField, List<String> fieldsToQuery){
		List<EmailRecipient> fieldRes = new list<EmailRecipient>();
		
		if (fieldsToQuery == null || fieldsToQuery.size() == 0)
			return fieldRes;
			
		String qryStr = 'SELECT ' + String.join(fieldsToQuery,',') + ' FROM ' + objectName + ' WHERE ' + idField + ' =\'' + pId + '\'';
		system.debug(qryStr);
		SObject[] res = Database.query(qryStr);
		for(Sobject currResult: res){
			String currName;
			for (String f: fieldsToQuery){
				String currFieldValue = (string)getFieldFromQueryResult(f,currResult);
				if (f.endsWithIgnoreCase('Name'))
					currName = currFieldValue;
				else if (!String.isEmpty(currFieldValue)){
					System.debug('Found email: ' + currFieldValue + ' in: ' + objectName + '.' + f + ': ' + idField + ':' + pId);
					fieldRes.add(new EmailRecipient(currName, currFieldValue));
				}
			}
		}

		return fieldRes;
	}

	public class EmailRecipient {
		public String name {get;set;}
		public String email {get;set;}
		
		public EmailRecipient(String name, String email){
			this.name = name;
			this.email = email;
		}
	}
	
	// TODO: Rename the methods
	public static List<EmailRecipient> getEmailAddrs(ID pId){
		// Translate the ID to the API name of the object
		if(pId == null)return null;
		String objectName = pId.getSobjectType().getDescribe().getName();
		
		// Get the list of field which might contain email addresses
		List<String> emailFields = ObjectsEmailFieldsCollector.getEmailFieldsForObject(objectName, null);
		// TODO: Consider moving this into the getEmailFieldsForObject method
		String nameField;
		if (objectName == 'Task')
			nameField = 'Subject';
		else
			nameField = 'Name';

		// Name field should be first, in order to display the email addresses by name 
		if (emailFields.size() > 0) 
			emailFields.add(0, nameField);
		else
			emailFields.add(nameField);
		
		// Query the data from the fields to contain the email associated with the person name
		list<EmailRecipient> fieldRes = ObjectsEmailFieldsCollector.getEmailAddrs(objectName, pId, 'ID', emailFields);

		fieldRes.addAll(getEmailFieldsForObjectRelatedLists(pId));
		
		return fieldRes;
	}
	
    public static object getFieldFromQueryResult(String answerField, SObject queryResult){
        String field = answerField;
        if (field.indexOf('.') < 0)
            return queryResult.get(field);
            
        SObject objResult;
        String objName = field.substring(0,field.indexOf('.'));
        field = field.substring(field.indexOf('.')+1);
        objResult = queryResult.getSObject(objName);
        while (field.indexOf('.') > 0 && objResult != null){
            objName = field.substring(0,field.indexOf('.'));
            field = field.substring(field.indexOf('.')+1);
            objResult = objResult.getSObject(objName);
        }
        
        if (objResult != null)
            return objResult.get(field);
        else
            return null;
    }   
}