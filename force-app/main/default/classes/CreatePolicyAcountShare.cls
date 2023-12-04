global with sharing class CreatePolicyAcountShare implements Schedulable, Database.Batchable<sObject> {
	//public classCreatePolicyAcountShareException extends Exception {}
	
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new CreatePolicyAcountShare(), numOfRecsInBatch);
    }
	global Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator('SELECT Novidea_HPC__Client__c,Policy_Type__c FROM Novidea_HPC__Policy__c' +
			' WHERE Policy_Type__c = \'Personal\'' );
  	}
  	
  	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		
		list<Novidea_HPC__Policy__c> policies = (list<Novidea_HPC__Policy__c>)scope;
		
		list<AccountShare> accountsShare = new list<AccountShare>();				
		for (Novidea_HPC__Policy__c policy:policies){
			if (policy.Novidea_HPC__Client__c != null) {
				AccountShare accountShare = new AccountShare();
				accountShare.AccountId = policy.Novidea_HPC__Client__c; // The account that we are trying to grant access to.
				accountShare.UserOrGroupId = System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
				accountShare.OpportunityAccessLevel = 'Read';
				accountShare.CaseAccessLevel = 'Read';
				accountShare.AccountAccessLevel = 'Read';
				accountsShare.add(accountShare);
			}
		}		
		Database.upsert(accountsShare);	
		
  	}
  	global void finish(Database.BatchableContext BC){
   }
	/* Script for running the method:
   	 Datetime dt = Datetime.now().addMinutes(1); //change minutes here
        String min = dt.minute()+'';
        String hour = dt.hour()+'';
        String day = dt.day()+'';
        String month = dt.month()+'';
        String year = dt.year()+'';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        final String CRON_EXP = '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        system.debug(CRON_EXP);
        system.schedule('Create Policy Account Shares for External Claim Department' + '(' + CRON_EXP + ')', CRON_EXP, new CreatePolicyAcountShare());
   */
}