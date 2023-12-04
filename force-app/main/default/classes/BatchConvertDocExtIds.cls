global with sharing class BatchConvertDocExtIds implements Database.Batchable<sObject>, Database.Stateful {
    
    public BatchConvertDocExtIds(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext info)
    { 
        String query = 'SELECT ';
        for(integer i =1;i<=20;++i){
            query+= 'EntId' + i + '__c, ';
        }
        query = query.substring(0,query.length()-1)+'/n';
        query+= 'FROM InboundDocument__c\n';

        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, list<sObject> scope)
    {   
        updateDocs((list<InboundDocument__c>) scope);
    }
    
    
    global void finish(Database.BatchableContext info)
    {   
    }
    
    private void updateDocs(list<InboundDocument__c> docs){
        map<Id,InboundDocument__c> docsMap = new map<Id,inboundDocument__c>(docs);
        map<Id,map<String,String>> entIdsByDocId = new map<Id,map<String,String>>();
        String idVal;
        //the external Id==> the name of the field in which it was found
        map<String,String> tmpMap;
        for(inboundDocument__c doc: docs){
            if((tmpMap=entIdsByDocId.get(doc.Id))==null)
                tmpMap = new map<String,String>();
            for(Integer i =1;i<=20;++i){
                if((idVal=(String)doc.get('EntId' + i + '__c'))!=null)
                    //assumes a doc can't be mapped twice to the same ext Id
                    tmpMap.put(idVal, 'EntId' + i + '__c');
            }
            entIdsByDocId.put(doc.Id,tmpMap);
        }
        set<String> tmpSet = new set<String>();
        for(Id key :entIdsByDocId.keyset()){
            tmpSet.addall(entIdsByDocId.get(key).keyset());
        }
        
        list<Account> acts = [SELECT Id,External_Id__c FROM Account WHERE External_Id__c IN:tmpSet];
        list<Novidea_HPC__Claim__c> clms = [SELECT Id,External_Id__c FROM Novidea_HPC__Claim__c WHERE External_Id__c IN:tmpSet];
        map<String, Id> actsExtIds = new map<String, Id>();
        for(Account act: acts){
            actsExtIds.put(act.External_Id__c,act.Id);
        }
        map<String, Id> clmsExtIds = new map<String, Id>();
        for(Novidea_HPC__Claim__c clm: clms){
            clmsExtIds.put(clm.External_Id__c,clm.Id);
        }
        for(Id key :entIdsByDocId.keyset()){
            tmpMap = entIdsByDocId.get(key);
            for(String extId: tmpMap.keyset()){
                if((idVal=actsExtIds.get(extId))!=null)docsMap.get(key).put(entIdsByDocId.get(key).get(extId),idVal);
                if((idVal=clmsExtIds.get(extId))!=null)docsMap.get(key).put(entIdsByDocId.get(key).get(extId),idVal);
            }
        }
        database.update(docsMap.values());
        
    }
}