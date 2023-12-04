global with sharing class UpdateClaimForAccountSumSched  implements Schedulable, Database.Batchable<sObject> {
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new UpdateClaimForAccountSumSched(), numOfRecsInBatch);
    }
   public UpdateClaimForAccountSumSched(){}
   public UpdateClaimForAccountSumSched(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Id ' +
					 'From Novidea_HPC__Claim__c';
      return Database.getQueryLocator(query);
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		
		Database.update(scope);
	}

   global void finish(Database.BatchableContext BC){
   }
   
   /*
        Datetime dt = Datetime.now().addMinutes(1); //change minutes here
        String min = dt.minute()+'';
        String hour = dt.hour()+'';
        String day = dt.day()+'';
        String month = dt.month()+'';
        String year = dt.year()+'';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        final String CRON_EXP = '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        system.debug(CRON_EXP);
        system.schedule('Update incomes' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year, CRON_EXP, new UpdateClaimForAccountSumSched(200));
   */
}