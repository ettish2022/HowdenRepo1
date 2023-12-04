global with sharing class UpdateIncomeHistoryTax implements Schedulable, Database.Batchable<sObject>{
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new UpdateIncomeHistoryTax(), numOfRecsInBatch);
    }
    private static String directCarrierIds = '001D000000qdGOn';
    private static Set<String> brokerIds = new Set<String>{'001D000000qdGLH', '001D000000qdGLF'};
	private static Set<String> isrealiCarrierIds = new Set<String>{'001D000000qdGPH', '001D000000qdGLG', '001D000000qdGP5', '001D000000qdGLI', '001D000000qdGOA', '001D000000qdGOa'};
	private static String howdenUnderwriters = '001D000000qdGOy';
   public UpdateIncomeHistoryTax(){}
   public UpdateIncomeHistoryTax(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
   		String brokerIdsArrayString = '';
   		for (Id brokerId:brokerIds) {
   			if (brokerIdsArrayString != '')
   				brokerIdsArrayString += ',';
   			brokerIdsArrayString += '\'' + brokerId + '\'';
   		}
   		brokerIdsArrayString = '(' + brokerIdsArrayString + ')';
   		
   		String isrealiCarrierIdsArrayString = '';
   		for (Id isrealiCarrierId:isrealiCarrierIds) {
   			if (isrealiCarrierIdsArrayString != '')
   				isrealiCarrierIdsArrayString += ',';
   			isrealiCarrierIdsArrayString += '\'' + isrealiCarrierId + '\'';
   		}
   		isrealiCarrierIdsArrayString = '(' + isrealiCarrierIdsArrayString + ')';
      	String query = 'Select Income_Recognition_Date__c, Novidea_HPC__Local_Tax__c, Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c, Novidea_HPC__Policy__r.Novidea_HPC__Value_Date__c, ' +
      			' Novidea_HPC__Policy__r.Insurance_Type__c ' +
				' From Novidea_HPC__Income__c ' + 
				' Where ' +
				' Novidea_HPC__Policy__r.Insurance_Type__c IN (\'Direct\',\'Front\') '
				/*
				'(' + ' Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c = \'' + howdenUnderwriters + '\'' + ')' + ' Or ' + 
				'(' + ' Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c = \'' + directCarrierIds + '\'' + ')' + ' Or ' +
				'(' + ' Novidea_HPC__Carrier__c IN ' + brokerIdsArrayString + ' And ' + 
				' Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c IN ' + isrealiCarrierIdsArrayString+ ')' 
				*/;
      return Database.getQueryLocator(query);
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		
		list<Novidea_HPC__Income__c> incomes = (list<Novidea_HPC__Income__c>)scope;
		for (Novidea_HPC__Income__c income:incomes) {
			Date incomeDate = income.Income_Recognition_Date__c;
			if (incomeDate > income.Novidea_HPC__Policy__r.Novidea_HPC__Value_Date__c)
				incomeDate = income.Novidea_HPC__Policy__r.Novidea_HPC__Value_Date__c;
			if (/*isrealiCarrierIds.contains(income.Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c) ||
					income.Novidea_HPC__Policy__r.Novidea_HPC__Carrier__c == 'a0ND0000004TCiN'*/
					income.Novidea_HPC__Policy__r.Insurance_Type__c == 'Front') {
				// Front
				if (incomeDate < Date.parse('01/01/2010'))
					income.Novidea_HPC__Local_Tax__c = 16.5;
				else 
					income.Novidea_HPC__Local_Tax__c = 16;	
			} else {
				if (incomeDate < Date.parse('01/07/2009'))
					income.Novidea_HPC__Local_Tax__c = 7.75;
				else if (incomeDate < Date.parse('01/01/2010'))
					income.Novidea_HPC__Local_Tax__c = 8.25;
				else if (incomeDate < Date.parse('01/02/2012'))
					income.Novidea_HPC__Local_Tax__c = 8;
				else
					income.Novidea_HPC__Local_Tax__c = 16;
			}
		}
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
        system.schedule('Update incomes history ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year, CRON_EXP, new UpdateIncomeHistoryTax(200));
   */
}