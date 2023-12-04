global class BatchRetrospektivChangePolicies2Expired extends BatchRefresh{

	static final String QUERY_TMPL  = 'SELECT Id, Novidea_HPC__Action__c, Name '+
			' FROM Novidea_HPC__Policy__c '+
			' WHERE Novidea_HPC__Expiration_Date__c <> NULL AND Novidea_HPC__Expiration_Date__c < {0} AND Novidea_HPC__Action__c = \'Active\''; 

	public BatchRetrospektivChangePolicies2Expired(Boolean isTest) {
		String sql = QUERY_TMPL.replace('{0}', StringUtils.date4Query(Date.today()));
		if(isTest)
			sql += ' limit 1000 ';
		
		this.query = sql;
	}
	
	protected override  void refresh(sObject obj) {
		Novidea_HPC__Policy__c policy = (Novidea_HPC__Policy__c)obj;
		policy.Novidea_HPC__Action__c = 'Expired';
		if(Test.isRunningTest())
			policy.Name = policy.Name + ':ref613';
	}
	/*
	@isTest(SeeAllData=true) 
	static void test001() {
   		Test.StartTest();
   		Account client = TestUtils.createAccount('client:001', true);
   		list<Novidea_HPC__Policy__c> pPolicies = new Novidea_HPC__Policy__c[] {
   													 TestUtils.createPolicy('policy:0D0', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0D1', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0D2', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0D3', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0D4', null, client.Id, null, 'Active', false)
   													
   													,TestUtils.createPolicy('policy:0E5', null, client.Id, null, 'Expired', false)
   													,TestUtils.createPolicy('policy:0E6', null, client.Id, null, 'Expired', false)
   													
   													,TestUtils.createPolicy('policy:0C7', null, client.Id, null, 'Cancelled', false)
   													,TestUtils.createPolicy('policy:0C8', null, client.Id, null, 'Cancelled', false)
   		};   
   		
   		for(Novidea_HPC__Policy__c po : pPolicies) {
   			po.Novidea_HPC__Expiration_Date__c = Date.newInstance(2012, 1, 1);  
   		}
   		
   		pPolicies[3].Novidea_HPC__Expiration_Date__c = Date.newInstance(2012, 1, 1); //Date.today().addYears(-1);
   		pPolicies[4].Novidea_HPC__Expiration_Date__c = null;  
   		Database.insert(pPolicies);
   		
   		Set<Id> poIds = new Set<Id>();
   		for(Novidea_HPC__Policy__c po : pPolicies) 
   			poIds.add(po.Id);
   		
   		pPolicies = [select Id, Novidea_HPC__Expiration_Date__c, Novidea_HPC__Action__c from Novidea_HPC__Policy__c where Id IN :poIds ];
   		String dump = '';
   		for(Novidea_HPC__Policy__c po : pPolicies) {
   			dump += po.Novidea_HPC__Expiration_Date__c + ' <--> ' +  po.Novidea_HPC__Action__c + '\n';
   		}
   		system.debug('\n\n\n\n list dump ' + dump + '\n\n\n\n');
   		
   		BatchPreparePolicies2WorkflowAction batch = new BatchPreparePolicies2WorkflowAction(true);
		Database.executeBatch(batch);
   		Test.StopTest();
        String sql = 'SELECT count() FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Expiration_Date__c <> NULL AND Novidea_HPC__Expiration_Date__c < {0} AND Novidea_HPC__Action__c = \'Active\'';
        sql = sql.replace('{0}', StringUtils.date4Query(Date.today()));
   		system.debug('\n\n\n\nquery count >>> ' + database.countQuery(sql) + '\n\n\n\n');
   		System.AssertEquals(1,
   			database.countquery('SELECT COUNT() FROM Novidea_HPC__Policy__c WHERE Name like \'%:ref613\' ')); 
           //database.countquery('SELECT COUNT() FROM Novidea_HPC__Policy__c WHERE Name like \'policy:0D%\' AND Name like \'%:ref613\' '));  
	} */ 
}