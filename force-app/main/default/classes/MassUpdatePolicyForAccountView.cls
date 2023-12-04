global class MassUpdatePolicyForAccountView implements Schedulable, Database.Batchable<sObject> {
	
	private Integer numOfRecsInBatch = 200;
	
   global void execute(SchedulableContext ctx){
        Database.executeBatch(new MassUpdatePolicyForAccountView(), numOfRecsInBatch);
   }
   
   public MassUpdatePolicyForAccountView(){}
   
   public MassUpdatePolicyForAccountView(Integer numOfRecsInBatch){
   		this.numOfRecsInBatch = numOfRecsInBatch;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT Id FROM Novidea_HPC__Policy__c'; 
      return Database.getQueryLocator(query);
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		
		Database.update(scope);
	}

   global void finish(Database.BatchableContext BC){
   }
}