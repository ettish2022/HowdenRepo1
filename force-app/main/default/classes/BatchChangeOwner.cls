global class BatchChangeOwner implements Database.Batchable<SObject> {

	global final String query;

	global BatchChangeOwner() { 
	 query = 'SELECT Novidea_HPC__Previous_Policy__r.OwnerId,'  
   			  + ' Novidea_HPC__Previous_Policy__c, ' 
			  + ' Novidea_HPC__Application__c, '
			  + ' Novidea_HPC__Application__r.OwnerId, ' 
			  +	' Novidea_HPC__Application__r.Novidea_HPC__Required_Policy_Type__c '
			  + ' FROM Novidea_HPC__Product__c '
			  + ' WHERE Novidea_HPC__Application__r.Novidea_HPC__Required_Policy_Type__c = \'Renew\''
			  + ' AND Novidea_HPC__Previous_Policy__c <> NULL AND Novidea_HPC__Previous_Policy__r.OwnerId!=\'005D0000001zdwL\'';
			  
	
	}

	global virtual Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	global virtual void execute(Database.BatchableContext BC,List<sObject> scope) {
		map<Id, Novidea_HPC__Application__c> appMap = new  map<Id, Novidea_HPC__Application__c>();
		for(sObject obj : scope) {
			Novidea_HPC__Product__c product = (Novidea_HPC__Product__c)obj;
			if( product.Novidea_HPC__Previous_Policy__r.OwnerId != product.Novidea_HPC__Application__r.OwnerId
			    && !appMap.containsKey(product.Novidea_HPC__Application__c)) {
					appMap.put(product.Novidea_HPC__Application__c, new Novidea_HPC__Application__c(
																		Id = product.Novidea_HPC__Application__c,
						    											OwnerId = product.Novidea_HPC__Previous_Policy__r.OwnerId));
			}
		}
		
		Database.update(appMap.values());
	}
	
	global virtual void finish(Database.BatchableContext BC) {
        
    }
    
}