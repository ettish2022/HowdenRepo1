public with sharing class LeadTriggerHelper {
    public static Boolean stopTrigger = false;
    public static boolean inTrigger = false;
    
    public static void onBeforeInsert(list<Novidea_HPC__Lead__c> newLeads){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        setLeadDefaultClient(newLeads);     
        inTrigger = false;        
    }
    
    public static void onAfterInsert(list<Novidea_HPC__Lead__c> newLeads){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        
        inTrigger = false;    
    }
    
    public static void onBeforeUpdate(list<Novidea_HPC__Lead__c> oldLeads, 
            map<Id,Novidea_HPC__Lead__c> oldLeadsMap,
            list<Novidea_HPC__Lead__c> newLeads,
            map<Id,Novidea_HPC__Lead__c> newLeadsMap){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        
        inTrigger = false; 
    }
    public static void onAfterUpdate(list<Novidea_HPC__Lead__c> oldLeads, 
            list<Novidea_HPC__Lead__c> newLeads,
            map <Id,Novidea_HPC__Lead__c> oldLeadsMap,
            map<Id,Novidea_HPC__Lead__c> newLeadsMap){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        
        inTrigger = false; 
    }
    public static void onBeforeDelete(list<Novidea_HPC__Lead__c> oldLeads,
            map<Id,Novidea_HPC__Lead__c>oldLeadsMap){     
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        
        inTrigger = false; 
    }
    public static void onAfterDelete(list<Novidea_HPC__Lead__c> oldLeads, 
            map<Id,Novidea_HPC__Lead__c> oldLeadsMap){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
        
        inTrigger = false; 
    }
    public static void onUndelete(list<Novidea_HPC__Lead__c> newLeads){
        if(stopTrigger || inTrigger)return;
        inTrigger = true;
         
        inTrigger = false;
    }
   
   /*
   *    set lead default client if not exist on insert
   */ 
	public static void setLeadDefaultClient(list<Novidea_HPC__Lead__c> newLeads){
		
		map<String, Id> productRecordTypesByDeveloperNames = new Map<String, Id>();
        for (RecordType recordType:[select developername, Id from RecordType where sobjecttype='Novidea_HPC__Lead__c'])
             productRecordTypesByDeveloperNames.put(recordType.DeveloperName, recordType.Id);
		Default_Account__c leadClient = Default_Account__c.getInstance('AccountId'); 
		for (Novidea_HPC__Lead__c lead : newLeads){
            if (	lead.Novidea_HPC__Client__c == null 
            		&& leadClient != null 
            		&& (lead.RecordTypeId == productRecordTypesByDeveloperNames.get('Car_Lead_New_Client')
            		|| lead.RecordTypeId == productRecordTypesByDeveloperNames.get('House_Lead_New_Client')
            		|| lead.RecordTypeId == productRecordTypesByDeveloperNames.get('Dwelling'))
			)
                lead.Novidea_HPC__Client__c  = leadClient.ID__c ;
       }
   }
}