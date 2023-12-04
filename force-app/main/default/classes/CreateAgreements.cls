global with sharing class CreateAgreements implements Schedulable, Database.Batchable<sObject>{
	public class CreateAgreementsException extends Exception {}
    private Integer numOfRecsInBatch = 1;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new CreateAgreements(), numOfRecsInBatch);
    }
   public CreateAgreements(){}
   public CreateAgreements(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch; }
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  return Database.getQueryLocator('Select Id From Account Where RecordType.DeveloperName = \'Carrier\'');
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		Map<String, Novidea_HPC__Agreement__c> agreemnets = new Map<String, Novidea_HPC__Agreement__c>();
		List<Novidea_HPC__Commission_Rate__c> commissionRates = new List<Novidea_HPC__Commission_Rate__c>();
		
		Set<Id> brokerNumbersIds = new Set<Id>();
		List<AggregateResult> policies = [Select Novidea_HPC__Carrier__c, Novidea_HPC__Product_Definition__c, 
				Novidea_HPC__Product_Definition__r.Name, Novidea_HPC__Broker_In_Carrier__c 
				From Novidea_HPC__Policy__c 
   	  			Where Novidea_HPC__Carrier__c = :((Account)scope[0]).Id and Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agreement__c = null
   	  			group by Novidea_HPC__Carrier__c, Novidea_HPC__Broker_In_Carrier__c, Novidea_HPC__Product_Definition__c, Novidea_HPC__Product_Definition__r.Name];
		
		Map<Id, String> productDefNames = new Map<Id, String>(); 
		for (AggregateResult policy:policies) {
			brokerNumbersIds.add((Id)policy.get('Novidea_HPC__Broker_In_Carrier__c'));
			productDefNames.put((Id)policy.get('Novidea_HPC__Product_Definition__c'), 
					(String)policy.get('Name'));
		}
		
		Map<Id, Novidea_HPC__Broker_Number__c> brokerNumberRecords = new Map<Id, Novidea_HPC__Broker_Number__c>([Select Id, Name, Novidea_HPC__Agreement__c 
				From Novidea_HPC__Broker_Number__c
				Where Id IN :brokerNumbersIds And Novidea_HPC__Agreement__c = null]);
		
		for (AggregateResult policy:policies) {
			agreemnets.put((String)policy.get('Novidea_HPC__Broker_In_Carrier__c'), 
					new Novidea_HPC__Agreement__c(Name='הסכם עמלות ' + brokerNumberRecords.get((Id)policy.get('Novidea_HPC__Broker_In_Carrier__c')).Name, 
							Novidea_HPC__Carrier__c=(Id)policy.get('Novidea_HPC__Carrier__c'),
							Novidea_HPC__Carrier_Producer_del__c=(Id)policy.get('Novidea_HPC__Broker_In_Carrier__c')));
		}
		Database.insert(agreemnets.values());
		for (AggregateResult policy:policies) {
			commissionRates.add(new Novidea_HPC__Commission_Rate__c(
					Name=productDefNames.get((Id)policy.get('Novidea_HPC__Product_Definition__c')),
					Novidea_HPC__Agreement__c=agreemnets.get((String)policy.get('Novidea_HPC__Broker_In_Carrier__c')).Id, 
					Novidea_HPC__Product_Definition__c=(Id)policy.get('Novidea_HPC__Product_Definition__c')));
		}
		
		Database.insert(commissionRates);
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
        system.schedule('Create agreements' + '(' + CRON_EXP + ')', CRON_EXP, new CreateAgreements(1));
   */
}