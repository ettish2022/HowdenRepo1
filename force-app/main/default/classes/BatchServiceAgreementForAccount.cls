global with sharing class BatchServiceAgreementForAccount implements Schedulable, Database.Batchable<sObject>{
    static final Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Novidea_TMF__Service_Agreement__c.getRecordTypeInfosByName();
    private Integer numOfRecsInBatch = 50;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new BatchServiceAgreementForAccount(), 200);
    }
    public BatchServiceAgreementForAccount(){}
    public BatchServiceAgreementForAccount(
            Integer numOfRecsInBatch){
        this.numOfRecsInBatch = numOfRecsInBatch;
        }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, (Select Id From Novidea_TMF__Service_Agreements__r) From Account';
        return Database.getQueryLocator(query); 
   }
    

    global void execute(Database.BatchableContext BC, list<sObject> scope){
        if(scope.isEmpty())return;
        Novidea_TMF__Service_Agreement__c agreement;
        list<Novidea_TMF__Service_Agreement__c> agreements = 
                new list<Novidea_TMF__Service_Agreement__c>();
        for (Account acc: (list<Account>)scope){
            if (acc.Novidea_TMF__Service_Agreements__r.size()==0) {
                agreement = new Novidea_TMF__Service_Agreement__c();
                agreement.Novidea_TMF__Client__c = acc.Id;
                agreement.Name = 'לא לחיוב';
                agreement.Novidea_TMF__Agreement_Date__c = date.today();
                agreement.Novidea_TMF__Expiration_Date__c = date.newInstance(2100, 1, 30);
                agreement.Novidea_TMF__FEE_Charging_Ammount__c = 0;
                agreement.Novidea_TMF__FEE_Charging_Method__c = 'לא מוגדר';
                agreements.add(agreement);
            }
        }
        
        
        Database.insert(agreements);
    }
    global void finish(Database.BatchableContext BC){
   }
	
}