global with sharing class DeleteObjects implements Schedulable, Database.Batchable<sObject>{
	public class DeleteObjectsException extends Exception {}
	public static final String OBJECT_NAME = (String)Delete_Object__c.getInstance().get('Object_Name__c');
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new DeleteObjects(), numOfRecsInBatch);
    }
   public DeleteObjects(){}
   public DeleteObjects(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  if (OBJECT_NAME != null) {
   	  	String query = 'Select Id From ' + OBJECT_NAME;
   	  	if (OBJECT_NAME.toLowerCase() == 'account') {
   	  		throw new DeleteObjectsException('Use account recordType.DeveloperName to define which accounts to delete in the format account___XXXXX');
   	  	}
   	  	if (OBJECT_NAME.toLowerCase().split('___')[0] == 'account') {
   	  		String wantedType = OBJECT_NAME.toLowerCase().split('___')[1];
   	  		query = 'select id from account where RecordType.DeveloperName = \'' + wantedType + '\'';
   	  	}
   	  	if (OBJECT_NAME == 'Slavik') {
   	  		String obj = 'Novidea_HPC__Income__c';
   	  		String usr = '005D0000001zboz';  //Howden_prod
   	  		query = 'select id from ' + obj + ' where createdById = \'' + usr + '\' and External_Id__c like \'E_%_Without_Commisions\'';
   	  	}
   	  	if (OBJECT_NAME.startsWith('Query:')) {
   	  		query = OBJECT_NAME.split('Query:')[1];
   	  	}
      	return Database.getQueryLocator(query);
   	  }
   	  return null;
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		Database.delete(scope);
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
        system.schedule('Delete Objects' + '(' + CRON_EXP + ')', CRON_EXP, new DeleteObjects(200));
   */
}