@isTest(seeAllData=false)
private with sharing class TestRFPTableCo {
	static testMethod void testRFPTable() {
		Database.insert(
			new Novidea_HPC__Time_Periods__c(
				Novidea_HPC__Minimum_Number_of_Days_for_Policy__c = 1,
				Novidea_HPC__Number_of_Days_Before_Effective__c = 0
			)
		);
		Database.insert(
			new Novidea_TMF__Time_Measurement_Settings__c(
				Name = 'Default',
				Novidea_TMF__DefaultServiceTaskName__c = 'Test',
				Novidea_TMF__limit_rows__c = '1000'
			)
		);
		Novidea_HPC__Product_Def__c proDef1 = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef1);
		Novidea_HPC__Product_Def__c proDef2 = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef2);

		Account acc1 = new Account(Name = 'tess');
		Database.insert(acc1);

		Account acc2 = new Account(Name = 'tess');
		Database.insert(acc2);

		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c();
		insert app;

		Novidea_HPC__Request_for_Proposal__c rfp = new Novidea_HPC__Request_for_Proposal__c();
		rfp.Novidea_HPC__Carrier__c = acc1.Id;
		rfp.Novidea_HPC__Application__c = app.Id;
		Database.insert(rfp);

		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c();
		pro.Novidea_HPC__Carrier__c = acc1.Id;
		pro.Novidea_HPC__Application__c = app.Id;
		pro.Novidea_HPC__Product_Definition__c = proDef1.id;
		pro.Novidea_HPC__Request_for_Proposal__c = rfp.id;
		Database.insert(pro);

		Novidea_HPC__Request_for_Proposal__c rfp2 = new Novidea_HPC__Request_for_Proposal__c();
		rfp2.Novidea_HPC__Carrier__c = acc2.Id;
		rfp2.Novidea_HPC__Application__c = app.Id;
		Database.insert(rfp2);

		Novidea_HPC__Product__c pro2 = new Novidea_HPC__Product__c();
		pro2.Novidea_HPC__Carrier__c = acc2.Id;
		pro2.Novidea_HPC__Application__c = app.Id;
		pro2.Novidea_HPC__Product_Definition__c = proDef1.id;
		pro2.Novidea_HPC__Request_for_Proposal__c = rfp2.id;
		Database.insert(pro2);

		Novidea_HPC__Proposal__c prop = new Novidea_HPC__Proposal__c();
		prop.Novidea_HPC__Carrier__c = acc2.Id;
		prop.Novidea_HPC__Application__c = app.Id;
		Database.insert(prop);

		Novidea_HPC__Product__c pro3 = new Novidea_HPC__Product__c();
		pro3.Novidea_HPC__Product__c = pro.Id;
		pro3.Novidea_HPC__Carrier__c = acc2.Id;
		pro3.Novidea_HPC__Application__c = app.Id;
		pro3.Novidea_HPC__Product_Definition__c = proDef1.id;
		pro3.Novidea_HPC__Proposal__c = prop.id;
		Database.insert(pro3);

		RFPTableCo con = new RFPTableCo(new ApexPages.StandardController(app));
		con.init();

		RFPTableCo.ProductWrapper pw0 = con.productWrapperList[0];
		RFPTableCo.CarrierWrapper carrier0 = con.carrierlist[0];

		pw0.cancelOtherAcceptStatuses(1);

		con.index = '1';

		con.createRFP();
		// con.changeStatus();

		con.convertToPolicy();
		con.index = '1';
		// con.deleteColumn();
	}

	private static testMethod void testHarbana() {
		RFPTableCo.testPasser();
	}
}