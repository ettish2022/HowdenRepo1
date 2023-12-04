global with sharing class UpdateIncomeBatchFreeUse implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext info){
        String query =
        'select Id\n' +
		'from Novidea_HPC__Income__c\n' +
		'WHERE lastmodifieddate < 2013-01-31T14:55:18.000Z\n' +
		'order by Novidea_HPC__Policy__c, Novidea_HPC__Endorsement_Number__c\n';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, list<sObject> scope) { 
        SumByCarrierHelper.stopTrigger = true;
        
        update scope;
    }
    
    global void finish(Database.BatchableContext info)
    {   
    }
}