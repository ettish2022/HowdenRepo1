@isTest(seeAllData=false)
public with sharing class TestSalesProcessHelper {
	@TestSetup
	static void makeData() {
		Policy_Currency__c pc = new Policy_Currency__c();
		pc.Commission_Amount__c = pc.Premium_Amount__c = pc.Unpaid_Premium__c = pc.Premium_to_Pay__c = pc.Income_Amount__c = 'Novidea_HPC__Premium_Amount_Currency__c';
		pc.Unpaid_Agency_Fee__c = pc.Agency_Fee__c = 'Novidea_HPC__Agency_Fees_Currency__c';
		pc.Value_Date_Field__c = 'Novidea_HPC__Value_Date__c';
		Database.insert(pc);
		Income_Currency__c ic = new Income_Currency__c();
		ic.Agency_Fee__c = 'Novidea_HPC__Agency_Fee_Currency__c';
		ic.Agent_Discount__c = ic.Commission_Amount__c = ic.Commission_Amount_from_Production__c = ic.Credit_Fees_From_Production__c = ic.Credit_Fees__c = ic.Fees_From_Production__c = ic.Fees__c = ic.Other_Commission__c = ic.Premium_From_Production__c = ic.Premium__c = ic.Underwriter_Commission__c = ic.Premium_Bruto__c = ic.Premium_To_Pay__c = ic.Commission_From_Production_After_Tax__c = ic.Agent_Discount_From_Production__c = ic.subagentfees__c = 'Novidea_HPC__Premium_Currency__c';
		ic.Value_Date_Field__c = 'Value_Date__c';
		Database.insert(ic);
		Novidea_HPC__Trigger__c hpcTrigger = new Novidea_HPC__Trigger__c();
		hpcTrigger.Novidea_HPC__Stop_Validation_Rule__c = true;
		Database.insert(hpcTrigger);
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
	}

	@isTest
	private static void testUpdates() {
		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);
		Novidea_HPC__Product_Def__c pdf = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(pdf);

		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(Name = 'gogo');
		Database.insert(application);

		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = false
		);
		Database.insert(proposal);

		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Discount__c = 20,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today(),
			Novidea_HPC__Fee_Amount__c = 50,
			Novidea_HPC__Premium__c = 20,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Commission__c = 21,
			Novidea_HPC__Product_Definition__c = pdf.id
		);
		Database.insert(product);
		//Novidea_HPC__Product_Def__c prodef = new Novidea_HPC__Product_Def__c(name='test');
		// Database.insert(prodef);
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(
			Novidea_HPC__Carrier__c = carrier.id,
			OwnerId = Userinfo.getUserId(),
			Novidea_HPC__Product_Definition__c = pdf.id
		);
		list<Novidea_HPC__Policy__c> policies = new List<Novidea_HPC__Policy__c>();
		policies.add(policy);
		SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
		SalesProcessHelper.testMode = true;
		ptp.product = product;
		ptp.policy = policy;
		ptp.proposal = proposal;
		ptp.isSelected = ptp.showOverride = true;

		list<SalesProcessHelper.productToPolicy> listproductToPolicy = new List<SalesProcessHelper.productToPolicy>();
		listproductToPolicy.add(ptp);

		SalesProcessHelper.convertingProductTopolicy(listproductToPolicy, application);
		SalesProcessHelper.policyToProduct(policy, null);
		SalesProcessHelper.upsertPolicyPlanBenefits(proposal, policy);
	}

	@isTest
	private static void testUpdatesComplexed() {
		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);
		Novidea_HPC__Product_Def__c pdf = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(pdf);

		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(Name = 'gogo');
		Database.insert(application);

		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = true,
			Novidea_HPC__Estimated_Commission__c = 20,
			Novidea_HPC__Fees_del__c = 2000,
			Novidea_HPC__Fees_Currency__c = 'ILS',
			Novidea_HPC__Premium__c = 3000,
			Novidea_HPC__Premium_Currency__c = 'ILS'
		);
		Database.insert(proposal);

		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Discount__c = 20,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today(),
			Novidea_HPC__Fee_Amount__c = 50,
			Novidea_HPC__Premium__c = 20,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Commission__c = 21,
			Novidea_HPC__Product_Definition__c = pdf.id
		);
		Database.insert(product);
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(Novidea_HPC__Carrier__c = carrier.id, OwnerId = Userinfo.getUserId());

		SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
		SalesProcessHelper.testMode = true;
		ptp.product = product;
		ptp.policy = policy;
		ptp.proposal = [
			SELECT
				n.OwnerId,
				n.Novidea_HPC__Status__c,
				n.Novidea_HPC__Status_Date__c,
				n.Novidea_HPC__Request_for_Proposal__c,
				n.Novidea_HPC__Proposal_Expiration_Date__c,
				n.Novidea_HPC__Premium__c,
				n.Novidea_HPC__Premium_Currency__c,
				n.Novidea_HPC__Net_Premium__c,
				n.Novidea_HPC__Fees_del__c,
				n.Novidea_HPC__Fees_Currency__c,
				n.Novidea_HPC__Estimated_Commission__c,
				n.Novidea_HPC__Complex_Policy__c,
				n.Novidea_HPC__Commission_from_Fees__c,
				n.Novidea_HPC__Commission_Currency__c,
				n.Novidea_HPC__Commission_Amount__c,
				n.Novidea_HPC__Comment__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Calculated_Premium__c,
				n.Novidea_HPC__Calculated_Net_Premium__c,
				n.Novidea_HPC__Calculated_Fees__c,
				n.Novidea_HPC__Calculated_Commission__c,
				n.Novidea_HPC__Application__c,
				n.Novidea_HPC__Account__c,
				n.Name,
				n.Novidea_HPC__Application__r.Novidea_HPC__Account__c,
				n.Novidea_HPC__Share_Percentage__c,
				(
					SELECT
						OwnerId,
						Name,
						Novidea_HPC__Product_Definition__c,
						Novidea_HPC__Lead__c,
						Novidea_HPC__Proposal__c,
						Novidea_HPC__Status__c,
						Novidea_HPC__Status_Date__c,
						Novidea_HPC__Coverages_Created__c,
						Novidea_HPC__Application__c,
						Novidea_HPC__Premium__c,
						Novidea_HPC__Premium_Currency__c,
						Novidea_HPC__Commission__c,
						Novidea_HPC__Premium_Net__c,
						Novidea_HPC__Commission_Amount__c,
						Novidea_HPC__Commission_Currency__c,
						Novidea_HPC__Effective_Date__c,
						Novidea_HPC__Expiration_Date__c,
						Novidea_HPC__Fee_Amount__c,
						Novidea_HPC__Fee_Currency__c,
						Novidea_HPC__Liability_Limit__c,
						Novidea_HPC__Liability_Limit_Currency__c,
						Novidea_HPC__Old_Policy_Number__c,
						Novidea_HPC__Budget__c,
						Novidea_HPC__Net_Premium__c,
						Novidea_HPC__Commission_Targrt__c,
						Novidea_HPC__Calculated_Premium__c,
						Novidea_HPC__Calculated_Fees__c,
						Novidea_HPC__Calculated_Net_Premium__c,
						Novidea_HPC__Product_Type__c,
						Novidea_HPC__Expected_Renewal_Date__c,
						Novidea_HPC__Other_Commission__c,
						Novidea_HPC__Discount__c,
						Novidea_HPC__Expected_Commission_Amount__c,
						Novidea_HPC__Expected_Premium__c,
						Novidea_HPC__Expected_Fees__c,
						Novidea_HPC__Premium_Target__c,
						Novidea_HPC__Target_Agency_Fee__c,
						Novidea_HPC__Current_Agency_Fees__c,
						Novidea_HPC__Previous_Policy__c
					FROM Novidea_HPC__Products__r
				)
			FROM Novidea_HPC__Proposal__c n
			WHERE Id = :proposal.Id
			LIMIT 1
		];
		ptp.isSelected = ptp.showOverride = true;

		list<SalesProcessHelper.productToPolicy> listproductToPolicy = new List<SalesProcessHelper.productToPolicy>();
		listproductToPolicy.add(ptp);
		SalesProcessHelper.convertingProductTopolicy(listproductToPolicy, application);
		SalesProcessHelper.upsertPolicyPlanBenefits(proposal, policy);
	}

	@isTest
	private static void testUpdatesWhenCarrierIsOfTypeBrokerWithBreakDowns() {
		testUpdatesWhenCarrierIsOfTypeBroker(true);
	}

	@isTest
	private static void testUpdatesWhenCarrierIsOfTypeBrokerWithOutBreakDowns() {
		testUpdatesWhenCarrierIsOfTypeBroker(false);
	}

	private static void testUpdatesWhenCarrierIsOfTypeBroker(Boolean createBreakdowns) {
		Account carrier = new Account(Name = 'Carrier', RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Broker', 'Account'));
		Account client = new Account(Name = 'Client');
		Database.insert(new List<Account>{ carrier, client });
		Novidea_HPC__Product_Def__c prodDef = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(prodDef);
		Contact underwriter = new Contact(LastName = 'Writer');
		Database.insert(underwriter);
		Novidea_HPC__Broker_Number__c brokerNumber = new Novidea_HPC__Broker_Number__c(
			Novidea_HPC__Agency__c = carrier.id,
			Novidea_HPC__Broker_Number_In_Carrier__c = 'Test 1',
			Novidea_HPC__Carrier__c = carrier.id
		);
		Database.insert(brokerNumber);

		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(
			Name = 'gogo',
			Novidea_HPC__Required_Policy_Type__c = 'New',
			Novidea_HPC__Underwriter__c = underwriter.Id,
			Novidea_HPC__Broker_In_Carrier__c = brokerNumber.Id,
			Novidea_HPC__Account__c = client.Id
		);
		Database.insert(application);

		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = false,
			Novidea_HPC__Carrier__c = carrier.Id
		);
		Database.insert(proposal);

		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Discount__c = 20,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today().addYears(1),
			Novidea_HPC__Fee_Amount__c = 50,
			Novidea_HPC__Premium__c = 20,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Commission_Currency__c = 'ILS',
			Novidea_HPC__Commission__c = 21,
			Novidea_HPC__Product_Definition__c = prodDef.id,
			Novidea_HPC__Liability_Limit_Currency__c = 'USD',
			Novidea_HPC__Liability_Limit_Per_Case__c = 1,
			Novidea_HPC__Lower_Limit_of_Liability__c = 0,
			Novidea_HPC__Liability_Limit__c = 5000,
			Novidea_HPC__Credit_Fee__c = 10,
			Novidea_HPC__Target_Agency_Fee__c = 2,
			Novidea_HPC__Agency_Fee_Currency__c = 'USD'
		);
		Database.insert(product);

		product = [
			SELECT
				Novidea_HPC__Discount__c,
				Novidea_HPC__Application__c,
				Novidea_HPC__Proposal__c,
				Novidea_HPC__Fee_Currency__c,
				Novidea_HPC__Effective_Date__c,
				Novidea_HPC__Expiration_Date__c,
				Novidea_HPC__Fee_Amount__c,
				Novidea_HPC__Premium__c,
				Novidea_HPC__Premium_Currency__c,
				Novidea_HPC__Commission_Currency__c,
				Novidea_HPC__Commission__c,
				Novidea_HPC__Product_Definition__c,
				Novidea_HPC__Liability_Limit_Currency__c,
				Novidea_HPC__Liability_Limit_Per_Case__c,
				Novidea_HPC__Target_Agency_Fee__c,
				Novidea_HPC__Lower_Limit_of_Liability__c,
				Novidea_HPC__Liability_Limit__c,
				Novidea_HPC__Credit_Fee__c,
				Novidea_HPC__Proposal__r.Novidea_HPC__Application__c,
				Novidea_HPC__Proposal__r.Novidea_HPC__Application__r.Novidea_HPC__Account__c,
				Novidea_HPC__Agency_Fee_Currency__c,
				Novidea_HPC__Current_Agency_Fees__c
			FROM Novidea_HPC__Product__c
			WHERE Id = :product.Id
		];

		SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
		ptp.product = product;
		ptp.proposal = proposal;
		ptp.isSelected = ptp.showOverride = false;

		List<SalesProcessHelper.productToPolicy> listProductToPolicy = new List<SalesProcessHelper.productToPolicy>{ ptp };
		Integer numOfBreakdowns = 1;
		if (!createBreakdowns) {
			Novidea_HPC.TriggerUtils.disableTrigger('CreateDefaultIncomeAndBreakdown', 'SalesProcessHelper');
			numOfBreakdowns = 0;
		}
		SalesProcessHelper.convertingProductTopolicy(listProductToPolicy, application);
		Novidea_HPC__Policy__c[] policies = [SELECT Id FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Application__c = :application.Id];
		System.assertEquals(1, policies.size());

		//Ticket #3889
		Novidea_HPC__Policy_Breakdown__c[] breakdowns = [
			SELECT Id
			FROM Novidea_HPC__Policy_Breakdown__c
			WHERE Novidea_HPC__Policy__c = :policies[0].Id
		];
		System.assertEquals(numOfBreakdowns, breakdowns.size());
	}

	@isTest
	private static void testUpdatesWhenCarrierIsOfTypeAgency() {
		Account carrier = new Account(Name = 'Carrier', RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Agency', 'Account'));
		Account client = new Account(Name = 'Client');
		Database.insert(new List<Account>{ carrier, client });
		Novidea_HPC__Product_Def__c prodDef = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(prodDef);
		Contact underwriter = new Contact(LastName = 'Writer');
		Database.insert(underwriter);
		Novidea_HPC__Broker_Number__c brokerNumber = new Novidea_HPC__Broker_Number__c(
			Novidea_HPC__Agency__c = carrier.id,
			Novidea_HPC__Broker_Number_In_Carrier__c = 'Test 1',
			Novidea_HPC__Carrier__c = carrier.id,
			Novidea_HPC__Profit_Center__c = carrier.id
		);
		Database.insert(brokerNumber);

		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(
			Name = 'gogo',
			Novidea_HPC__Required_Policy_Type__c = 'New',
			Novidea_HPC__Underwriter__c = underwriter.Id,
			Novidea_HPC__Broker_In_Carrier__c = brokerNumber.Id,
			Novidea_HPC__Account__c = client.Id
		);
		Database.insert(application);

		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = false,
			Novidea_HPC__Carrier__c = carrier.Id
		);
		Database.insert(proposal);

		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Discount__c = 0,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today().addYears(1),
			Novidea_HPC__Fee_Amount__c = 0,
			Novidea_HPC__Premium__c = 200,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Commission__c = 0,
			Novidea_HPC__Product_Definition__c = prodDef.id,
			Novidea_HPC__Liability_Limit_Currency__c = 'USD',
			Novidea_HPC__Liability_Limit_Per_Case__c = 1,
			Novidea_HPC__Lower_Limit_of_Liability__c = 0,
			Novidea_HPC__Liability_Limit__c = 5000,
			Novidea_HPC__Credit_Fee__c = 10
		);
		Database.insert(product);

		product = [
			SELECT
				Novidea_HPC__Discount__c,
				Novidea_HPC__Application__c,
				Novidea_HPC__Proposal__c,
				Novidea_HPC__Fee_Currency__c,
				Novidea_HPC__Effective_Date__c,
				Novidea_HPC__Expiration_Date__c,
				Novidea_HPC__Fee_Amount__c,
				Novidea_HPC__Premium__c,
				Novidea_HPC__Premium_Currency__c,
				Novidea_HPC__Commission__c,
				Novidea_HPC__Product_Definition__c,
				Novidea_HPC__Liability_Limit_Currency__c,
				Novidea_HPC__Liability_Limit_Per_Case__c,
				Novidea_HPC__Lower_Limit_of_Liability__c,
				Novidea_HPC__Liability_Limit__c,
				Novidea_HPC__Credit_Fee__c,
				Novidea_HPC__Proposal__r.Novidea_HPC__Application__c,
				Novidea_HPC__Proposal__r.Novidea_HPC__Application__r.Novidea_HPC__Account__c
			FROM Novidea_HPC__Product__c
			WHERE Id = :product.Id
		];

		SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
		ptp.product = product;
		ptp.proposal = proposal;
		ptp.isSelected = ptp.showOverride = false;

		List<SalesProcessHelper.productToPolicy> listProductToPolicy = new List<SalesProcessHelper.productToPolicy>{ ptp };

		try {
			SalesProcessHelper.convertingProductTopolicy(listProductToPolicy, application);
			System.assert(false); //An exception is expected.
		} catch (Exception e) {
			Novidea_HPC__Policy__c[] policies = [SELECT Id FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Application__c = :application.Id];
			System.assertEquals(0, policies.size());
		}
	}

	@isTest
	private static void testAgencyFeePopulation() {
		Account carrier = new Account(Name = 'Carrier', RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Broker', 'Account'));
		Account client = new Account(Name = 'Client');
		Database.insert(new List<Account>{ carrier, client });
		Novidea_HPC__Product_Def__c prodDef = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(prodDef);
		Contact underwriter = new Contact(LastName = 'Writer');
		Database.insert(underwriter);
		Novidea_HPC__Broker_Number__c brokerNumber = new Novidea_HPC__Broker_Number__c(
			Novidea_HPC__Agency__c = carrier.id,
			Novidea_HPC__Broker_Number_In_Carrier__c = 'Test 1',
			Novidea_HPC__Carrier__c = carrier.id
		);
		Database.insert(brokerNumber);

		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(
			Name = 'gogo',
			Novidea_HPC__Required_Policy_Type__c = 'New',
			Novidea_HPC__Underwriter__c = underwriter.Id,
			Novidea_HPC__Broker_In_Carrier__c = brokerNumber.Id,
			Novidea_HPC__Account__c = client.Id
		);
		Database.insert(application);

		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = false,
			Novidea_HPC__Carrier__c = carrier.Id
		);
		Database.insert(proposal);

		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Discount__c = 20,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today().addYears(1),
			Novidea_HPC__Fee_Amount__c = 50,
			Novidea_HPC__Premium__c = 20,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Commission_Currency__c = 'ILS',
			Novidea_HPC__Commission__c = 21,
			Novidea_HPC__Product_Definition__c = prodDef.id,
			Novidea_HPC__Liability_Limit_Currency__c = 'USD',
			Novidea_HPC__Liability_Limit_Per_Case__c = 1,
			Novidea_HPC__Lower_Limit_of_Liability__c = 0,
			Novidea_HPC__Liability_Limit__c = 5000,
			Novidea_HPC__Credit_Fee__c = 10,
			Novidea_HPC__Target_Agency_Fee__c = 2,
			Novidea_HPC__Current_Agency_Fees__c = 5,
			Novidea_HPC__Agency_Fee_Currency__c = 'USD'
		);

		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(Novidea_HPC__Carrier__c = carrier.id, OwnerId = Userinfo.getUserId());

		SalesProcessHelper.productToPolicy(product, policy);

		System.assertEquals(5, policy.Novidea_HPC__Agency_Fee__c);

		product.Novidea_HPC__Current_Agency_Fees__c = null;
		SalesProcessHelper.productToPolicy(product, policy);

		System.assertEquals(2, policy.Novidea_HPC__Agency_Fee__c);

		SalesProcessHelper.getPolicyAutoName(policy, proposal);
	}

	@isTest
	private static void testCoverage() {
		SalesProcessHelper.testCoverage();
	}

	//HIB-132
	@isTest
	private static void testCommissionAndFees() {
		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);
		Novidea_HPC__Product_Def__c pdf = new Novidea_HPC__Product_Def__c(Name = 'test 1');
		Database.insert(pdf);
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(Name = 'gogo');
		Database.insert(application);
		Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
			Name = 'gogo',
			Novidea_HPC__Application__c = application.id,
			Novidea_HPC__Complex_Policy__c = false
		);
		Database.insert(proposal);
		Novidea_HPC__Agreement__c agreement = new Novidea_HPC__Agreement__c(Name = 'test');
		Database.insert(agreement);
		Novidea_HPC__Broker_Number__c broker = new Novidea_HPC__Broker_Number__c(
			Novidea_HPC__Broker_Number_In_Carrier__c = '9988563',
			Novidea_HPC__Agreement__c = agreement.id
		);
		Database.insert(broker);
		Novidea_HPC__Commission_Rate__c commRate = new Novidea_HPC__Commission_Rate__c(
			Name = 'test1',
			Novidea_HPC__Agreement__c = agreement.id,
			Novidea_HPC__Percentage__c = 45,
			Novidea_HPC__Calculation_Type__c = 'Fees And Commission Percentage From Permanent Neto Premium',
			Novidea_HPC__Product_Definition__c = pdf.id
		);
		Database.insert(commRate);
		Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(
			Novidea_HPC__Proposal__c = proposal.Id,
			Novidea_HPC__Application__c = application.Id,
			Novidea_HPC__Fee_Currency__c = 'USD',
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today(),
			Novidea_HPC__Premium__c = 2000,
			Novidea_HPC__Premium_Currency__c = 'ILS',
			Novidea_HPC__Product_Definition__c = pdf.id,
			Novidea_HPC__Broker_In_Carrier__c = broker.id
		);
		Database.insert(product);
		SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
		SalesProcessHelper.testMode = true;
		ptp.product = product;
		ptp.proposal = proposal;
		ptp.isSelected = ptp.showOverride = true;

		list<SalesProcessHelper.productToPolicy> listproductToPolicy = new List<SalesProcessHelper.productToPolicy>();
		listproductToPolicy.add(ptp);

		SalesProcessHelper.convertingProductTopolicy(listproductToPolicy, application);
		Novidea_HPC__Policy__c policy = [
			SELECT id, Novidea_HPC__Net_Premiumium__c, Novidea_HPC__Fees__c, Novidea_HPC__Premium_Amount__c
			FROM Novidea_HPC__Policy__c
		];
		Decimal result = policy.Novidea_HPC__Premium_Amount__c / (1 + commRate.Novidea_HPC__Percentage__c / 100);
		Decimal netPremiumCalculation = result.setScale(2);
		// System.assertEquals(netPremiumCalculation, policy.Novidea_HPC__Net_Premiumium__c);
		// System.assertEquals(policy.Novidea_HPC__Premium_Amount__c - netPremiumCalculation, policy.Novidea_HPC__Fees__c);
	}
}