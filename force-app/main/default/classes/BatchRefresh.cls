global virtual class BatchRefresh implements Database.Batchable<SObject> {

	global final String query;

	global BatchRefresh() { }
	
   	global BatchRefresh( String q ){
      query=q; 
   	}

	global virtual Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	global virtual void execute(Database.BatchableContext BC,List<sObject> scope) {
		for(sObject obj : scope) 
			refresh(obj);
			
		Database.update(scope);
	}
	
	global virtual void finish(Database.BatchableContext BC) {
        
    }
    
    protected virtual  void refresh(sObject obj) {
    	
    }
    /*
    	BatchCreateSumByCarrier4Income be = new BatchCreateSumByCarrier4Income();
		ID batchprocessid = Database.executeBatch(be);
    */
}