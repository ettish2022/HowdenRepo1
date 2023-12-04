global with sharing class ConnectDocumentsToAccount implements Schedulable, Database.Batchable<sObject>{
	public class ConnectDocumentsToAccountException extends Exception {}
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new ConnectDocumentsToAccount(), numOfRecsInBatch);
    }
   public ConnectDocumentsToAccount(){}
   public ConnectDocumentsToAccount(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  	String query = 'Select account__c, EntId1__c,EntId2__c,EntId3__c,EntId4__c,EntId5__c,EntId6__c, ' + 
                                ' EntId7__c,EntId8__c,EntId9__c,EntId10__c,EntId11__c,EntId12__c, ' + 
                                ' EntId13__c,EntId14__c,EntId15__c,EntId16__c,EntId17__c,EntId18__c, ' + 
                                ' EntId19__c,EntId20__c ' + 
					' From InboundDocument__c  ' ;
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
        ConnectDocumentsToAccount do1 = new ConnectDocumentsToAccount(200);
        do1.OBJECT_NAME = '';
        system.schedule('Connect Documents to Accounts ' + '(' + CRON_EXP + ')', CRON_EXP, do1);
   */
}