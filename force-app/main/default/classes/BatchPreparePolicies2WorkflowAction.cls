global class BatchPreparePolicies2WorkflowAction extends BatchRefresh {

	static final String QUERY_TMPL  = 'SELECT Id, Name FROM Novidea_HPC__Policy__c ' + 
	' WHERE Novidea_HPC__Expiration_Date__c <> NULL AND Novidea_HPC__Expiration_Date__c > {0} AND Novidea_HPC__Action__c = \'Expired\''; 

	global BatchPreparePolicies2WorkflowAction(Boolean isTest) {
		String sql = QUERY_TMPL.replace('{0}', StringUtils.date4Query(Date.today())); 
		if(isTest)
			sql += ' limit 200 ';
			
		this.query = sql;	
	}
	
	override protected void refresh(sObject obj) {
		obj.put('Novidea_HPC__Action__c','Active');
		if(Test.isRunningTest()) {
			Novidea_HPC__Policy__c policy = (Novidea_HPC__Policy__c)obj;
			policy.Name = policy.Name + ':up13';
		}
		
	}
	/*
	@isTest(SeeAllData=true)
	static void test001() {
   		Test.StartTest();
   		Account client = TestUtils.createAccount('client:001', true);
   		list<Novidea_HPC__Policy__c> pPolicies = new Novidea_HPC__Policy__c[] {
   													 TestUtils.createPolicy('policy:0A0', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0A1', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0A2', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0A3', null, client.Id, null, 'Active', false)
   													,TestUtils.createPolicy('policy:0A4', null, client.Id, null, 'Active', false)
   													
   													,TestUtils.createPolicy('policy:0E5', null, client.Id, null, 'Expired', false)
   													,TestUtils.createPolicy('policy:0E6', null, client.Id, null, 'Expired', false)
   													
   													,TestUtils.createPolicy('policy:0C7', null, client.Id, null, 'Cancelled', false)
   													,TestUtils.createPolicy('policy:0C8', null, client.Id, null, 'Cancelled', false)
   		};   
   		
   		for(Novidea_HPC__Policy__c po : pPolicies) {
   			po.Novidea_HPC__Expiration_Date__c = Date.today().addYears(1);  
   		}
   		pPolicies[3].Novidea_HPC__Expiration_Date__c = Date.today().addYears(-1);
   		pPolicies[4].Novidea_HPC__Expiration_Date__c = null;  
   		Database.insert(pPolicies);
   		
   		
   		BatchPreparePolicies2WorkflowAction batch = new BatchPreparePolicies2WorkflowAction(true);
		Database.executeBatch(batch);
   		Test.StopTest();
   		System.AssertEquals(3,
           database.countquery('SELECT COUNT() FROM Novidea_HPC__Policy__c WHERE Name like \'policy:0A%\' AND Name like \'%:up13\' '));  
	} */
}