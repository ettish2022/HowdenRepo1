global with sharing class CreatePolicyShare implements  Database.Batchable<sObject>{
	
	//public classCreatePolicyAcountShareException extends Exception {}
	
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){  
        Database.executeBatch(new CreatePolicyShare(), numOfRecsInBatch);
    }
	global Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator('SELECT Id,Novidea_HPC__Client__c FROM Novidea_HPC__Policy__c '+
				 ' WHERE Policy_Type__c = \'Personal\'' );
  	}
  	
  	global void execute(Database.BatchableContext BC, list<sObject> scope){ 
		if(scope.isEmpty())return;
		
		list<Novidea_HPC__Policy__c> Policys = (list<Novidea_HPC__Policy__c>)scope;
		
		list<Novidea_HPC__Policy__Share> PolicysShare = new list<Novidea_HPC__Policy__Share>();				
		for (Novidea_HPC__Policy__c Policy: Policys){
			if (Policy.Novidea_HPC__Client__c != null) {
				Novidea_HPC__Policy__Share PolicyShare = new Novidea_HPC__Policy__Share();
				PolicyShare.ParentId 		= Policy.Id; // The account that we are trying to grant access to.
				PolicyShare.UserOrGroupId 	= System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
				PolicyShare.AccessLevel 		= 'Read';
				PolicysShare.add(PolicyShare);
			}
		}		
		Database.upsert(PolicysShare);	
		
  	}
  	global void finish(Database.BatchableContext BC){
   }
	/* Script for running the method:
   	 CreatePolicyShare be = new CreatePolicyShare();
	ID batchprocessid = Database.executeBatch(be);
   */
}