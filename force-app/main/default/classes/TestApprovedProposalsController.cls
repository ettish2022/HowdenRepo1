@isTest(seeAllData=false)
private with sharing class TestApprovedProposalsController {
	private static final String RECEIVED = 'Received';
	private static final String ACCEPTED = 'Accepted';

	private static void init(
		List<Novidea_HPC__Product_Def__c> productdefs,
		Novidea_HPC__Application__c application,
		List<Novidea_HPC__Product__c> appProducts,
		List<Novidea_HPC__Request_for_Proposal__c> rfqs,
		List<Novidea_HPC__Product__c> rfqProducts,
		List<Novidea_HPC__Proposal__c> proposals,
		List<Novidea_HPC__Product__c> propProducts
	) {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = true,
				Novidea_HPC__Mark_NTU_On_Not_Converted_Proposals__c = true,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		Id recordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account');
		list<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 2; ++i) {
			accounts.add(new Account(name = 'carrier' + i, RecordTypeId = recordTypeId, Novidea_HPC__Market_Code__c = '5322'));
		}
		Database.insert(accounts);
		productdefs.add(new Novidea_HPC__Product_Def__c(name = 'def1'));
		productdefs.add(new Novidea_HPC__Product_Def__c(name = 'def2'));
		productdefs.add(new Novidea_HPC__Product_Def__c(name = 'def3'));
		productdefs.add(new Novidea_HPC__Product_Def__c(name = 'def4'));
		Database.insert(productdefs);

		Database.Insert(application);

		appProducts.add(
			new Novidea_HPC__Product__c(
				name = 'def1',
				Novidea_HPC__Product_Definition__c = productdefs[0].id,
				Novidea_HPC__Application__c = application.id
			)
		);
		appProducts.add(
			new Novidea_HPC__Product__c(
				name = 'def2',
				Novidea_HPC__Product_Definition__c = productdefs[1].id,
				Novidea_HPC__Application__c = application.id
			)
		);
		appProducts.add(
			new Novidea_HPC__Product__c(
				name = 'def3',
				Novidea_HPC__Product_Definition__c = productdefs[2].id,
				Novidea_HPC__Application__c = application.id
			)
		);
		appProducts.add(
			new Novidea_HPC__Product__c(
				name = 'def4',
				Novidea_HPC__Product_Definition__c = productdefs[3].id,
				Novidea_HPC__Application__c = application.id
			)
		);
		Database.insert(appProducts);

		rfqs.add(
			new Novidea_HPC__Request_for_Proposal__c(
				name = 'rfp1',
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id
			)
		);
		rfqs.add(
			new Novidea_HPC__Request_for_Proposal__c(
				name = 'rfp2',
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id
			)
		);
		rfqs.add(
			new Novidea_HPC__Request_for_Proposal__c(
				name = 'rfp3',
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id
			)
		);
		rfqs.add(
			new Novidea_HPC__Request_for_Proposal__c(
				name = 'rfp4',
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[1].Id
			)
		);
		rfqs.add(
			new Novidea_HPC__Request_for_Proposal__c(
				name = 'rfp5',
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[1].Id
			)
		);
		Database.insert(rfqs);

		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd1',
				Novidea_HPC__Product_Definition__c = productdefs[0].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[0].id,
				Novidea_HPC__Product__c = appProducts[0].id
			)
		);
		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd2',
				Novidea_HPC__Product_Definition__c = productdefs[0].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[1].id,
				Novidea_HPC__Product__c = appProducts[0].id
			)
		);
		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd3',
				Novidea_HPC__Product_Definition__c = productdefs[1].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[2].id,
				Novidea_HPC__Product__c = appProducts[1].id
			)
		);
		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd4',
				Novidea_HPC__Product_Definition__c = productdefs[1].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[3].id,
				Novidea_HPC__Product__c = appProducts[1].id
			)
		);
		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd5',
				Novidea_HPC__Product_Definition__c = productdefs[3].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[4].id,
				Novidea_HPC__Product__c = appProducts[3].id
			)
		);
		rfqProducts.add(
			new Novidea_HPC__Product__c(
				name = 'rfpProd6',
				Novidea_HPC__Product_Definition__c = productdefs[2].id,
				Novidea_HPC__Request_for_Proposal__c = rfqs[3].id,
				Novidea_HPC__Product__c = appProducts[2].id
			)
		);
		Database.insert(rfqProducts);

		proposals.add(
			new Novidea_HPC__Proposal__c(
				Name = 'prop0',
				Novidea_HPC__Status__c = RECEIVED,
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id,
				Novidea_HPC__Request_For_Proposal__c = rfqs[0].Id
			)
		);
		proposals.add(
			new Novidea_HPC__Proposal__c(
				Name = 'prop1',
				Novidea_HPC__Status__c = RECEIVED,
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id,
				Novidea_HPC__Request_For_Proposal__c = rfqs[1].Id
			)
		);
		proposals.add(
			new Novidea_HPC__Proposal__c(
				Name = 'prop2',
				Novidea_HPC__Status__c = RECEIVED,
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[0].Id,
				Novidea_HPC__Request_For_Proposal__c = rfqs[2].Id
			)
		);
		proposals.add(
			new Novidea_HPC__Proposal__c(
				Name = 'prop3',
				Novidea_HPC__Status__c = RECEIVED,
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[1].Id,
				Novidea_HPC__Request_For_Proposal__c = rfqs[3].Id
			)
		);
		proposals.add(
			new Novidea_HPC__Proposal__c(
				Name = 'prop4',
				Novidea_HPC__Status__c = RECEIVED,
				Novidea_HPC__Application__c = application.id,
				Novidea_HPC__Carrier__c = accounts[1].Id,
				Novidea_HPC__Request_For_Proposal__c = rfqs[4].Id
			)
		);
		Database.insert(proposals);

		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr1',
				Novidea_HPC__Product_Definition__c = productdefs[0].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[0].id,
				Novidea_HPC__Product__c = rfqProducts[0].id
			)
		);
		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr2',
				Novidea_HPC__Product_Definition__c = productdefs[0].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[1].id,
				Novidea_HPC__Product__c = rfqProducts[0].id
			)
		);
		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr3',
				Novidea_HPC__Product_Definition__c = productdefs[1].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[2].id,
				Novidea_HPC__Product__c = rfqProducts[2].id
			)
		);
		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr4',
				Novidea_HPC__Product_Definition__c = productdefs[1].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[3].id,
				Novidea_HPC__Product__c = rfqProducts[2].id
			)
		);
		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr5',
				Novidea_HPC__Product_Definition__c = productdefs[2].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[3].id,
				Novidea_HPC__Product__c = rfqProducts[4].id
			)
		);
		propProducts.add(
			new Novidea_HPC__Product__c(
				Name = 'pr6',
				Novidea_HPC__Product_Definition__c = productdefs[3].id,
				Novidea_HPC__Status__c = ACCEPTED,
				Novidea_HPC__Proposal__c = proposals[4].id,
				Novidea_HPC__Product__c = rfqProducts[5].id
			)
		);
		Database.insert(propProducts);
	}

	@isTest
	private static void testBlockConvertingSameAppProdOnSameProdDefOff() {
		Novidea_HPC__Product_Def__c[] productdefs = new List<Novidea_HPC__Product_Def__c>{};
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Novidea_HPC__Product__c[] appProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Request_for_Proposal__c[] rfqs = new List<Novidea_HPC__Request_for_Proposal__c>{};
		Novidea_HPC__Product__c[] rfqProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Proposal__c[] proposals = new List<Novidea_HPC__Proposal__c>{};
		Novidea_HPC__Product__c[] propProducts = new List<Novidea_HPC__Product__c>{};
		init(productdefs, application, appProducts, rfqs, rfqProducts, proposals, propProducts);
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		gs.Novidea_HPC__Enable_Same_Product_Def__c = false;
		Database.update(gs);
		PageReference pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', application.Id);
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
			[SELECT Id FROM Novidea_HPC__Proposal__c WHERE Id IN :new List<Id>{ proposals[2].Id, proposals[3].Id }]
		);

		controller.setSelected(proposals);
		ApprovedProposalsController con = new ApprovedProposalsController(controller);
		con.convertToPolicy();
		System.assert(con.hasErrors);
	}

	@isTest
	private static void testCalcExpectedFees() {
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
		Id recordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account');
		list<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 10; ++i) {
			accounts.add(new Account(name = 'test' + i, RecordTypeId = recordTypeId, Novidea_HPC__Market_Code__c = '5322'));
		}
		Database.insert(accounts);
		list<Novidea_HPC__Agreement__c> agreements = new List<Novidea_HPC__Agreement__c>();
		for (Integer i = 0; i < 10; ++i) {
			agreements.add(
				new Novidea_HPC__Agreement__c(Novidea_HPC__Carrier__c = accounts.get(i).Id, Novidea_HPC__Carrier_Producer_del__c = null)
			);
		}
		Database.insert(agreements);
		list<Novidea_HPC__Broker_Number__c> brokers = new List<Novidea_HPC__Broker_Number__c>();
		for (Integer i = 0; i < 10; ++i) {
			brokers.add(new Novidea_HPC__Broker_Number__c(Novidea_HPC__Agreement__c = agreements.get(i).Id, name = 'test' + i));
		}
		Database.insert(brokers);
		list<Novidea_HPC__Request_For_Proposal__c> rfps = new List<Novidea_HPC__Request_For_Proposal__c>();
		for (Integer i = 0; i < 10; ++i) {
			rfps.add(new Novidea_HPC__Request_For_Proposal__c(Name = 'test' + i, Novidea_HPC__Broker_Number__c = brokers.get(i).Id));
		}
		Database.insert(rfps);
		list<Novidea_HPC__Proposal__c> proposals = new List<Novidea_HPC__Proposal__c>();
		for (Integer i = 0; i < 10; ++i) {
			proposals.add(new Novidea_HPC__Proposal__c(Name = 'test' + i, Novidea_HPC__Request_For_Proposal__c = rfps.get(i).Id));
		}
		Database.insert(proposals);
		for (Integer i = 0; i < 10; ++i) {
			Novidea_HPC__Broker_Number__c bn = brokers.get(i);
			Novidea_HPC__Request_For_Proposal__c rfp = rfps.get(i);
			rfp.Novidea_HPC__Broker_Number__r = bn;
			proposals.get(i).Novidea_HPC__Request_For_Proposal__r = rfp;
		}
		list<Novidea_HPC__Product_Def__c> productDefs = new List<Novidea_HPC__Product_Def__c>();
		for (Integer i = 0; i < 10; ++i) {
			productDefs.add(new Novidea_HPC__Product_Def__c(name = 'test' + i));
		}
		Database.insert(productDefs);
		list<Novidea_HPC__Commission_Rate__c> comrates = new List<Novidea_HPC__Commission_Rate__c>();
		list<String> calculationTypes = new List<String>(
			NOVU.ArrayUtils.getPicklistValues('Novidea_HPC__Calculation_Type__c', Novidea_HPC__Commission_Rate__c.sobjectType).keyset()
		);
		for (Integer i = 0; i < 10; ++i) {
			comRates.add(
				new Novidea_HPC__Commission_Rate__c(
					Novidea_HPC__Calculation_Type__c = (math.mod(i, 2) == 0
						? 'Percentage from Premium by fees range'
						: 'Percentage from Net Premium by fees range'),
					Novidea_HPC__Product_Definition__c = productDefs.get(math.mod(i, 10)).Id,
					Novidea_HPC__Minimum_Percentage__c = math.mod(i, 10),
					Novidea_HPC__Maximum_Percentage__c = math.mod(i, 10) + 10,
					Novidea_HPC__Percentage__c = 30 - math.mod(i, 10),
					Novidea_HPC__Product_Cost_Price__c = null,
					Novidea_HPC__Agreement__c = agreements.get(math.mod(i, 10)).Id,
					Novidea_HPC__Product_Cost_Price_Currency__c = null,
					Novidea_HPC__Product_Maximum_Price__c = null
				)
			);
		}
		Database.insert(comRates);
		list<Novidea_HPC__Product__c> products = new List<Novidea_HPC__Product__c>();
		map<Integer, Novidea_HPC__Proposal__c> propsByProdId = new Map<Integer, Novidea_HPC__Proposal__c>();
		for (Integer i = 0; i < 10; ++i) {
			products.add(
				new Novidea_HPC__Product__c(
					Novidea_HPC__Proposal__c = proposals.get(i).Id,
					Novidea_HPC__Product_Definition__c = productDefs.get(i).Id,
					Novidea_HPC__Premium_Net__c = (i + 1) * 1000
				)
			);
			propsByProdId.put(i, proposals.get(i));
		}
		Test.startTest();
		ProductHelper.calcExpectedFees(products);
		Integer j = 0;
		list<Novidea_HPC__Commission_Rate__c> tempComRateList;
		for (Novidea_HPC__Product__c prod : products) {
			Novidea_HPC__Proposal__c prop = propsByProdId.get(j);
			for (Novidea_HPC__Commission_Rate__c cr : comRates) {
				if (
					(cr.Novidea_HPC__Calculation_Type__c == 'Percentage from Premium by fees range' ||
					cr.Novidea_HPC__Calculation_Type__c == 'Percentage from Net Premium by fees range') &&
					prop.Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Broker_Number__r.Novidea_HPC__Agreement__c ==
					cr.Novidea_HPC__Agreement__c &&
					prod.Novidea_HPC__Product_Definition__c == cr.Novidea_HPC__Product_Definition__c
				) {
					if (tempComRateList == null)
						tempComRateList = new List<Novidea_HPC__Commission_Rate__c>();
					tempComRateList.add(cr);
				}
			}
			Novidea_HPC__Commission_Rate__c cr = tempComRateList[0];
			system.debug(tempComRateList.size() + '\n' + cr);
			system.assertEquals(
				prod.Novidea_HPC__Premium_Net__c *
				cr.Novidea_HPC__Maximum_Percentage__c /
				100,
				prod.Novidea_HPC__Expected_Fees__c
			);
			j++;
			tempComRateList = null;
		}
		Test.stopTest();
	}

	@isTest
	private static void testApprovedProposalCO() {
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
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		insert proDef;
		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c();
		insert app;
		Novidea_HPC__Proposal__c propsal = new Novidea_HPC__Proposal__c();
		propsal.Novidea_HPC__Application__c = app.Id;
		insert propsal;

		Novidea_HPC__Proposal__c propsal2 = new Novidea_HPC__Proposal__c();
		propsal2.Novidea_HPC__Application__c = app.Id;
		insert propsal2;
		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c();
		pro.Novidea_HPC__Application__c = app.Id;
		pro.Novidea_HPC__Product_Definition__c = proDef.Id;
		pro.Novidea_HPC__Proposal__c = propsal.Id;
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Discount__c = 1;
		pro.Novidea_HPC__Effective_Date__c = date.today();
		pro.Novidea_HPC__Expiration_Date__c = date.today();
		pro.Novidea_HPC__Fee_Amount__c = 1;
		pro.Novidea_HPC__Fee_Currency__c = 'ILS';
		pro.Novidea_HPC__Premium__c = 1;
		pro.Novidea_HPC__Premium_Currency__c = 'ILS';
		pro.Novidea_HPC__Commission__c = 1;
		insert pro;
		Account acc = new Account(
			Name = 'tess',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		insert acc;
		Novidea_HPC__Request_for_Proposal__c rfp = new Novidea_HPC__Request_for_Proposal__c();
		rfp.Novidea_HPC__Carrier__c = acc.Id;
		rfp.Novidea_HPC__Application__c = app.Id;
		insert rfp;

		CurrencyTriggerHelper.stopTrigger = true;
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Application__c = app.Id;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Carrier__c = acc.Id;
		insert policy;

		PageReference pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
			Database.getQueryLocator([SELECT Id FROM Novidea_HPC__Proposal__c WHERE Id = :propsal.Id])
		);
		list<Novidea_HPC__Proposal__c> listProposal = new List<Novidea_HPC__Proposal__c>();
		listProposal.add(propsal);
		controller.setSelected(listProposal);
		ApprovedProposalsController con = new ApprovedProposalsController(controller);
		con.convertToPolicy();
		ApprovedProposalsController.BrokerNumberWrapper bnw = new ApprovedProposalsController.BrokerNumberWrapper(
			acc.Id,
			new Set<Id>{ proDef.Id }
		);
		con.cancel();
		ApexPages.StandardController controller2 = new ApexPages.StandardController(propsal2);
		ApprovedProposalsController con2 = new ApprovedProposalsController(controller2);
	}

	@isTest
	static void testApprovedProposalCO2() {
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
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		insert proDef;
		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c();
		insert app;
		Novidea_HPC__Proposal__c propsal = new Novidea_HPC__Proposal__c();
		propsal.Novidea_HPC__Application__c = app.Id;
		insert propsal;

		Novidea_HPC__Proposal__c propsal2 = new Novidea_HPC__Proposal__c();
		propsal2.Novidea_HPC__Application__c = app.Id;
		insert propsal2;
		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c();
		pro.Novidea_HPC__Application__c = app.Id;
		pro.Novidea_HPC__Product_Definition__c = proDef.Id;
		pro.Novidea_HPC__Proposal__c = propsal.Id;
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Discount__c = 1;
		pro.Novidea_HPC__Effective_Date__c = date.today();
		pro.Novidea_HPC__Expiration_Date__c = date.today();
		pro.Novidea_HPC__Fee_Amount__c = 1;
		pro.Novidea_HPC__Fee_Currency__c = 'ILS';
		pro.Novidea_HPC__Premium__c = 1;
		pro.Novidea_HPC__Premium_Currency__c = 'ILS';
		pro.Novidea_HPC__Commission__c = 1;
		insert pro;
		Account acc = new Account(
			Name = 'tess',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		insert acc;
		Novidea_HPC__Request_for_Proposal__c rfp = new Novidea_HPC__Request_for_Proposal__c();
		rfp.Novidea_HPC__Carrier__c = acc.Id;
		rfp.Novidea_HPC__Application__c = app.Id;
		insert rfp;

		CurrencyTriggerHelper.stopTrigger = true;
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Application__c = app.Id;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Carrier__c = acc.Id;
		insert policy;

		PageReference pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
			Database.getQueryLocator([SELECT Id FROM Novidea_HPC__Proposal__c WHERE Id = :propsal.Id])
		);
		list<Novidea_HPC__Proposal__c> listProposal = new List<Novidea_HPC__Proposal__c>();
		listProposal.add(propsal);
		listProposal.add(propsal2);
		controller.setSelected(listProposal);
		ApprovedProposalsController con = new ApprovedProposalsController(controller);
		con.convertToPolicy();
		con.convertToPolicy();
		ApprovedProposalsController.BrokerNumberWrapper bnw = new ApprovedProposalsController.BrokerNumberWrapper(
			acc.Id,
			new Set<Id>{ proDef.Id }
		);
		con.cancel();
		ApexPages.StandardController controller2 = new ApexPages.StandardController(propsal2);
		ApprovedProposalsController con2 = new ApprovedProposalsController(controller2);
	}

	@isTest
	public static void testCancelledStatus() {
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
		Novidea_HPC__Product_Def__c productDefinition = new Novidea_HPC__Product_Def__c();
		Database.insert(productDefinition);
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Database.insert(application);
		Account carrier = new Account(Name = 'test');
		Database.insert(carrier);
		Novidea_HPC__Agreement__c agreement = new Novidea_HPC__Agreement__c(
			Novidea_HPC__Carrier__c = carrier.Id,
			Novidea_HPC__Carrier_Producer_del__c = null
		);
		Database.insert(agreement);
		Novidea_HPC__Broker_Number__c broker = new Novidea_HPC__Broker_Number__c(Novidea_HPC__Agreement__c = agreement.Id, name = 'test');
		Database.insert(broker);

		Novidea_HPC__Request_for_Proposal__c requestForProposal = new Novidea_HPC__Request_for_Proposal__c(
			Name = 'RFP',
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Carrier__c = carrier.Id,
			Novidea_HPC__Status__c = 'Received By Carrier',
			Novidea_HPC__Broker_Number__c = broker.Id
		);
		Database.insert(requestForProposal);
		Novidea_HPC__Hierarchical_General_Settings__c generalSettings = new Novidea_HPC__Hierarchical_General_Settings__c(
			Novidea_HPC__Proposal_Cancelled_Statuses__c = 'Rejected by agent , Rejected'
		);
		Database.insert(generalSettings);
		List<Novidea_HPC__Proposal__c> proposalList = new List<Novidea_HPC__Proposal__c>{
			new Novidea_HPC__Proposal__c(
				Name = 'Test',
				Novidea_HPC__Request_For_Proposal__c = requestForProposal.Id,
				Novidea_HPC__Status__c = ConvertProposalsHelper.REJECTED
			)
		};
		Database.insert(proposalList);
		Novidea_HPC__Product__c proposalProduct = new Novidea_HPC__Product__c(
			Name = 'Product',
			Novidea_HPC__Expected_Premium__c = 500,
			Novidea_HPC__Expected_Commission_Amount__c = 50,
			Novidea_HPC__Proposal__c = proposalList[0].Id,
			Novidea_HPC__Product_Definition__c = productDefinition.Id,
			Novidea_HPC__Status__c = ACCEPTED
		);
		Novidea_HPC__Product__c rfpProduct = new Novidea_HPC__Product__c(
			Name = 'Product',
			Novidea_HPC__Expected_Premium__c = 500,
			Novidea_HPC__Expected_Commission_Amount__c = 50,
			Novidea_HPC__Proposal__c = proposalList[0].Id,
			Novidea_HPC__Product_Definition__c = productDefinition.Id
		);
		Database.insert(new List<Novidea_HPC__Product__c>{ proposalProduct, rfpProduct });

		CurrencyTriggerHelper.stopTrigger = true;
		Apexpages.currentPage().getParameters().put('Id', application.Id);
		ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(proposalList);
		standardController.setSelected(proposalList);
		ApprovedProposalsController controller = new ApprovedProposalsController(standardController);
		controller.convertToPolicy();
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Novidea_HPC.No_products_related_to_chosen_proposals, ApexPages.getMessages()[0].getSummary());
	}

	private static Novidea_HPC__Product__c createProduct(Id applicationId, Id productDefId, Id proposalId) {
		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c(name = '' + applicationId + productDefId + proposalId);
		pro.Novidea_HPC__Product_Definition__c = productDefId;
		pro.Novidea_HPC__Proposal__c = proposalId;
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Discount__c = 1;
		pro.Novidea_HPC__Effective_Date__c = date.today();
		pro.Novidea_HPC__Expiration_Date__c = date.today();
		pro.Novidea_HPC__Fee_Amount__c = 1;
		pro.Novidea_HPC__Fee_Currency__c = 'ILS';
		pro.Novidea_HPC__Premium__c = 1;
		pro.Novidea_HPC__Premium_Currency__c = 'ILS';
		pro.Novidea_HPC__Commission__c = 1;
		pro.Novidea_HPC__Status__c = ACCEPTED;
		return pro;
	}

	// secondProposalType
	//   0 - no second proposal
	//   1 - second propsal with same productDef like first proposal
	//   2 - second proposal with different productDef
	private static List<Novidea_HPC__Product_Def__c> preformSameProductDefTestLogic(Boolean alreadyHasPolicy, Integer secondProposalType) {
		List<Novidea_HPC__Product_Def__c> productDefs = new List<Novidea_HPC__Product_Def__c>();
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c(name = 'def1');
		productDefs.add(proDef);
		Novidea_HPC__Product_Def__c proDef2 = new Novidea_HPC__Product_Def__c(name = 'def2');
		productDefs.add(proDef2);
		Database.insert(productDefs);

		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c(name = 'app1');
		Database.insert(app);
		List<Id> proposalIds = new List<Id>();
		List<Novidea_HPC__Proposal__c> proposals = new List<Novidea_HPC__Proposal__c>();
		Novidea_HPC__Proposal__c proposal1 = new Novidea_HPC__Proposal__c(name = 'prop1');
		proposal1.Novidea_HPC__Application__c = app.Id;
		proposals.add(proposal1);

		Novidea_HPC__Proposal__c proposal2;
		if (secondProposalType != 0) {
			proposal2 = new Novidea_HPC__Proposal__c(name = 'prop2');
			proposal2.Novidea_HPC__Application__c = app.Id;
			proposals.add(proposal2);
		}

		Database.insert(proposals);
		for (Novidea_HPC__Proposal__c proposal : proposals)
			proposalIds.add(proposal.Id);

		List<Novidea_HPC__Product__c> products = new List<Novidea_HPC__Product__c>();
		products.add(createProduct(app.Id, proDef.Id, proposal1.Id));
		if (secondProposalType == 1)
			products.add(createProduct(app.Id, proDef.Id, proposal2.Id));
		else if (secondProposalType == 2)
			products.add(createProduct(app.Id, proDef2.Id, proposal2.Id));
		Database.insert(products);

		CurrencyTriggerHelper.stopTrigger = true;
		if (alreadyHasPolicy) {
			Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(name = 'pol1');
			policy.Novidea_HPC__Application__c = app.Id;
			policy.Novidea_HPC__Product_Definition__c = proDef.Id;
			Account acc = new Account(
				Name = 'carrier',
				RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
				Novidea_HPC__Market_Code__c = '5322'
			);
			policy.Novidea_HPC__Carrier__c = acc.Id;
			Database.insert(policy);
		}

		PageReference pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
			[SELECT Id FROM Novidea_HPC__Proposal__c WHERE Id IN :proposalIds]
		);

		controller.setSelected(proposals);
		ApprovedProposalsController con = new ApprovedProposalsController(controller);
		con.advancedModeVal = true;
		con.convertToPolicy();

		return productDefs;
	}

	@isTest
	public static void testEnableSameProductDefHasPolicy() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = true,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		preformSameProductDefTestLogic(true, 0);

		system.assertEquals(2, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Status__c FROM Novidea_HPC__Product__c];
		system.assertEquals(1, products.size());
		System.assertEquals(ConvertProposalsHelper.CONVERTED, products[0].Novidea_HPC__Status__c);
	}

	@isTest
	public static void testDisableSameProductDefHasPolicy() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = false,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		preformSameProductDefTestLogic(true, 0);

		system.assertEquals(1, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Status__c FROM Novidea_HPC__Product__c];
		system.assertEquals(1, products.size());
		System.assertEquals(ACCEPTED, products[0].Novidea_HPC__Status__c);
	}

	@isTest
	public static void testDisableSameProductDefNoPolicyTwoProposalsWithSameProductDef() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = false,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		preformSameProductDefTestLogic(false, 1);

		// create only one policy with the productDef
		system.assertEquals(1, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Status__c FROM Novidea_HPC__Product__c];
		system.assertEquals(2, products.size());
		System.assert(
			(ACCEPTED == products[0].Novidea_HPC__Status__c && ConvertProposalsHelper.CONVERTED == products[1].Novidea_HPC__Status__c) ||
			(ACCEPTED == products[1].Novidea_HPC__Status__c &&
			ConvertProposalsHelper.CONVERTED == products[0].Novidea_HPC__Status__c)
		);
	}

	@isTest
	public static void testEnableSameProductDefNoPolicyTwoProposalsWithSameProductDef() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = true,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		preformSameProductDefTestLogic(false, 1);

		// create two policies with the same productDef
		system.assertEquals(2, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Status__c FROM Novidea_HPC__Product__c];
		system.assertEquals(2, products.size());
		for (Novidea_HPC__Product__c product : products) {
			System.assertEquals(ConvertProposalsHelper.CONVERTED, product.Novidea_HPC__Status__c);
		}
	}

	@isTest
	public static void testEnableSameProductDefHasPolicyTwoProposalsWithDifferentProductDef() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = true,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		preformSameProductDefTestLogic(true, 2);

		// The productdef of one proposal is equals to existing policy productDef
		// create two policies with two different productDef
		// total policies is 3 (including existing policy)
		system.assertEquals(3, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Status__c FROM Novidea_HPC__Product__c];
		system.assertEquals(2, products.size());
		for (Novidea_HPC__Product__c product : products) {
			System.assertEquals(ConvertProposalsHelper.CONVERTED, product.Novidea_HPC__Status__c);
		}
	}

	@isTest
	public static void testDisableSameProductDefHasPolicyTwoProposalsWithDifferentProductDef() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Enable_Same_Product_Def__c = false,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);
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
		List<Novidea_HPC__Product_Def__c> productDefs = preformSameProductDefTestLogic(true, 2);

		// The productdef of one propsal is equals to existing policy productDef
		// create only one policy (with the productDef that is not equal to existing productDef)
		// total policies is 2 (including existing policy)
		system.assertEquals(2, [SELECT Id FROM Novidea_HPC__Policy__c].size());

		// get proposal products
		List<Novidea_HPC__Product__c> products = [
			SELECT Novidea_HPC__Status__c, Novidea_HPC__Product_Definition__c
			FROM Novidea_HPC__Product__c
		];
		System.assertEquals(2, products.size());
		for (Novidea_HPC__Product__c product : products) {
			if (product.Novidea_HPC__Product_Definition__c == productDefs[0].Id) {
				System.assertEquals(ACCEPTED, product.Novidea_HPC__Status__c);
			} else if (product.Novidea_HPC__Product_Definition__c == productDefs[1].Id) {
				System.assertEquals(ConvertProposalsHelper.CONVERTED, product.Novidea_HPC__Status__c);
			} else {
				System.assert(false);
			}
		}
	}

	@isTest
	public static void testNTU() {
		Novidea_HPC__Product_Def__c[] productdefs = new List<Novidea_HPC__Product_Def__c>{};
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Novidea_HPC__Product__c[] appProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Request_for_Proposal__c[] rfqs = new List<Novidea_HPC__Request_for_Proposal__c>{};
		Novidea_HPC__Product__c[] rfqProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Proposal__c[] proposals = new List<Novidea_HPC__Proposal__c>{};
		Novidea_HPC__Product__c[] propProducts = new List<Novidea_HPC__Product__c>{};
		init(productdefs, application, appProducts, rfqs, rfqProducts, proposals, propProducts);

		set<Id> productsIds = new Set<Id>();
		for (Novidea_HPC__Product__c product : propProducts) {
			productsIds.add(product.Id);
		}
		Database.update(new Novidea_HPC__Product__c(Id = propProducts[4].Id, Novidea_HPC__Status__c = ConvertProposalsHelper.REJECTED));

		CurrencyTriggerHelper.stopTrigger = true;
		ApprovedProposalsController controller = new ApprovedProposalsController();
		controller.setAllselectedProposals = new Set<Id>{ proposals[0].Id, proposals[2].Id, proposals[4].Id };
		controller.applicationid = application.id;
		controller.init();
		controller.convertToPolicy();
		controller.convertingProductTopolicy();

		List<Novidea_HPC__Product__c> resultProducts = [
			SELECT Name, Novidea_HPC__Status__c, Novidea_HPC__Proposal__r.Novidea_HPC__Status__c
			FROM Novidea_HPC__Product__c
			WHERE Id IN :productsIds
		];

		System.AssertEquals(6, resultProducts.size());
		Map<String, Novidea_HPC__Product__c> productNameToProduct = new Map<String, Novidea_HPC__Product__c>();
		for (Novidea_HPC__Product__c product : resultProducts) {
			System.debug('product name: ' + product.Name);
			productNameToProduct.put(product.Name, product);
		}

		assertProductAndPrposalStatuses(
			productNameToProduct.get('pr1'),
			ConvertProposalsHelper.CONVERTED,
			ConvertProposalsHelper.COVERAGE_CONFIRMATION
		);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr2'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
		assertProductAndPrposalStatuses(
			productNameToProduct.get('pr3'),
			ConvertProposalsHelper.CONVERTED,
			ConvertProposalsHelper.COVERAGE_CONFIRMATION
		);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr4'), ConvertProposalsHelper.NTU, RECEIVED);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr5'), ConvertProposalsHelper.REJECTED, RECEIVED);
		assertProductAndPrposalStatuses(
			productNameToProduct.get('pr6'),
			ConvertProposalsHelper.CONVERTED,
			ConvertProposalsHelper.COVERAGE_CONFIRMATION
		);
	}

	@isTest
	public static void testNTUSharePartial() {
		Novidea_HPC__Product_Def__c[] productdefs = new List<Novidea_HPC__Product_Def__c>{};
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Novidea_HPC__Product__c[] appProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Request_for_Proposal__c[] rfqs = new List<Novidea_HPC__Request_for_Proposal__c>{};
		Novidea_HPC__Product__c[] rfqProducts = new List<Novidea_HPC__Product__c>{};
		Novidea_HPC__Proposal__c[] proposals = new List<Novidea_HPC__Proposal__c>{};
		Novidea_HPC__Product__c[] propProducts = new List<Novidea_HPC__Product__c>{};
		init(productdefs, application, appProducts, rfqs, rfqProducts, proposals, propProducts);

		set<Id> productsIds = new Set<Id>();
		for (Novidea_HPC__Product__c product : propProducts) {
			productsIds.add(product.Id);
		}

		CurrencyTriggerHelper.stopTrigger = true;
		ApprovedProposalsController controller = new ApprovedProposalsController();
		controller.setAllselectedProposals = new Set<Id>{ proposals[0].Id, proposals[1].Id, proposals[4].Id };
		controller.applicationid = application.id;
		controller.init();
		controller.convertToPolicy();
		controller.convertingProductToPolicy();

		List<Novidea_HPC__Product__c> resultProducts = [
			SELECT Name, Novidea_HPC__Status__c, Novidea_HPC__Proposal__r.Novidea_HPC__Status__c
			FROM Novidea_HPC__Product__c
			WHERE Id IN :productsIds
		];

		System.AssertEquals(6, resultProducts.size());
		Map<String, Novidea_HPC__Product__c> productNameToProduct = new Map<String, Novidea_HPC__Product__c>();
		for (Novidea_HPC__Product__c product : resultProducts) {
			productNameToProduct.put(product.Name, product);
		}

		assertProductAndPrposalStatuses(
			productNameToProduct.get('pr1'),
			ConvertProposalsHelper.CONVERTED,
			ConvertProposalsHelper.COVERAGE_CONFIRMATION
		);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr2'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr3'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr4'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr5'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
		assertProductAndPrposalStatuses(productNameToProduct.get('pr6'), ConvertProposalsHelper.NTU, ConvertProposalsHelper.NTU);
	}

	private static void assertProductAndPrposalStatuses(
		Novidea_HPC__Product__c actualProduct,
		String expectedProductStatus,
		String expectedProposalStatus
	) {
		System.AssertEquals(expectedProductStatus, actualProduct.Novidea_HPC__Status__c);
		System.AssertEquals(expectedProposalStatus, actualProduct.Novidea_HPC__Proposal__r.Novidea_HPC__Status__c);
	}
	/*
	@isTest
	static void testPolicyProductRecordTypeWithNoCopyOfRenewalProduct() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Copy_Application_Product_To_RFP_Product__c = true,
				Novidea_HPC__Copy_Renewal_Product_To_Policy_Product__c = false,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);

		testPolicyProductRecordType('Home_Owners');
	}

	@isTest
	static void testPolicyProductRecordTypeWithCopyOfRenewalProduct() {
		Database.Insert(
			new Novidea_HPC__General_Switches__c(
				Name = 'Default',
				Novidea_HPC__Copy_Application_Product_To_RFP_Product__c = true,
				Novidea_HPC__Copy_Renewal_Product_To_Policy_Product__c = true,
				Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
			)
		);

		testPolicyProductRecordType('Home_Owners');
	}

	private static void testPolicyProductRecordType(String reocordTypeName) {
		Novidea_HPC__Product_Category__c category = new Novidea_HPC__Product_Category__c(Name = 'test cat');
		Database.Insert(category);

		Novidea_HPC__Process__c proc = new Novidea_HPC__Process__c(
			name = 'test Process',
			Novidea_HPC__Create_Policy_Product__c = true,
			Novidea_HPC__Renewal__c = 'Application',
			Novidea_HPC__Product_Category__c = category.id
		);
		Database.insert(proc);

		//test cloning application product to rfp product
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c(Name = 'XYZ', Novidea_HPC__Category__c = category.id);
		Database.insert(proDef);

		Novidea_HPC__Process_Connection__c processConnection = new Novidea_HPC__Process_Connection__c(
			Novidea_HPC__Process__c = proc.Id,
			Novidea_HPC__Product_Def__c = proDef.Id,
			Novidea_HPC__Product_Record_Type__c = 'General_Product'
		);
		Database.insert(processConnection);

		Account client = new Account(Name = 'yik');
		Database.insert(client);

		Novidea_HPC__Application__c app = new Novidea_HPC__Application__c(Novidea_HPC__Account__c = client.id);
		Database.insert(app);

		Novidea_HPC__Product__c pro = new Novidea_HPC__Product__c(
			Novidea_HPC__Property_Address__c = 'pro test address',
			Novidea_HPC__Application__c = app.Id,
			Novidea_HPC__Product_Definition__c = proDef.id,
			Novidea_HPC__Effective_Date__c = Date.today().addYears(-1),
			Novidea_HPC__Expiration_Date__c = Date.today() - 1,
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Home_Owners', 'Novidea_HPC__Product__c')
		);
		Database.insert(pro);
		Novidea_HPC__Product__c insidePro = new Novidea_HPC__Product__c(
			Novidea_HPC__Property_Address__c = 'inside test address',
			Novidea_HPC__CombinedProduct__c = pro.id,
			Novidea_HPC__Product_Definition__c = proDef.id,
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Home_Owners', 'Novidea_HPC__Product__c')
		);
		Database.insert(insidePro);

		Novidea_HPC__Plan_Benefit__c planBenefit = new Novidea_HPC__Plan_Benefit__c(Novidea_HPC__Product__c = insidePro.id, Novidea_HPC__Amount__c = 50);
		Database.insert(planBenefit);

		Id insuranceCompanyReocordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account');
		Account acc = new Account(Name = 'tess', RecordtypeId = insuranceCompanyReocordTypeId, Novidea_HPC__Market_Code__c = '5322');
		Database.insert(acc);

		Database.insert(new Novidea_HPC__Carrier_Product__c(Novidea_HPC__Account__c = acc.Id, Novidea_HPC__Product_Definition__c = proDef.Id));

		PageReference pageRef = Page.createRfp;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		createRfpCO con = new createRfpCO(new ApexPages.StandardController(app));
		con.insuranceCommpanies[0].selectedProduct.add(con.InsuranceCommpanies[0].products[0].getValue());
		con.InsuranceCommpanies[0].isSelected = true;

		con.createRFP();
		List<Novidea_HPC__Request_For_Proposal__c> rfps = [SELECT Id FROM Novidea_HPC__Request_For_Proposal__c WHERE Novidea_HPC__Carrier__c = :acc.Id];
		Novidea_HPC__Product__c rfpProduct = [SELECT Novidea_HPC__Property_Address__c FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Request_For_Proposal__c = :rfps[0].id];

		ApexPages.StandardSetController rfpStdController = new ApexPages.StandardSetController(rfps);
		rfpStdController.setSelected(rfps);
		AcceptedRFPController acceptedRFPCon = new AcceptedRFPController(rfpStdController);
		acceptedRFPCon.lightningFlag = false;
		acceptedRFPCon.acceptedProposals();

		List<Novidea_HPC__Proposal__c> proposals = [SELECT Id FROM Novidea_HPC__Proposal__c WHERE Novidea_HPC__Request_for_Proposal__c = :rfps[0].id];

		Novidea_HPC__Product__c proposalProduct = [
			SELECT Novidea_HPC__Status__c, RecordTypeId
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Proposal__c = :proposals[0].id AND Novidea_HPC__Product__c = :rfpProduct.id
		];

		system.assert(proposalProduct != null);
		proposalProduct.RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Home_Owners', 'Novidea_HPC__Product__c');
		proposalProduct.Novidea_HPC__Status__c = 'Accepted';
		Database.update(proposalProduct);
		System.debug(proposalProduct);
		System.debug(NOVU.RecordTypeUtils.getDeveloperNameById(proposalProduct.RecordTypeId, 'Novidea_HPC__Product__c'));

		pageRef = Page.ApprovedProposals;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', app.Id);
		ApexPages.StandardSetController propStdController = new ApexPages.StandardSetController(proposals);

		propStdController.setSelected(proposals);
		ApprovedProposalsController approvedProposalsCon = new ApprovedProposalsController(propStdController);
		approvedProposalsCon.advancedModeVal = true;
		approvedProposalsCon.convertToPolicy();

		Novidea_HPC__Policy__c policy = [SELECT Id, Novidea_HPC__Product__c FROM Novidea_HPC__Policy__c];
		System.assert(policy != null);
		System.assert(policy.Novidea_HPC__Product__c != null);

		Novidea_HPC__Product__c policyProduct = [SELECT Id, RecordTypeId FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Policy__c = :policy.id AND Novidea_HPC__Product__c = :proposalProduct.id];
		System.assert(policyProduct != null);

		System.AssertEquals(reocordTypeName, NOVU.RecordTypeUtils.getDeveloperNameById(policyProduct.RecordTypeId, 'Novidea_HPC__Product__c'));
	}
*/
}