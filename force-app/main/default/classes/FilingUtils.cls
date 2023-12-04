public with sharing class FilingUtils {
	/**
	* This is the list of objects which are available for filing
	*/
    private static FilingCriterionObject[] stdFilingCriterionObjects;
    private static FilingCriterionObject[] filingCriterionObjects;
    public static FilingCriterionObject[] getFilingCriterionObjects() {
    	if (filingCriterionObjects == null) {
	        filingCriterionObjects = new List<FilingCriterionObject>();
	        stdFilingCriterionObjects = new List<FilingCriterionObject>();
	        for(Novidea_Document_Management_List__c filingCriterion: Novidea_Document_Management_List__c.getAll().values()){
	        	if (!filingCriterion.Active__c)
	        		continue;
	        	if(!filingCriterion.Custom__c)
	        		stdFilingCriterionObjects.add(wrapFilingCriterion(filingCriterion));
				else
					filingCriterionObjects.add(wrapFilingCriterion(filingCriterion));
	        }
    	}
    	
    	return filingCriterionObjects;
    }
    
    private static FilingCriterionObject[] allfilingCriterionObjects;
    public static FilingCriterionObject[] getAllFilingCriterionObjects() {
    	if (allfilingCriterionObjects == null){
    		allfilingCriterionObjects = new List<FilingCriterionObject>(getFilingCriterionObjects());
    		allfilingCriterionObjects.addAll(stdFilingCriterionObjects);
    	}
    	return allfilingCriterionObjects;
    }
    
    public static FilingCriterionObject wrapFilingCriterion(Novidea_Document_Management_List__c filingCriterion) {
      	FilingCriterionObject fco = new FilingCriterionObject();
		fco.name =  filingCriterion.Name;
		fco.apiName = filingCriterion.Object_Type_Name__c.toLowerCase();
		fco.jsonPrefix =  filingCriterion.Json_Base_Field_Name__c;
		fco.valueInTaskConnect = filingCriterion.Value_In_Task_Connect_To_DD__c.intValue();
		fco.accountFieldName = filingCriterion.Account_Field_Api_Name__c;
		fco.accountRelationshipName = filingCriterion.Account_Relation_Api_Name__c;
		fco.relationshipToAccountImpClass = filingCriterion.Relation_To_Account_Implementation_Class__c;
		fco.jsonBaseFieldName = filingCriterion.Json_Base_Field_Name__c;
		fco.nameFieldsCsv = filingCriterion.Query_Fields_Display_Mark_Obj_Csv__c;
		fco.idFieldsCsv = filingCriterion.Additional_Identifying_Fields_Api_Csv__c;
		fco.relationToAccountFieldName = filingCriterion.This_Relation_To_Account_Api_Name__c;
		
		return fco;
    }
 
    public static Map<String, FilingCriterionObject> filingCriterionByApiName;
    public static FilingCriterionObject getFilingCriterionByApiName(String apiName){
    	if (filingCriterionByApiName == null) {
    		filingCriterionByApiName = new Map<String, FilingCriterionObject>();
    		for (FilingCriterionObject co:getAllFilingCriterionObjects()){
    			filingCriterionByApiName.put(co.apiName.toLowerCase(), co);
    		} 
    	}
    	
    	return filingCriterionByApiName.get(apiName.toLowerCase());
    }

	public static AccountSObjectRelation[] getAccountSObjectRelationsById(String entId){
		AccountSObjectRelation[] asors = new List<AccountSObjectRelation>();

		String entname = 'Name'; // TODO: Rolan - Make configurable
		String accName = 'Name'; // TODO: Rolan - Make configurable
        ID entIdId = id.valueOf(entId);

        String entTypeName = entIdId.getSobjectType().getDescribe().getName();
        if (entTypeName == 'Task')
        	entName = 'Subject';
        	
        FilingCriterionObject fco = FilingUtils.getFilingCriterionByApiName(entTypeName);
        
        if (fco == null)
        	return asors;

        if(String.isNotEmpty(fco.relationshipToAccountImpClass)){
			AccountSObjectInterface accRelImpl = fco.getInstanceOfRelationshipToAccountImpl();
			if (accRelImpl != null){
				asors = accRelImpl.getAccountSObjectRelations(new list<ID>{entId});
			}
        } 
        if(String.isEmpty(fco.relationshipToAccountImpClass) || asors.isEmpty()){
            String query = 'SELECT ' + entname + (fco.accountFieldName!=null? ',' + fco.accountFieldName + ',' + fco.accountRelationshipName + '.' + accName:'') + '\n'+
                   'FROM ' + entTypeName + '\n'+
                   'WHERE Id=\'' + entId + '\'';
            SObject[] ls = Database.query(query);
        
            for(sObject sobj: ls){
            	if (fco.accountFieldName != null){
	                SObject tempobj = sobj.getSObject(fco.accountRelationshipName);
	                system.debug('FilingUtils.getAccountSObjectRelationsById: ' + tempobj);
            		AccountSObjectRelation asor = new AccountSObjectRelation();
            		asor.accountId = (String)sobj.get(fco.accountFieldName);
            		asor.objectId = entId;
            		asor.objectName = (String)sobj.get(entname); 
            		asors.add(asor);
	                if(tempobj!=null)
	            		asor.accountName = (String)tempobj.get(accName);
            	} else if (entTypeName == 'Account'){
            		// TODO: Rolan - See if this is the correct way to handle account
            		AccountSObjectRelation asor = new AccountSObjectRelation();
            		//asor.accountId = entId;
            		//asor.accountName = (String)sobj.get(accName); 
            		asor.objectId = entId;
            		asor.objectName = (String)sobj.get(accName); 
            		asors.add(asor);
            	}
            }
        }

        return asors;
	}
}