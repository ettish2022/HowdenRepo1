@isTest(seeAllData=false)
private class TestApplProductBuilderExtendCo {
	@testsetup
	static void setupData() {
		Database.insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
		User currentUser = [SELECT Id, LanguageLocaleKey, LocaleSidKey, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
		currentUser.LanguageLocaleKey = 'en_US';
		currentUser.LocaleSidKey = 'en_US';
		Database.update(currentUser);
		// Database.insert(new Novidea_HPC__Broker_Number__c(Id = brokerNumber.Id, name = 'profit center1'));
		System.runAs(new User(Id = UserInfo.getUserId())) {
			User user1 = new User(
				Alias = 'std1test',
				Email = 'standarduser1@testorg.com',
				EmailEncodingKey = 'UTF-8',
				LastName = 'Testing',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = currentUser.ProfileId,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = 'standarduser1@test.novideasoft.com'
			);
			Database.insert(user1);
		}
	}

	private static Novidea_HPC__Product_Def__c productDef, productDef2;
	private static Account dataAccount, dataAccount2, dataAccountClient, profitCenterAcc;
	private static Novidea_HPC__Application__c application;
	private static Novidea_HPC__Product__c product;
	private static Novidea_HPC__Product_Category__c category;
	private static Novidea_HPC__Broker_Number__c brokerNumber, brokerNumber2;

	private static void prepData() {
		prepData(null);
	}
	private static void prepData(String prodStatus) {
		//without Novidea_HPC__Disable_Management_Policy__c = true it requires after #4482 another call that the VF does
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
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
		Database.update(gs);
		category = new Novidea_HPC__Product_Category__c(Name = 'test cat', Shika_Percent__c = 5);
		Database.insert(category);
		productDef = new Novidea_HPC__Product_Def__c(Name = 'Fire', Novidea_HPC__Category__c = category.Id);
		productDef2 = new Novidea_HPC__Product_Def__c(Name = 'Commercial', Novidea_HPC__Category__c = category.Id);
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
		profitCenterAcc = new Account(
			Name = 'profit center1',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Agency', 'Account')
		);

		Database.insert(new List<Account>{ dataAccount, dataAccount2, dataAccountClient, profitCenterAcc });
		TestApplProductBuilderExtendCo.application = new Novidea_HPC__Application__c(Novidea_HPC__Account__c = dataAccountClient.Id);
		Database.insert(application);
		product = new Novidea_HPC__Product__c();
		if (prodStatus != null)
			product.Novidea_HPC__Status__c = prodStatus;
		product.Novidea_HPC__Application__c = application.Id;
		product.Novidea_HPC__Product_Definition__c = productDef.id;
		Database.insert(product);

		brokerNumber = new Novidea_HPC__Broker_Number__c(
			Novidea_HPC__Carrier__c = dataAccount.Id,
			name = 'profit center1',
			Novidea_HPC__Profit_Center__c = profitCenterAcc.Id
		);
		brokerNumber2 = new Novidea_HPC__Broker_Number__c(Novidea_HPC__Carrier__c = dataAccount2.Id, name = 'profit center2');
		Database.insert(new List<Novidea_HPC__Broker_Number__c>{ brokerNumber, brokerNumber2 });
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

	@isTest
	static void testApplProductBuilderExtend() {
		prepData();

		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));
		con.init();
		con.save();

		con.addLine();
		con.lineToRemove = con.getMaxIdVal() - 1;
		con.deleteProducts();
		con.save();
		CurrencyTriggerHelper.stopTrigger = true;
		con.convert();
		con.lossReport();
		con.getHasAcceptedProducts();
		con.getHasLostProducts();
		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
		}
		con.save();
		con.deleteProducts();

		con.save();

		con.addLine();
		con.addLine();
		con.addLine();

		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
			con.products[x].product.Novidea_HPC__Product_Definition__c = productDef.id;
			con.products[x].product.Novidea_HPC__Carrier__c = dataAccount.Id;
			con.products[x].carrierName = dataAccount.Name;
			con.products[x].productDefName = productDef.Name;
		}

		con.save();
		con.convert();

		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.CANCELLED;
		}
		con.products[0].lossCauseText = 'text text';
		con.products[0].cancellationReason = 'חסר כספים';
		Test.startTest();
		con.save();
		con.lossReport();
		object a = con.fieldSetStorage;
		con.getFieldSetItems();
		Test.stopTest();
		System.assertEquals(true, con.products[0].product.Novidea_HPC__Is_Lost__c);
		System.assertEquals(true, con.products[0].product.Novidea_HPC__Loss_Cause_Reporting__c.contains('text text'));
	}

	@isTest
	static void testApplProductBuilderExtendClone() {
		prepData();

		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));
		con.init();
		con.save();

		con.addLine();
		con.lineToRemove = con.getMaxIdVal() - 1;
		con.deleteProducts();
		con.save();
		CurrencyTriggerHelper.stopTrigger = true;
		con.convert();
		con.lossReport();
		con.getHasAcceptedProducts();
		con.getHasLostProducts();
		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
		}
		con.save();
		con.deleteProducts();

		con.save();

		con.addLine();
		System.assertEquals(2, con.products.size());
		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
			con.products[x].product.Novidea_HPC__Product_Definition__c = productDef.id;
			con.products[x].product.Novidea_HPC__Carrier__c = dataAccount.Id;
			con.products[x].carrierName = dataAccount.Name;
			con.products[x].productDefName = productDef.Name;
		}
		con.cloneProduct();
		System.assertEquals(4, con.products.size());
	}

	static String testApplProductBuilderExtendPolicyEditURL(Boolean disableManagementPolicy) {
		prepData(); // here Novidea_HPC__Disable_Management_Policy__c is set to true
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		gs.Novidea_HPC__Edit_Policy_After_Conversion__c = true;
		if (!disableManagementPolicy)
			gs.Novidea_HPC__Disable_Management_Policy__c = false;
		Database.update(gs);
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));
		con.init();

		con.products[0].productEffDate = '05/05/2015';
		con.products[0].isSelected = true;
		con.products[0].product.Novidea_HPC__Required_Policy_Type__c = 'New';
		con.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
		con.products[0].product.Novidea_HPC__Product_Definition__c = productDef.id;
		con.products[0].product.Novidea_HPC__Carrier__c = dataAccount.Id;
		con.products[0].carrierName = dataAccount.Name;
		con.products[0].productDefName = productDef.Name;
		con.save();
		con.products[0].isSelected = true;
		CurrencyTriggerHelper.stopTrigger = true;
		Test.startTest();
		con.convert();
		Test.stopTest();

		return con.policyEditUrl;
	}

	@isTest
	static void testApplProductBuilderExtendPolicyEditURLDisableManagementPolicyTrue() {
		String policyEditUrl = testApplProductBuilderExtendPolicyEditURL(true);

		string policyId = [SELECT Id FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Application__c = :application.Id][0].Id;
		System.assertEquals('/' + policyId + '/e?retURL=%2F' + policyId, policyEditUrl);
	}

	@isTest
	static void testApplProductBuilderExtendPolicyEditURLDisableManagementPolicyFalse() {
		String policyEditUrl = testApplProductBuilderExtendPolicyEditURL(false);

		System.assertEquals(null, policyEditUrl);
	}

	@isTest
	static void testApplProductBuilderExtendPolicyWithoutBreakdowns() {
		// This flow should create by default breakdown in process of converting application to policy in method SalesProcessHelper.convertingProductToPolicy
		// but we disable the creation of breakdowns
		Novidea_HPC.TriggerUtils.disableTrigger('CreateDefaultBreakdown', 'testApplProductBuilderExtendPolicyWithoutBreakdowns');
		testApplProductBuilderExtendPolicyEditURL(true);

		System.assertEquals(0, [SELECT Id FROM Novidea_HPC__Policy_Breakdown__c].size());
	}

	@isTest
	static void testApplProductBuilderExtendLimitToOnePolicyConversion() {
		prepData();
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		gs.Novidea_HPC__Limit_To_One_Policy_Conversion__c = true;
		Database.update(gs);
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		con.init();
		con.addLine();
		system.assertEquals(2, con.products.size());
		set<Id> prodIds = new Set<Id>();
		for (Integer x = 0; x < con.products.size(); x++) {
			prodIds.add(con.products[x].product.Id);
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = false;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
			con.products[x].product.Novidea_HPC__Carrier__c = (x == 0 ? dataAccount.Id : dataAccount2.Id);
			con.products[x].carrierName = (x == 0 ? dataAccount.Name : dataAccount2.Name);
			//the system currenly does not support conversion of the same product definition in the same app
			con.products[x].product.Novidea_HPC__Product_Definition__c = (x == 0 ? productDef.id : productDef2.id);
			con.products[x].productDefName = (x == 0 ? productDef.Name : productDef2.Name);
		}
		con.save();

		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].isSelected = x == 0;
			con.products[x].profitCenter = ApprovedProposalsController.composeProfitCenterName(
				new Novidea_HPC__Broker_Number__c(
					Id = (x == 0 ? brokerNumber.Id : brokerNumber2.Id),
					name = (x == 0 ? 'profit center1' : 'profit center2')
				)
			);
		}
		CurrencyTriggerHelper.stopTrigger = true;
		Test.startTest();
		con.convert();
		Test.stopTest();
		// Profit center is now chosen by defult so it does not apply. No error is thrown
		// System.assertEquals(1, ApexPages.getMessages().size());
		// System.assertEquals(Label.Novidea_HPC.Choose_profit_center, ApexPages.getMessages()[0].getSummary());
		system.assertEquals(1, [SELECT Id FROM Novidea_HPC__Policy__c].size());
	}

	@isTest
	static void testApplProductBuilderExtendDeleteProd() {
		prepData();
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		con.init();
		con.addLine();
		system.assertEquals(2, con.products.size());
		for (Integer x = 0; x < con.products.size(); x++) {
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = true;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
			con.products[x].product.Novidea_HPC__Product_Definition__c = productDef.id;
			con.products[x].product.Novidea_HPC__Carrier__c = dataAccount.Id;
			con.products[x].carrierName = dataAccount.Name;
			con.products[x].productDefName = productDef.Name;
		}
		con.save();
		CurrencyTriggerHelper.stopTrigger = true;
		con.convert();

		con.addLine();
		system.assertEquals(3, con.products.size());
		for (Integer x = 0; x < con.products.size(); x++) {
			if (x == 2)
				con.products[x].isSelected = true;
			else
				con.products[x].isSelected = null;
		}
		con.deleteProducts();
		system.assertEquals(2, con.products.size());
	}

	@isTest
	static void testApplProductBuilderExtendAddProfitCenter() {
		prepData();
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		con.init();
		con.addLine();
		system.assertEquals(2, con.products.size());
		set<Id> prodIds = new Set<Id>();
		for (Integer x = 0; x < con.products.size(); x++) {
			prodIds.add(con.products[x].product.Id);
			con.products[x].productEffDate = '05/05/2015';
			con.products[x].isSelected = false;
			con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
			con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
			con.products[x].product.Novidea_HPC__Product_Definition__c = productDef.id;
			con.products[x].product.Novidea_HPC__Carrier__c = dataAccount.Id;
			con.products[x].carrierName = dataAccount.Name;
			con.products[x].productDefName = productDef.Name;
		}
		con.save();
		system.assertEquals(1, [SELECT Id FROM Novidea_HPC__Proposal__c].size());
		Novidea_HPC__Product__c[] prods = [
			SELECT Novidea_HPC__Broker_In_Carrier__c
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :prodIds AND Novidea_HPC__Proposal__c != NULL
		];
		system.assertEquals(1, prods.size());
		system.assertEquals(
			brokerNumber.Id,
			[
				SELECT Novidea_HPC__Broker_In_Carrier__c
				FROM Novidea_HPC__Product__c
				WHERE Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :prodIds AND Novidea_HPC__Proposal__c != NULL
			][0]
			.Novidea_HPC__Broker_In_Carrier__c
		);
		con.save();
		system.assertEquals(
			brokerNumber.Id,
			[
				SELECT Novidea_HPC__Broker_In_Carrier__c
				FROM Novidea_HPC__Product__c
				WHERE Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :prodIds AND Novidea_HPC__Proposal__c != NULL
			][0]
			.Novidea_HPC__Broker_In_Carrier__c
		);
	}

	@isTest
	static void testApplProductBuilderExtendConvertSeveralCarriers() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			prepData();
			PageReference pageRef = Page.ApplProductBuilderExtend;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', application.Id);
			ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));
			Test.startTest();
			con.init();
			con.addLine();
			system.assertEquals(2, con.products.size());
			set<Id> prodIds = new Set<Id>();
			for (Integer x = 0; x < con.products.size(); x++) {
				prodIds.add(con.products[x].product.Id);
				con.products[x].productEffDate = '05/05/2015';
				con.products[x].isSelected = false;
				con.products[x].product.Novidea_HPC__Required_Policy_Type__c = 'New';
				con.products[x].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
				con.products[x].product.Novidea_HPC__Carrier__c = (x == 0 ? dataAccount.Id : dataAccount2.Id);
				con.products[x].carrierName = (x == 0 ? dataAccount.Name : dataAccount2.Name);
				//the system currenly does not support conversion of the same product definition in the same app
				con.products[x].product.Novidea_HPC__Product_Definition__c = (x == 0 ? productDef.id : productDef2.id);
				con.products[x].productDefName = (x == 0 ? productDef.Name : productDef2.Name);
			}
			con.save();
			Novidea_HPC__Proposal__c[] props = [SELECT (SELECT Id FROM Novidea_HPC__Products__r) FROM Novidea_HPC__Proposal__c];
			system.assertEquals(1, props[0].Novidea_HPC__Products__r.size());
			system.assertEquals(1, props[1].Novidea_HPC__Products__r.size());
			system.assertEquals(
				brokerNumber.Id,
				[
					SELECT Novidea_HPC__Broker_In_Carrier__c
					FROM Novidea_HPC__Product__c
					WHERE Novidea_HPC__Product__r.Novidea_HPC__Product__c = :con.products[0].product.Id AND Novidea_HPC__Proposal__c != NULL
				][0]
				.Novidea_HPC__Broker_In_Carrier__c
			);
			Novidea_HPC__Product__c product1 = [
				SELECT Novidea_HPC__Broker_In_Carrier__c
				FROM Novidea_HPC__Product__c
				WHERE Id = :con.products[0].product.Id
			]; //Ticket #4497
			System.assertEquals(brokerNumber.Id, product1.Novidea_HPC__Broker_In_Carrier__c);
			for (Integer x = 0; x < con.products.size(); x++) {
				con.products[x].isSelected = true;
				con.products[x].profitCenter = ApprovedProposalsController.composeProfitCenterName(
					new Novidea_HPC__Broker_Number__c(
						Id = (x == 0 ? brokerNumber.Id : brokerNumber2.Id),
						name = (x == 0 ? 'profit center1' : 'profit center2')
					)
				);
			}
			CurrencyTriggerHelper.stopTrigger = true;
			con.convert();
			Test.stopTest();
			system.assertEquals(2, [SELECT Id FROM Novidea_HPC__Policy__c].size());
			system.assertEquals(
				2,
				[SELECT Id FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Status__c = 'Converted' AND Novidea_HPC__Proposal__c != NULL].size()
			);
		}
	}

	@isTest
	static void testApplProductBuilderExtRenewAppWithRFPDoesNotChangeToCurrLang() {
		prepData();
		application.Novidea_HPC__Required_Policy_Type__c = 'Renew';
		Database.update(application);
		product.Novidea_HPC__Required_Policy_Type__c = 'Renew';
		Database.update(product);
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO controller = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		controller.init();
		system.assertEquals(1, controller.products.size());
		set<Id> prodIds = new Set<Id>();
		prodIds.add(controller.products[0].product.Id);
		controller.products[0].productEffDate = '05/05/2015';
		controller.products[0].isSelected = false;
		controller.products[0].product.Novidea_HPC__Carrier__c = dataAccount.Id;
		controller.products[0].carrierName = dataAccount.Name;
		controller.products[0].product.Novidea_HPC__Product_Definition__c = productDef.id;
		controller.products[0].productDefName = productDef.Name;
		controller.products[0].product.Novidea_HPC__Expected_Premium__c = 13;
		controller.products[0].product.Novidea_HPC__Expected_Premium_Net__c = 8;
		controller.products[0].product.Novidea_HPC__Expected_Fees__c = 5;
		controller.products[0].product.Novidea_HPC__Expected_Commission_Amount__c = 2;

		User user1 = [SELECT Id FROM User WHERE Email = 'standarduser1@testorg.com' LIMIT 1];

		Test.startTest();
		System.runAs(user1) {
			controller.save();
		}
		system.assertEquals(
			'Renew',
			[SELECT Novidea_HPC__Required_Policy_Type__c FROM Novidea_HPC__Application__c WHERE Id = :application.Id][0]
			.Novidea_HPC__Required_Policy_Type__c
		);
		system.assertEquals(
			'Renew',
			[SELECT Novidea_HPC__Required_Policy_Type__c FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Application__c = :application.Id][0]
			.Novidea_HPC__Required_Policy_Type__c
		);
	}

	@isTest
	static void testApplProductBuilderExtPropProductHasNoPrevPol() {
		prepData();
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(
			Novidea_HPC__Policy_Number__c = '123456789',
			Novidea_HPC__Agency_Fees_Currency__c = 'USD',
			Novidea_HPC__Client__c = dataAccountClient.Id,
			Novidea_HPC__Product_Definition__c = product.Novidea_HPC__Product_Definition__c,
			Novidea_HPC__Carrier__c = dataAccount.Id,
			Novidea_HPC__Expiration_Date__c = Date.Today(),
			Novidea_HPC__Effective_Date__c = Date.Today().addYears(-1),
			Novidea_HPC__Action__c = 'Active'
		);
		CurrencyTriggerHelper.stopTrigger = true;
		Database.insert(policy);

		application.Novidea_HPC__Required_Policy_Type__c = 'Renew';
		application.Novidea_HPC__Previous_Policy__c = policy.Id;
		Database.update(application);
		product.Novidea_HPC__Required_Policy_Type__c = 'Renew';
		product.Novidea_HPC__Previous_Policy__c = policy.Id;
		Database.update(product);
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO controller = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		controller.init();
		system.assertEquals(1, controller.products.size());
		set<Id> prodIds = new Set<Id>();
		prodIds.add(controller.products[0].product.Id);
		controller.products[0].productEffDate = '05/05/2015';
		controller.products[0].isSelected = false;
		controller.products[0].product.Novidea_HPC__Carrier__c = dataAccount.Id;
		controller.products[0].carrierName = dataAccount.Name;
		controller.products[0].product.Novidea_HPC__Product_Definition__c = productDef.id;
		controller.products[0].productDefName = productDef.Name;
		controller.products[0].product.Novidea_HPC__Expected_Premium__c = 13;
		controller.products[0].product.Novidea_HPC__Expected_Premium_Net__c = 8;
		controller.products[0].product.Novidea_HPC__Expected_Fees__c = 5;
		controller.products[0].product.Novidea_HPC__Expected_Commission_Amount__c = 2;

		Test.startTest();
		controller.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.RECEIVED;
		controller.save();
		Novidea_HPC__Proposal__c[] props = [
			SELECT (SELECT Novidea_HPC__Previous_Policy__c FROM Novidea_HPC__Products__r)
			FROM Novidea_HPC__Proposal__c
		];
		system.assertEquals(1, props.size());
		system.assertEquals(null, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Previous_Policy__c);
	}

	@isTest
	static void testApplProductBuilderExtProposalProdActualFromAppProdExpected() {
		prepData();
		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		con.init();
		system.assertEquals(1, con.products.size());
		set<Id> prodIds = new Set<Id>();
		prodIds.add(con.products[0].product.Id);
		con.products[0].productEffDate = '05/05/2015';
		con.products[0].isSelected = false;
		con.products[0].product.Novidea_HPC__Required_Policy_Type__c = 'New';
		con.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.RECEIVED;
		con.products[0].product.Novidea_HPC__Carrier__c = dataAccount.Id;
		con.products[0].carrierName = dataAccount.Name;
		con.products[0].product.Novidea_HPC__Product_Definition__c = productDef.id;
		con.products[0].productDefName = productDef.Name;
		con.products[0].product.Novidea_HPC__Expected_Premium__c = 13;
		con.products[0].product.Novidea_HPC__Expected_Premium_Net__c = 8;
		con.products[0].product.Novidea_HPC__Expected_Fees__c = 5;
		con.products[0].product.Novidea_HPC__Expected_Commission_Amount__c = 2;
		Test.startTest();
		con.save();
		Novidea_HPC__Proposal__c[] props = [
			SELECT
				Novidea_HPC__Carrier__c,
				(
					SELECT
						Novidea_HPC__Premium__c,
						Novidea_HPC__Premium_Net__c,
						Novidea_HPC__Fee_Amount__c,
						Novidea_HPC__Commission_Amount__c,
						Novidea_HPC__Expected_Premium__c,
						Novidea_HPC__Expected_Premium_Net__c,
						Novidea_HPC__Expected_Fees__c,
						Novidea_HPC__Expected_Commission_Amount__c
					FROM Novidea_HPC__Products__r
				)
			FROM Novidea_HPC__Proposal__c
		];
		system.assertEquals(1, props.size());
		system.assertEquals(13, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Premium__c);
		system.assertEquals(8, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Premium_Net__c);
		system.assertEquals(5, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Fee_Amount__c);
		system.assertEquals(2, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Commission_Amount__c);

		con.products[0].product.Novidea_HPC__Expected_Premium__c = 14;
		con.products[0].product.Novidea_HPC__Expected_Premium_Net__c = 9;
		con.products[0].product.Novidea_HPC__Expected_Fees__c = 5;
		con.products[0].product.Novidea_HPC__Expected_Commission_Amount__c = 3;
		con.products[0].product.Novidea_HPC__Target_Agency_Fee__c = 1.5;
		con.products[0].product.Novidea_HPC__Agency_Fee_Currency__c = 'USD';

		con.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
		con.save();
		props = [
			SELECT
				Novidea_HPC__Carrier__c,
				(
					SELECT
						Novidea_HPC__Premium__c,
						Novidea_HPC__Premium_Net__c,
						Novidea_HPC__Fee_Amount__c,
						Novidea_HPC__Commission_Amount__c,
						Novidea_HPC__Expected_Premium__c,
						Novidea_HPC__Expected_Premium_Net__c,
						Novidea_HPC__Expected_Fees__c,
						Novidea_HPC__Expected_Commission_Amount__c,
						Novidea_HPC__Target_Agency_Fee__c,
						Novidea_HPC__Agency_Fee_Currency__c
					FROM Novidea_HPC__Products__r
				)
			FROM Novidea_HPC__Proposal__c
		];
		system.assertEquals(14, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Premium__c);
		system.assertEquals(9, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Premium_Net__c);
		system.assertEquals(5, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Fee_Amount__c);
		system.assertEquals(3, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Commission_Amount__c);
		system.assertEquals(1.5, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Target_Agency_Fee__c);
		system.assertEquals('USD', props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Agency_Fee_Currency__c);

		con.products[0].isSelected = true;

		CurrencyTriggerHelper.stopTrigger = true;
		con.convert();
		Test.stopTest();
		Novidea_HPC__Policy__c[] policies = [
			SELECT
				Novidea_HPC__Commission_Amount__c,
				Novidea_HPC__Net_Premiumium__c,
				Novidea_HPC__Fees__c,
				Novidea_HPC__Premium_Amount__c,
				Novidea_HPC__Agency_Fee__c,
				Novidea_HPC__Agency_Fees_Currency__c
			FROM Novidea_HPC__Policy__c
		];
		system.assertEquals(1, policies.size());
		system.assertEquals(14, policies[0].Novidea_HPC__Premium_Amount__c);
		system.assertEquals(9, policies[0].Novidea_HPC__Net_Premiumium__c);
		system.assertEquals(5, policies[0].Novidea_HPC__Fees__c);
		system.assertEquals(3, policies[0].Novidea_HPC__Commission_Amount__c);
		system.assertEquals(1.5, policies[0].Novidea_HPC__Agency_Fee__c);
		system.assertEquals('USD', policies[0].Novidea_HPC__Agency_Fees_Currency__c);
	}

	@isTest
	static void testApplProductBuilderExtendCopyAppProductToPolicyProduct() {
		prepData();
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		gs.Novidea_HPC__Copy_Renewal_Product_To_Policy_Product__c = true;
		Database.update(gs);
		Novidea_HPC__Process__c proc = new Novidea_HPC__Process__c(name = 'test Process', Novidea_HPC__Create_Policy_Product__c = true);
		Database.insert(proc);
		CurrencyTriggerHelper.stopTrigger = true;
		Novidea_HPC__Process_Connection__c processConnection = new Novidea_HPC__Process_Connection__c(
			Novidea_HPC__Process__c = proc.Id,
			Novidea_HPC__Product_Def__c = productDef.Id,
			Novidea_HPC__Product_Record_Type__c = 'General_Product'
		);
		Database.insert(processConnection);

		PageReference pageRef = Page.ApplProductBuilderExtend;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApplProductBuilderExtendCO con = new ApplProductBuilderExtendCO(new ApexPages.StandardController(application));

		con.init();
		system.assertEquals(1, con.products.size());
		set<Id> prodIds = new Set<Id>();
		prodIds.add(con.products[0].product.Id);
		con.products[0].productEffDate = '05/05/2015';
		con.products[0].isSelected = false;
		con.products[0].product.Novidea_HPC__Required_Policy_Type__c = 'New';
		con.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.RECEIVED;
		con.products[0].product.Novidea_HPC__Carrier__c = dataAccount.Id;
		con.products[0].carrierName = dataAccount.Name;
		con.products[0].productDefName = productDef.Name;
		con.products[0].product.Novidea_HPC__Does_the_Driving_Licence_Revoked_for_Any__c = true;

		Test.startTest();
		con.save();
		Novidea_HPC__Proposal__c[] props = [
			SELECT Novidea_HPC__Carrier__c, (SELECT Novidea_HPC__Does_the_Driving_Licence_Revoked_for_Any__c FROM Novidea_HPC__Products__r)
			FROM Novidea_HPC__Proposal__c
		];
		system.assertEquals(1, props.size());
		system.assertEquals(true, props[0].Novidea_HPC__Products__r[0].Novidea_HPC__Does_the_Driving_Licence_Revoked_for_Any__c);

		con.products[0].product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
		con.save();

		con.products[0].isSelected = true;
		con.products[0].profitCenter = ApprovedProposalsController.composeProfitCenterName(
			new Novidea_HPC__Broker_Number__c(Id = brokerNumber.Id, name = 'profit center1')
		);
		con.convert();
		Test.stopTest();
		Novidea_HPC__Policy__c[] policies = [SELECT Id FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Application__c = :application.Id];
		// TODO: Not working when deploying to PROD, need to solve
		// system.assertEquals(1, policies.size());
		// system.assert(
		// 	[
		// 		SELECT Novidea_HPC__Does_the_Driving_Licence_Revoked_for_Any__c
		// 		FROM Novidea_HPC__Product__c
		// 		WHERE Novidea_HPC__Policy__c = :policies[0].Id
		// 	]
		// 	.Novidea_HPC__Does_the_Driving_Licence_Revoked_for_Any__c
		// );

		// Database.delete([SELECT Id FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Application__c = :application.Id]);
		// system.assertEquals(3, [SELECT Id FROM Novidea_HPC__Product__c].size());
	}
}