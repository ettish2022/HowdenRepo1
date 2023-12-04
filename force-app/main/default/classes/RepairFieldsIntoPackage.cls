global with sharing class RepairFieldsIntoPackage implements Schedulable, Database.Batchable<sObject>{
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new RepairFieldsIntoPackage(), numOfRecsInBatch);
    }
   public RepairFieldsIntoPackage(){}
   public RepairFieldsIntoPackage(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select (Select Id,Income_Recognition_Date__c, Novidea_HPC__Income_Recognition_Date__c From Novidea_HPC__Incomes__r Where Novidea_HPC__Income_Recognition_Date__c = null) ' +
      				' ,Novidea_HPC__Insurance_Type__c, Insurance_Type__c ' + 
					 ' From Novidea_HPC__Policy__c ' +
					 ' Where Novidea_HPC__Insurance_Type__c = null';
      return Database.getQueryLocator(query);
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		list<Novidea_HPC__Policy__c> polcies = (list<Novidea_HPC__Policy__c>)scope;
		list<Novidea_HPC__Income__c> incomes = new List<Novidea_HPC__Income__c>();
		for (Novidea_HPC__Policy__c policy:polcies) {
			if (policy.Insurance_Type__c != null)
				policy.Novidea_HPC__Insurance_Type__c = policy.Insurance_Type__c;
			for (Novidea_HPC__Income__c income:policy.Novidea_HPC__Incomes__r) {
				if (income.Income_Recognition_Date__c != null) {
					income.Novidea_HPC__Income_Recognition_Date__c = income.Income_Recognition_Date__c;
					incomes.add(income);
				}
				
			}
		}
		CurrencyTriggerHelper.stopTrigger = true;
		Database.update(polcies);
		Database.update(incomes);
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
        system.schedule('Update incomes' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year, CRON_EXP, new RepairFieldsIntoPackage(200));
   */
}