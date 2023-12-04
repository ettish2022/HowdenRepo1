global class BatchCheckOtherCollectionFromCarrier implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator([SELECT Id,
    											Novidea_HPC__Policy__c, 
    											Novidea_HPC__Carrier__c, 
    											Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c,
    											IsOtherCarrier__c 
										   FROM Novidea_HPC__Collection_From_Carrier__c]); 
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
    	
    	list<Novidea_HPC__Collection_From_Carrier__c> incomList = (list<Novidea_HPC__Collection_From_Carrier__c>)scope; 
    	list<Novidea_HPC__Collection_From_Carrier__c> list2update =  new list<Novidea_HPC__Collection_From_Carrier__c>();
    	for(Novidea_HPC__Collection_From_Carrier__c incom : incomList) {
    		 Integer isOtherCarrier = incom.Novidea_HPC__Carrier__c != incom.Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c ? 1 : 0;
    		 if(isOtherCarrier != incom.IsOtherCarrier__c) { 
    		 	incom.IsOtherCarrier__c = isOtherCarrier;
    		 	list2update.add(incom);
    		 } 
    	}
    	
    	Database.update(list2update);
    	
    }
    
    global void finish(Database.BatchableContext BC) {
    }
	//test
	//Database.executeBatch(new BatchCheckOtherCarrier(), 200);
	
}