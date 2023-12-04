global with sharing class UpdateIncomesForPolicySumsSchedImple implements Schedulable, Database.Batchable<sObject>{
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new UpdateIncomesForPolicySumsSchedImple(), numOfRecsInBatch);
    }
   public UpdateIncomesForPolicySumsSchedImple(){}
   public UpdateIncomesForPolicySumsSchedImple(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Id, Novidea_HPC__Credit_Fees__c,  Novidea_HPC__Commission_Amount__c, Novidea_HPC__Agency_Fee__c, Novidea_HPC__Policy__c,\n' +
      				' Novidea_HPC__Policy__r.Novidea_HPC__Agency_Fees_Currency__c, Novidea_HPC__Policy__r.Novidea_HPC__Premium_Amount_Currency__c, ' +
					 'Novidea_HPC__Fees__c, Novidea_HPC__Premium__c, Novidea_HPC__Endorsement_Number__c, Novidea_HPC__Agent_Discount__c,\n' +
					 'Novidea_HPC__Other_Commission__c, Novidea_HPC__Premium_To_Pay__c\n'+
					 'From Novidea_HPC__Income__c';
      return Database.getQueryLocator(query);
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		list<Novidea_HPC__Income__c> incomes = (list<Novidea_HPC__Income__c>)scope;
		Set<Id> policiesIds = new Set<Id>();
		for (Novidea_HPC__Income__c income:incomes) {
			policiesIds.add(income.Novidea_HPC__Policy__c);
			income.Novidea_HPC__Agency_Fee_Currency__c 	= income.Novidea_HPC__Policy__r.Novidea_HPC__Agency_Fees_Currency__c;
			income.Novidea_HPC__Premium_Currency__c 	= income.Novidea_HPC__Policy__r.Novidea_HPC__Premium_Amount_Currency__c;
			if (income.Novidea_HPC__Premium_Currency__c == null)
				income.Novidea_HPC__Premium_Currency__c	= income.Novidea_HPC__Policy__r.Novidea_HPC__Agency_Fees_Currency__c;
				
			if (income.Novidea_HPC__Credit_Fees__c == null)
				income.Novidea_HPC__Credit_Fees__c = 0;
			if (income.Novidea_HPC__Commission_Amount__c == null)
				income.Novidea_HPC__Commission_Amount__c = 0;
			if (income.Novidea_HPC__Agency_Fee__c == null)
				income.Novidea_HPC__Agency_Fee__c = 0;
			if (income.Novidea_HPC__Fees__c == null)
				income.Novidea_HPC__Fees__c = 0;
			if (income.Novidea_HPC__Premium__c == null)
				income.Novidea_HPC__Premium__c = 0;
			if (income.Novidea_HPC__Endorsement_Number__c == null)
				income.Novidea_HPC__Endorsement_Number__c = 0;
			if (income.Novidea_HPC__Agent_Discount__c == null)
				income.Novidea_HPC__Agent_Discount__c = 0;
			if (income.Novidea_HPC__Other_Commission__c == null)
				income.Novidea_HPC__Other_Commission__c = 0;
		}
		/*
		// Update all incomes according to the bordero date of the first one. 
		List<Novidea_HPC__Income__c> allIncomesForPolicies = 
				[Select Novidea_HPC__Endorsement_Number__c, Novidea_HPC__Bordero_Date__c, Novidea_HPC__Production_Update_Date__c, Novidea_HPC__Policy__c 
					From Novidea_HPC__Income__c
					Where Novidea_HPC__Policy__c IN :policiesIds and Novidea_HPC__Endorsement_Number__c < 0
					Order By Novidea_HPC__Policy__c, Novidea_HPC__Endorsement_Number__c DESC, Novidea_HPC__Bordero_Date__c];
		Date firstDate;
		Id currentPolicy;
		Integer currentEndorsement;
		for (Novidea_HPC__Income__c income:allIncomesForPolicies) {
			if (firstDate == null || currentPolicy != income.Novidea_HPC__Policy__c || currentEndorsement != income.Novidea_HPC__Endorsement_Number__c) {
				firstDate = income.Novidea_HPC__Bordero_Date__c;
				currentEndorsement = income.Novidea_HPC__Endorsement_Number__c;
				currentPolicy = income.Novidea_HPC__Policy__c;
			}
			income.Novidea_HPC__Policy__c = currentPolicy;
		}
		Boolean preventRunning = Novidea_HPC__Trigger__c.getInstance().Novidea_HPC__Prevent_Running__c;
		Novidea_HPC__Trigger__c.getInstance().Novidea_HPC__Prevent_Running__c = true;
		Database.update(allIncomesForPolicies);
		Novidea_HPC__Trigger__c.getInstance().Novidea_HPC__Prevent_Running__c = preventRunning;
		*/
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
        system.schedule('Update incomes' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year, CRON_EXP, new UpdateIncomesForPolicySumsSchedImple(200));
   */
}