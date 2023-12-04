public with sharing class TriggerHelpper {
    public static Map<Id,String> accountRemarks;
    public static Map<Id,Id> oldToNew;
    
    //private static set<string> setFieldNames = new set<string>{'Logo__c'}; 
    //update fields only if the field was empty
    public static void BeforeUpdating(map<Id,SObject> oldMapSobject, map<Id,SObject> newMapSobject, string objectName  ){  
            system.debug('oldMapSobject: ' + oldMapSobject + '\nnewMapSobject: ' + newMapSobject);            
            for ( Id sobjId : oldMapSobject.keySet() ){
                    compareSobjects(oldMapSobject.get(sobjId), newMapSobject.get(sobjId), objectName );
                
            }                         
      } 
     // Make sure to query akk entId fields and account__c field too.
     public static Boolean preventInboundRunning = false;
     public static void setAccountOnDocument(List<InboundDocument__c> documents){
     	for (InboundDocument__c document:documents)
			for(integer i=1;i<=20;++i){
	           String s = (String)document.get('EntId' + i + '__c');
	           if(s==null || !s.startsWith('001'))continue;
	           document.put('account__c', (Id)s);
	           break;
	     	}
     }
       
      private static void  compareSobjects(sObject oldSobj ,Sobject newSobj, string objectName){ 
            boolean isPolicy = objectName.equalsIgnoreCase('Novidea_HPC__Policy__c');
            Map<String, Schema.SObjectField> fieldsMap =  FlatModelHelper.getSObjectFieldsMap(objectName);
            system.debug('TriggerHelpper 1st print: ' + newSObj);
            for(String fieldKey : fieldsMap.keySet()){
            	//allow rewriting the account
            	//raniz comment 5/7/12: no need to allow client update
                //if(isPolicy && fieldKey.equalsIgnoreCase('Novidea_HPC__Client__c')) continue;
                //allow rewriting the Status
                if(isPolicy){ 
                	if(fieldKey.equalsIgnoreCase('Novidea_HPC__Status__c') ||
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Original_Type__c') ||
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Broker_In_Carrier__c') ||
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Action__c')	|| 
                		fieldKey.equalsIgnoreCase('Managed_By_Production__c')	|| 
						//raniz add 16/10/2012: fields that should be updated during summation of incomes. They were blocked untill this line added.
						//will remove Novidea_HPC__Date_Written__c, Novidea_HPC__Expiration_Date__c, Novidea_HPC__Effective_Date__c, 
						//Novidea_HPC__Endorsement_Number__c from production logic
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Commission__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Agency_Fee__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Credit_Fee__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Fees__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Premium_Amount__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Endorsement_Number__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Agent_Discount__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Other_Commission__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Premium_To_Pay__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Date_Written__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Expiration_Date__c')	|| 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Effective_Date__c')	||
                		//raniz add 16/10/2012: allow update during tx process
                		fieldKey.equalsIgnoreCase('Endorsement_Approved__c') || 
                		//raniz add 21/10/2012: allow overriding exiting carrier product according to #1044 
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Carrier_Product_Number__c') ||
                		fieldKey.equalsIgnoreCase('OwnerId') ||
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Insured_Person__c') ||
                		//raniz added 17/12/2012: in order to track car number changes
						fieldKey.equalsIgnoreCase('Novidea_HPC__Car_Number__c')||
						fieldKey.equalsIgnoreCase('Novidea_HPC__Vehicle_Model__c')||
						fieldKey.equalsIgnoreCase('Novidea_HPC__Vehicle_Manufacturer__c')||
						fieldKey.equalsIgnoreCase('Novidea_HPC__Vehicle_Production_Year__c')||
						fieldKey.equalsIgnoreCase('Novidea_HPC__Payments_Number__c')||
                		fieldKey.equalsIgnoreCase('Novidea_HPC__Policy_Number__c') && 
                		oldSobj.get('Novidea_HPC__Policy_Number__c')!=null &&
                		((String)oldSobj.get('Novidea_HPC__Policy_Number__c')).startsWith('-'))
                	continue;
                }
                Schema.SObjectField fieldName = fieldsMap.get(fieldKey);
                //TODO create function to deal with special logic 
                
                // if there is a value in field before the update then don't update
                if(newSobj.get(fieldName) != oldSobj.get(fieldName) && newSobj.get(fieldName) != null && 
                  newSobj.get(fieldName) != '' && oldSobj.get(fieldName)!= null && 
                  FlatModelHelper.getFieldDescription(objectName,string.valueOf(fieldName)).isUpdateable()){
                    system.debug('newSobj.get(fieldName)' +newSobj.get(fieldName) +' oldSobj.get(fieldName)'+ oldSobj.get(fieldName));
                    newSobj.put(fieldName,oldSobj.get(fieldName));
                }
            }
            system.debug('TriggerHelpper 2nd print: ' + newSObj);
      }
	
	@future 
  	public static void approvalProcess(Set<Id> policiesIds) {
  		/**/
    	Map<Id, Novidea_HPC__Policy__c> policyMap = new Map<Id, Novidea_HPC__Policy__c>([Select Id, ownerId, owner.Profile.Name From Novidea_HPC__Policy__c Where Id IN :policiesIds]);
    	Map<Id, User> users = new Map<Id, User> ([Select Id, ManagerId From User]);
    	for (Id policyId:policyMap.keySet()) {
    		if (policyMap.get(policyId).Owner.Profile.Name == 'מנהל מערכת' ||
    				policyMap.get(policyId).Owner.Profile.Name == 'System Administrator'  ||
    				users.get(policyMap.get(policyId).OwnerId).ManagerId== null) 
    			continue;
	    	Approval.ProcessSubmitRequest req1 = 
	            new Approval.ProcessSubmitRequest();
	        req1.setComments('Submitting request for approval.');
	        req1.setObjectId(policyId);
	        Approval.ProcessResult result = Approval.process(req1);
    	}
    	/**/
  	}
  	
  	
  	public static void updatePolicyManagedByProduction(Set<Id> policiesIds){
  		if(!WSYigod.keepManagedByProductionOn && General__c.getInstance().Set_Policy_Managed_By_Production_Off__c){
    		list<Novidea_HPC__Policy__c> plcs = [SELECT Managed_By_Production__c 
    											FROM Novidea_HPC__Policy__c 
    											WHERE Id IN :policiesIds 
    											AND Managed_By_Production__c = true];
    		for(Novidea_HPC__Policy__c plc: plcs){
    			plc.Managed_By_Production__c = false;
    		}
    		boolean stopTriggerState = CurrencyTriggerHelper.stopTrigger;
    		boolean st = PolicyTriggerHelper.stopTrigger;
    		try{
    			CurrencyTriggerHelper.stopTrigger = true;
    			PolicyTriggerHelper.stopTrigger = true;
    			Database.update(plcs);
    		}
    		finally{
    			CurrencyTriggerHelper.stopTrigger = stopTriggerState;
    			PolicyTriggerHelper.stopTrigger = st;
    		}
    	}
  	}
}