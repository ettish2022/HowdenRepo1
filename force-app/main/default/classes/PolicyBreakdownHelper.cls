public with sharing class PolicyBreakdownHelper {
	
	public static Boolean stopTrigger = false;
	
	/**
	* The function go over all the policies related to the breakdowns and summarize the information in their breakdowns in a textual field in the policy
	* breakdowns = the list of breakdowns that were changed.
	**/
	public static void summaryBreakdowns(list<Novidea_HPC__Policy_Breakdown__c> breakdowns) {
		
		set<Id> policyIds = new Set<Id>();
		for(Novidea_HPC__Policy_Breakdown__c breakdown : breakdowns ) 
			policyIds.add(breakdown.Novidea_HPC__Policy__c);
			
        list<Novidea_HPC__Policy__c> policies = [SELECT Id, Policy_Breakdown__c,
         												(SELECT Novidea_HPC__Carrier__r.Name, 
         												        Novidea_HPC__Premium_Breakdown__c  
         												   FROM Novidea_HPC__Policy_Breakdowns__r) 
         										    FROM Novidea_HPC__Policy__c
         										   WHERE Id IN : policyIds];
         												 
        list<Novidea_HPC__Policy__c> policesToUpdate = new list<Novidea_HPC__Policy__c>();
        for(Novidea_HPC__Policy__c policy : policies) {
        	String text = '';
        	for(Novidea_HPC__Policy_Breakdown__c breakdown : policy.Novidea_HPC__Policy_Breakdowns__r) {
        		
        		if(breakdown.Novidea_HPC__Premium_Breakdown__c == null || breakdown.Novidea_HPC__Carrier__r == null)
					continue;
				String tmp = breakdown.Novidea_HPC__Carrier__r.Name + ' - ' + String.valueOf(breakdown.Novidea_HPC__Premium_Breakdown__c.setScale(2)) + '%';
				text += String.isEmpty(text) ? tmp : ', ' + tmp;
        	}
        	
        	if( policy.Policy_Breakdown__c != text) {
        		 policy.Policy_Breakdown__c = text;
        		 policesToUpdate.add(policy);
        	}
        }
        //raniz change 23/12/2012: canceled trigger also within package. Otherwise a confirm coverage process created 2 new renewal apps with 2 new prods.
        Novidea_HPC__Trigger__c pkgInst  = Novidea_HPC__Trigger__c.getInstance();
        Boolean st = PolicyTriggerHelper.stopTrigger, pkgSt = pkgInst.Novidea_HPC__Prevent_Policy_Running__c;
        PolicyTriggerHelper.stopTrigger = true;
        pkgInst.Novidea_HPC__Prevent_Policy_Running__c = true;
        Database.update(pkgInst);
        Database.update(policesToUpdate);
        PolicyTriggerHelper.stopTrigger = st;											 
        pkgInst.Novidea_HPC__Prevent_Policy_Running__c = false;
        Database.update(pkgInst);
	} 
	
/*	@isTest(SeeAllData=true)
	public static void test001() {
		final String ACTIVE = 'Active';
		list<sObject> pList = new list<sObject>();
		Account acc =  TestUtils.createAccount('test:1', true);
		Account carrier =  TestUtils.createAccount('test:2', true);
		Account carrier2 =  TestUtils.createAccount('test:3', true);
		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('test:01', null, null, null, ACTIVE, true);
		list<Novidea_HPC__Policy_Breakdown__c> brl = new sObject[] {
				 				 TestUtils.createBreakdown(policy.Id, 'test:001', carrier.Id, 50, false)
				 			     ,TestUtils.createBreakdown(policy.Id, 'test:002', carrier2.Id, 50, false)
							};
							
		Database.insert(brl);
		
		policy = [SELECT Id, Policy_Breakdown__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
		Decimal pr = 50;
		Decimal pr2 = 50;
		String textPart1 = 'test:2 - ' + String.valueOf(pr.setScale(2)) +'%';
		String textPart2 = 'test:3 - ' + String.valueOf(pr2.setScale(2)) +'%';
		system.assert(policy.Policy_Breakdown__c.contains(textPart1));
		system.assert(policy.Policy_Breakdown__c.contains(textPart2));
		
		Id id0 = brl[0].Id; 
		Id id1 = brl[1].Id; 
		brl = [SELECT Id, 
                      Novidea_HPC__Policy__c,
        			  Novidea_HPC__Premium_Breakdown__c,
        			  Novidea_HPC__Carrier__r.Name 
        		FROM Novidea_HPC__Policy_Breakdown__c 
        	   WHERE Id =: id0 OR Id =: id1 ];
        	   
       //-----------------------
       brl[0].Novidea_HPC__Premium_Breakdown__c = 30;
       brl[1].Novidea_HPC__Premium_Breakdown__c = 70;
       
       Database.update(brl);
       
       policy = [SELECT Id, Policy_Breakdown__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
	   pr = 30;
	   pr2 = 70;
	   //text = 'test:2 - ' + String.valueOf(pr.setScale(2)) +'%, test:3 - ' + String.valueOf(pr2.setScale(2)) +'%';
	   textPart1 = 'test:2 - ' + String.valueOf(pr.setScale(2)) +'%';
	   textPart2 = 'test:3 - ' + String.valueOf(pr2.setScale(2)) +'%';
	   system.assert(policy.Policy_Breakdown__c.contains(textPart1));
	   system.assert(policy.Policy_Breakdown__c.contains(textPart2));
	   
	   //-----------------------
	   brl[1].Novidea_HPC__Premium_Breakdown__c = 80;
       
       Database.update(brl);
       
       policy = [SELECT Id, Policy_Breakdown__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
	   pr2 = 80;
	   //text = 'test:2 - ' + String.valueOf(pr.setScale(2)) +'%, test:3 - ' + String.valueOf(pr2.setScale(2)) +'%';
	   textPart1 = 'test:2 - ' + String.valueOf(pr.setScale(2)) +'%';
	   textPart2 = 'test:3 - ' + String.valueOf(pr2.setScale(2)) +'%';
	   system.assert(policy.Policy_Breakdown__c.contains(textPart1));
	   system.assert(policy.Policy_Breakdown__c.contains(textPart2));
       
	}
*/
}