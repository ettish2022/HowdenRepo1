@isTest(SeeAllData=false)
private with sharing class AcceptProductInListViewControllerTest {
	@testSetup
	private static void setupTestData() {
		Novidea_HPC__Product_Def__c productDef, productDef2;
		Account dataAccount, dataAccount2, dataAccountClient;
		Novidea_HPC__Application__c application;
		Novidea_HPC__Product__c product;
		Novidea_HPC__Product_Category__c category;
		Novidea_HPC__Broker_Number__c brokerNumber, brokerNumber2;

		Novidea_TMF__Time_Measurement_Settings__c tmfSettings = new Novidea_TMF__Time_Measurement_Settings__c(
			Novidea_TMF__Stop_AccountTrigger__c = true,
			Novidea_TMF__DefaultServiceTaskName__c = 'כללי',
			Novidea_TMF__limit_rows__c = '1000',
			Name = 'Default'
		);
		Database.insert(tmfSettings);

		Novidea_HPC__General_Switches__c gs = new Novidea_HPC__General_Switches__c(
			Name = 'Default',
			Novidea_HPC__Enable_Same_Product_Def__c = true,
			Novidea_HPC__Mark_NTU_On_Not_Converted_Proposals__c = true,
			Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c',
			Novidea_HPC__Copy_Application_Product_To_RFP_Product__c = true,
			Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c = false
		);
		Database.insert(gs);

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
		gs.Novidea_HPC__Disable_Management_Policy__c = true;
		Database.Update(gs);
		category = new Novidea_HPC__Product_Category__c(Name = 'test cat');
		Database.Insert(category);
		productDef = new Novidea_HPC__Product_Def__c(Name = 'Fire', Novidea_HPC__Category__c = category.Id);
		productDef2 = new Novidea_HPC__Product_Def__c(Name = 'Commercial');
		Database.insert(new List<Novidea_HPC__Product_Def__c>{ productDef, productDef2 });
		dataAccount = new Account(
			Name = 'carrier 1',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		dataAccount2 = new Account(
			Name = 'carrier 2',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		dataAccountClient = new Account(
			Name = 'client',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('household', 'Account')
		);

		Database.insert(new List<Account>{ dataAccount, dataAccount2, dataAccountClient });
		application = new Novidea_HPC__Application__c(Novidea_HPC__Account__c = dataAccountClient.Id, Name = 'App1');
		Database.insert(application);
		product = new Novidea_HPC__Product__c();
		product.Novidea_HPC__Application__c = application.Id;
		product.Novidea_HPC__Product_Definition__c = productDef.id;
		product.Novidea_HPC__Effective_Date__c = System.today();
		product.Novidea_HPC__Carrier__c = dataAccount2.id;
		Database.insert(product);

		brokerNumber = new Novidea_HPC__Broker_Number__c(Novidea_HPC__Carrier__c = dataAccount.Id, name = 'profit center1');
		brokerNumber2 = new Novidea_HPC__Broker_Number__c(Novidea_HPC__Carrier__c = dataAccount2.Id, name = 'profit center2');
		Database.Insert(new List<Novidea_HPC__Broker_Number__c>{ brokerNumber, brokerNumber2 });
		Novidea_HPC__Agreement__c agreement = new Novidea_HPC__Agreement__c(
			Novidea_HPC__Carrier__c = dataAccount.Id,
			Novidea_HPC__Carrier_Producer_del__c = brokerNumber.Id,
			name = 'test agreement'
		);
		Novidea_HPC__Agreement__c agreement2 = new Novidea_HPC__Agreement__c(
			Novidea_HPC__Carrier__c = dataAccount2.Id,
			Novidea_HPC__Carrier_Producer_del__c = brokerNumber2.Id,
			name = 'test agreement2'
		);
		Database.insert(new List<Novidea_HPC__Agreement__c>{ agreement, agreement2 });
		Database.insert(
			new List<Novidea_HPC__Commission_Rate__c>{
				new Novidea_HPC__Commission_Rate__c(
					Novidea_HPC__Agreement__c = agreement.Id,
					Novidea_HPC__Product_Definition__c = productDef.id,
					name = 'Fire'
				),
				new Novidea_HPC__Commission_Rate__c(
					Novidea_HPC__Agreement__c = agreement2.Id,
					Novidea_HPC__Product_Definition__c = productDef.id,
					name = 'Fire'
				),
				new Novidea_HPC__Commission_Rate__c(
					Novidea_HPC__Agreement__c = agreement2.Id,
					Novidea_HPC__Product_Definition__c = productDef2.id,
					name = 'Commercial'
				)
			}
		);
	}

	@IsTest
	private static void noProductTest() {
		List<Novidea_HPC__Product__c> selectedItems = new List<Novidea_HPC__Product__c>();

		PageReference pageRef = Page.AcceptProductInListView;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(selectedItems);
		AcceptProductInListViewController controller = new AcceptProductInListViewController(stdController);

		Test.startTest();
		controller.initRecent();
		Test.stopTest();
	}

	@IsTest
	static void invalidProductTest() {
		List<Novidea_HPC__Product__c> selectedItems = [
			SELECT id, Novidea_HPC__Application__r.Name
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Application__r.Name = 'App1'
		];
		selectedItems[0].Novidea_HPC__Status__c = ApplProductBuilderExtendCo.CANCELLED;
		Database.update(selectedItems[0]);
		PageReference pageRef = Page.AcceptProductInListView;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(selectedItems);
		AcceptProductInListViewController controller = new AcceptProductInListViewController(stdController);
		Test.startTest();
		controller.selectedProducts = selectedItems;
		controller.init();
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(
			String.format(
				Label.AcceptProductInListView_Error_Format,
				new List<String>{ selectedItems[0].Novidea_HPC__Application__r.Name, Label.Wrong_Product_Status }
			),
			ApexPages.getMessages()[0].getSummary()
		);
		Test.stopTest();
	}
	@IsTest
	private static void validProductTest() {
		List<Novidea_HPC__Product__c> selectedItems = [
			SELECT id, Novidea_HPC__Application__r.Name, Novidea_HPC__Status__c
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Application__r.Name = 'App1'
		];
		PageReference pageRef = Page.AcceptProductInListView;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(selectedItems);
		AcceptProductInListViewController controller = new AcceptProductInListViewController(stdController);
		Test.startTest();
		controller.selectedProducts = selectedItems;
		System.assertNotEquals(ApplProductBuilderExtendCo.ACCEPTED, selectedItems[0].Novidea_HPC__Status__c);
		controller.init();
		selectedItems = [
			SELECT id, Novidea_HPC__Application__r.Name, Novidea_HPC__Status__c
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Application__r.Name = 'App1'
		];
		System.assertEquals(ApplProductBuilderExtendCo.ACCEPTED, selectedItems[0].Novidea_HPC__Status__c);
		Test.stopTest();
	}
}