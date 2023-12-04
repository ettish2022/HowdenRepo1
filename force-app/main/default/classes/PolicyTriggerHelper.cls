public class PolicyTriggerHelper {
	
	public static boolean stopTrigger = false;
	
	public static void onBeforeInsert(list<Novidea_HPC__Policy__c> newPolicies){
		/* The trigger is inactive  
		if(stopTrigger) return;
    	//raniz add 03/09/2012: meant to prevent a case when during policy creation in transaction receiving a duplicate policy is created
    	//for that reason this trigger is not impelmented in before update because this doesn't happpen there. 
        populatePolicyUniqueNumberAndNumberExternal(newPolicies);
        CurrencyTriggerHelper.updateCurrency(Policy_Currency__c.getInstance(),Novidea_HPC__Policy__c.sObjectType.getDescribe(),newPolicies);
        */
	}
    
    public static void onBeforeUpdate(list<Novidea_HPC__Policy__c> oldPolicies, map<Id,Novidea_HPC__Policy__c> oldPoliciesMap,list<Novidea_HPC__Policy__c> newPolicies, map<Id,Novidea_HPC__Policy__c> newPoliciesMap){
    	/* The trigger is inactive 
		if(stopTrigger) return;
        CurrencyTriggerHelper.updateCurrency(Policy_Currency__c.getInstance(),Novidea_HPC__Policy__c.sObjectType.getDescribe(),newPolicies);
        if (WSYigod.UpdateObject){
        	system.debug('Trigger.newMap: ' + Trigger.newMap);
            TriggerHelpper.BeforeUpdating(oldPoliciesMap, newPoliciesMap, 'Novidea_HPC__Policy__c');
        }
        pupulatePolicyNumberExternal(oldPoliciesMap, newPoliciesMap);
       */
    }
    
    /* The trigger is inactive
    public static void populatePolicyUniqueNumberAndNumberExternal(list<Novidea_HPC__Policy__c> plcs){
  		for(Novidea_HPC__Policy__c plc: plcs){
        	if(plc.Novidea_HPC__Policy_Number__c!=null){
        		plc.Policy_number_External__c = plc.Novidea_HPC__Policy_Number__c;
            	plc.Unique_Policy_Number__c = plc.Novidea_HPC__Policy_Number__c + '_';
            	if(plc.Novidea_HPC__Product_Definition__c!=null){
            		plc.Unique_Policy_Number__c += plc.Novidea_HPC__Product_Definition__c;
            	}
            }
            else{
            	plc.Unique_Policy_Number__c = plc.Policy_number_External__c = null;
            }
  		}
  	}
  	
  	public static void pupulatePolicyNumberExternal(map<Id,Novidea_HPC__Policy__c> oldPoliciesMap, map<Id,Novidea_HPC__Policy__c> newPoliciesMap){
  		Novidea_HPC__Policy__c plc;
  		for(Id key: oldPoliciesMap.keyset()){
  			plc = newPoliciesMap.get(key);
  			if(plc.Novidea_HPC__Policy_Number__c==oldPoliciesMap.get(key).Novidea_HPC__Policy_Number__c)continue;
 			plc.Policy_number_External__c = plc.Novidea_HPC__Policy_Number__c;
  		}
  	}
  	*/
	
}