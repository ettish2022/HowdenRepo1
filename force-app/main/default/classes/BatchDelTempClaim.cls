global class BatchDelTempClaim implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts
{
    String query;
    String result;
     
    global BatchDelTempClaim()
    {
        query='select id from Novidea_HPC__Claim__c where Is_Temp__c = true';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        try{
            Database.delete(scope);
        }catch(exception e){}
        
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        
    }        
}