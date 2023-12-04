global with sharing class CreateClaimShare implements Schedulable, Database.Batchable<sObject>{
	
	//public classCreateclaimAcountShareException extends Exception {}
	
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){  
        Database.executeBatch(new CreateClaimShare(), numOfRecsInBatch);
    }
	global Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator('SELECT Id,Novidea_HPC__Client__c FROM Novidea_HPC__Claim__c '+
				 ' WHERE RecordType.DeveloperName = \'Personal\'' );
  	}
  	
  	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		
		list<Novidea_HPC__Claim__c> claims = (list<Novidea_HPC__Claim__c>)scope;
		
		list<Novidea_HPC__Claim__Share> claimsShare = new list<Novidea_HPC__Claim__Share>();				
		for (Novidea_HPC__Claim__c claim: claims){
			if (Claim.Novidea_HPC__Client__c != null) {
				Novidea_HPC__Claim__Share claimShare = new Novidea_HPC__Claim__Share();
				claimShare.ParentId 		= claim.Id; // The account that we are trying to grant access to.
				claimShare.UserOrGroupId 	= System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
				claimShare.AccessLevel 		= 'Edit';
				claimsShare.add(claimShare);
			}
		}		
		Database.upsert(claimsShare);	
		
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
        system.schedule('Create Claim Account Shares for External Claim Department' + '(' + CRON_EXP + ')', CRON_EXP, new CreateClaimShare());
   */
}