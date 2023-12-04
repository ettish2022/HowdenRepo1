public with sharing class MaintenanceCO {
    public Id jobId{get; private set;}
    public String selectedEntity{get;set;}
    public list<Selectoption> entOpts{get;private set;}
    
    //TODO: a problem to create custom settings dynamically
    //if Claim_Currency__c does not exist class will not be valid
    public void runCurrencyCoversion(){
        if(selectedEntity==null || selectedEntity.equals('') || selectedEntity.equalsIgnoreCase('none')) return;
        Sobject currencyCustomSettings; Schema.Describesobjectresult objDesc;
        if('Policy'.equalsIgnoreCase(selectedEntity)){
            currencyCustomSettings = Policy_Currency__c.getInstance();
            objDesc = Novidea_HPC__Policy__c.sObjectType.getDescribe();
        }
        else if('Claim'.equalsIgnoreCase(selectedEntity)){
            currencyCustomSettings = Claim_Currency__c.getInstance();
            objDesc = Novidea_HPC__Claim__c.sObjectType.getDescribe();
        }
        else if('Income'.equalsIgnoreCase(selectedEntity)){ 
            currencyCustomSettings = Income_Currency__c.getInstance();
            objDesc = Novidea_HPC__Income__c.sObjectType.getDescribe();
        }
        CurrencyHelper ch = new CurrencyHelper(currencyCustomSettings,objDesc);
        jobId = Database.executeBatch(ch, 20);
    }
    
    public void stopjob(){
        system.abortJob(jobId);
    }
    
    public void init(){
        entOpts = new list<Selectoption>();
        entOpts.add(new Selectoption('none','--ללא--'));
        entOpts.add(new Selectoption('Policy','פוליסה'));
        entOpts.add(new Selectoption('Claim','תביעה'));
        entOpts.add(new Selectoption('Income','הכנסה'));
    }
    
    @RemoteAction 
    public static JobStatusResult getJobStatus(String jobId){
        AsyncApexJob a = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedDate
                          FROM AsyncApexJob 
                          WHERE Id =: jobId];
        return new JobStatusResult(a.Status,a.NumberOfErrors,a.JobItemsProcessed,a.TotalJobItems, a.ExtendedStatus, a.CreatedDate);
    }
    
    public class JobStatusResult{
        public String status;
        public Integer numberOfErrors;
        public Integer jobItemsProcessed;
        public Integer totalJobItems;
        public String extendedStatus;
        public String createdDate;
        public String localResultFileId;
        public JobStatusResult(String status, Integer numberOfErrors, Integer jobItemsProcessed, Integer totalJobItems,String extendedStatus, Datetime createdDate){
            this.status = status;
            this.numberOfErrors = numberOfErrors;
            this.jobItemsProcessed = jobItemsProcessed;
            this.totalJobItems = totalJobItems;
            this.extendedStatus = extendedStatus;
            this.createdDate = createdDate.format('HH:mmm:ss');
        }
    }
    
    /*
    Script to add missing coins:
    List<List<Novidea_HPC__Exchange_Rate__c>> allNewExchaneRates = new List<List<Novidea_HPC__Exchange_Rate__c>>();
	for (AggregateResult wantedCurrency :[Select Novidea_HPC__Target_Currency__c From Novidea_HPC__Exchange_Rate__c Group By Novidea_HPC__Target_Currency__c]) {
		List<Novidea_HPC__Exchange_Rate__c > wantedCurrencies = 
		[
		select Novidea_HPC__Rate__c, Novidea_HPC__Rate_Date__c, Novidea_HPC__Source_Currency__c, Novidea_HPC__Target_Currency__c
		from Novidea_HPC__Exchange_Rate__c 
		where Novidea_HPC__Target_Currency__c = :(String)wantedCurrency.get('Novidea_HPC__Target_Currency__c')
		order by Novidea_HPC__Rate_Date__c
		];
	
		List<Novidea_HPC__Exchange_Rate__c> newExchaneRates = new List<Novidea_HPC__Exchange_Rate__c >();
		Date lastDate = wantedCurrencies[0].Novidea_HPC__Rate_Date__c;
		for (Novidea_HPC__Exchange_Rate__c curr:wantedCurrencies ) {
		System.debug(curr.Novidea_HPC__Rate_Date__c);
		System.debug(  lastDate.daysBetween(curr.Novidea_HPC__Rate_Date__c) );
		if (lastDate.daysBetween(curr.Novidea_HPC__Rate_Date__c) > 1)
			for (Integer daysBetween = 1; 
					daysBetween <  lastDate.daysBetween(curr.Novidea_HPC__Rate_Date__c) ;
					daysBetween++) {
				newExchaneRates.add(curr.clone(false,true,false,true));
				newExchaneRates[newExchaneRates.size() - 1].Novidea_HPC__Rate_Date__c = lastDate.addDays(daysBetween);
			}
		lastDate = curr.Novidea_HPC__Rate_Date__c;
		if (newExchaneRates.size() == 10000) break;
		}
	
		Database.insert(newExchaneRates);
		//allNewExchaneRates.add(newExchaneRates);
	}
	//for (List<Novidea_HPC__Exchange_Rate__c> newExchaneRates: allNewExchaneRates)
	//System.debug(newExchaneRates);
    */
}