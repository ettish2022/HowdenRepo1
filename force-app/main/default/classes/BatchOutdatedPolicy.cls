global class BatchOutdatedPolicy implements Schedulable, Database.Batchable<sObject> { 
	
	private Integer numOfRecsInBatch = 50;
	
	global void execute(SchedulableContext ctx){
        Database.executeBatch(new BatchOutdatedPolicy(), numOfRecsInBatch); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator([SELECT Id, 
    											Novidea_HPC__Action__c 
								    	   FROM Novidea_HPC__Policy__c 
								    	  WHERE Novidea_HPC__Action__c = 'Active' 
								 		    AND Novidea_HPC__Expiration_Date__c < TODAY]); 
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
    	
    	list<Novidea_HPC__Policy__c> policyList = (list<Novidea_HPC__Policy__c>)scope; 
    	
    	for(Novidea_HPC__Policy__c policy : policyList) {
    		policy.Novidea_HPC__Action__c = 'Expired'; 
    	}
    	
    	Database.update(policyList, false);
    	// TBD - send an indicator regarding all the records that had problem
    	
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}