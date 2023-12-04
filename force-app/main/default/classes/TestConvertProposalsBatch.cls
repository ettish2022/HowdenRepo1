@isTest(seeAllData=false)
private with sharing class TestConvertProposalsBatch {
	@isTest
	private static void testAsyncConversion() {
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c(name = 'def1');
		Database.insert(proDef);

		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c(name = 'app1');
		Database.insert(app);

		List<Id> proposalIds = new List<Id>();
		List<Novidea_HPC__Proposal__c> proposals = new List<Novidea_HPC__Proposal__c>();
		Novidea_HPC__Proposal__c proposal1 = new Novidea_HPC__Proposal__c(name = 'prop1');
		proposal1.Novidea_HPC__Application__c = app.Id;
		proposals.add(proposal1);
		Database.insert(proposals);

		for (Novidea_HPC__Proposal__c proposal : proposals)
			proposalIds.add(proposal.Id);

		CurrencyTriggerHelper.stopTrigger = true;
		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c(Name = '' + app.Id + proDef.Id + proposal1.Id);
		pro.Novidea_HPC__Product_Definition__c = proDef.Id;
		pro.Novidea_HPC__Proposal__c = proposal1.Id;
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Discount__c = 1;
		pro.Novidea_HPC__Effective_Date__c = date.today();
		pro.Novidea_HPC__Expiration_Date__c = date.today();
		pro.Novidea_HPC__Fee_Amount__c = 1;
		pro.Novidea_HPC__Fee_Currency__c = 'ILS';
		pro.Novidea_HPC__Premium__c = 1;
		pro.Novidea_HPC__Premium_Currency__c = 'ILS';
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Status__c = 'Accepted';
		Database.insert(pro);

		PageReference pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
			[SELECT Id FROM Novidea_HPC__Proposal__c WHERE Id IN :proposalIds]
		);

		controller.setSelected(proposals);
		ApprovedProposalsController con = new ApprovedProposalsController(controller);
		con.advancedModeVal = true;
		con.asyncModeVal = true;

		Test.startTest();
		con.convertToPolicy();
		Test.stopTest();

		List<Novidea_HPC__Product__c> resultProducts = [
			SELECT Name, Novidea_HPC__Status__c, Novidea_HPC__Proposal__r.Novidea_HPC__Status__c
			FROM Novidea_HPC__Product__c
			WHERE Id = :pro.Id
		];

		System.AssertEquals(ConvertProposalsHelper.CONVERTED, resultProducts[0].Novidea_HPC__Status__c);
		System.AssertEquals(ConvertProposalsHelper.COVERAGE_CONFIRMATION, resultProducts[0].Novidea_HPC__Proposal__r.Novidea_HPC__Status__c);
	}
}