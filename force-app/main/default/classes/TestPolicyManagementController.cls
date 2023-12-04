@isTest(seeAllData=false)
public class TestPolicyManagementController {
	@testSetup
	static void dataSetup() {
		Novidea_HPC__General_Switches__c settings = new Novidea_HPC__General_Switches__c(
			Name = 'Default',
			Novidea_HPC__Third_Party_Main_Income_Field_Api__c = 'Novidea_HPC__Main_Income__c'
		);
		Database.insert(settings);
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

	@isTest(seeAllData=false)
	private static void testIncomePercentege() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(
			new Novidea_HPC__Tax__c(name = 'Default', Novidea_HPC__DirectTax__c = 0, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		Novidea_HPC__Product_Def__c productDef = new Novidea_HPC__Product_Def__c(Name = 'test');
		Database.insert(productDef);

		Id rts = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account');
		Account act = new Account(RecordTypeId = rts, name = 'test', Novidea_HPC__Market_Code__c = '5322');
		Database.insert(act);

		Date expiration = (Date.today()).addDays(10);
		Id comRateRt = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Commission', 'Novidea_HPC__Commission_Rate__c');
		Novidea_HPC__Agreement__c agreement = new Novidea_HPC__Agreement__c(
			Name = 'new_agr',
			Novidea_HPC__Carrier__c = act.id,
			Novidea_HPC__Expiration_Date__c = expiration
		);
		Database.insert(agreement);

		Novidea_HPC__Commission_Rate__c comRate = new Novidea_HPC__Commission_Rate__c(
			Name = 'com_rate',
			Novidea_HPC__Product_Definition__c = productDef.id,
			Novidea_HPC__Agreement__c = agreement.id,
			Novidea_HPC__Percentage__c = 5.00,
			RecordTypeId = comRateRt
		);

		Database.insert(comRate);

		Novidea_HPC__Policy__c pol = new Novidea_HPC__Policy__c(
			Name = 'test',
			Novidea_HPC__Product_Definition__c = productDef.id,
			Novidea_HPC__Carrier__c = act.id,
			Novidea_HPC__Commission__c = 10.00,
			Novidea_HPC__Premium_Amount__c = 100
		);

		Database.insert(pol);

		Novidea_HPC.TriggerUtils.disableTrigger('DefaultCommissionUpdate', 'testIncomePercentege');
		System.assertEquals(true, !Novidea_HPC.TriggerUtils.isTriggerEnabled('DefaultCommissionUpdate'));

		PolicyManagementController policyManager = new PolicyManagementController();
		Novidea_HPC__Tax__c tax = Novidea_HPC__Tax__c.getInstance('Default');
		policyManager.policyId = pol.Id;
		policyManager.endorsement();
		System.assertEquals(1, policyManager.incomes.size());
		for (Novidea_HPC__Income__c income : policyManager.incomes) {
			System.assertEquals(comRate.Novidea_HPC__Percentage__c, income.Novidea_HPC__Commission_Percentage__c);
		}
	}

	@isTest(seeAllData=false)
	private static void testDontValidateBreakdownCommission() {
		//Init:
		Novidea_HPC__General_Switches__c settings = Novidea_HPC__General_Switches__c.getInstance('Default');
		settings.Novidea_HPC__Do_Not_Validate_Breakdown_Commissions__c = true;
		Database.update(settings);

		PolicyManagementController policyManager = new PolicyManagementController();

		System.assertEquals(true, policyManager.getDontValidateBreakdownCommission());

		settings.Novidea_HPC__Do_Not_Validate_Breakdown_Commissions__c = false;

		Database.update(settings);

		System.assertEquals(false, policyManager.getDontValidateBreakdownCommission());
	}

	@isTest(seeAllData=false)
	private static void testPolicyManagementSettings() {
		//Init:
		Policy_Management_Page__c policyManageSettings = new Policy_Management_Page__c(
			Hide_Other_Commission_Field__c = true,
			Change_Fees_Text_In_Front__c = true,
			Show_Income_Reason__c = true,
			Show_Policy_Cancellation_CheckBox__c = true,
			Add_Breakdown_TB_fields__c = true,
			Show_Policy_Agreement__c = true,
			Remove_Income_Recognition_Date__c = true,
			Lock_Endorsement_Number__c = true
		);
		Database.insert(policyManageSettings);

		PolicyManagementController policyManager = new PolicyManagementController();
		policyManager.policy = new Novidea_HPC__Policy__c(Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT);

		System.assertEquals(true, policyManager.hideOtherCommissionField);
		System.assertEquals(System.Label.Fees_In_Front, policyManager.feesLabel);
		System.assertEquals(true, policyManager.showIncomeReason);
		System.assertEquals(true, policyManager.showPolicyCancellation);
		System.assertEquals(true, policyManager.showBreakdownTB);
		System.assertEquals(true, policyManager.showAgreement);
		System.assertEquals(true, policyManager.removeIncomeRecognitionDate);
		System.assertEquals(true, policyManager.lockEndorsementNumber);

		policyManageSettings.Hide_Other_Commission_Field__c = false;
		policyManageSettings.Change_Fees_Text_In_Front__c = false;
		policyManageSettings.Show_Income_Reason__c = false;
		policyManageSettings.Show_Policy_Cancellation_CheckBox__c = false;
		policyManageSettings.Add_Breakdown_TB_fields__c = false;
		policyManageSettings.Show_Policy_Agreement__c = false;
		policyManageSettings.Remove_Income_Recognition_Date__c = false;
		policyManageSettings.Lock_Endorsement_Number__c = false;

		Database.update(policyManageSettings);

		String label = NOVU.FlatModelHelper.getFieldLabel('Novidea_HPC__Income__c', 'Novidea_HPC__Fees__c');

		PolicyManagementController updatedPolicyManager = new PolicyManagementController();

		System.assertEquals(false, updatedPolicyManager.hideOtherCommissionField);
		System.assertEquals(label, updatedPolicyManager.feesLabel);
		System.assertEquals(false, updatedPolicyManager.showIncomeReason);
		System.assertEquals(false, updatedPolicyManager.showPolicyCancellation);
		System.assertEquals(false, updatedPolicyManager.showBreakdownTB);
		System.assertEquals(false, updatedPolicyManager.showAgreement);
		System.assertEquals(false, updatedPolicyManager.removeIncomeRecognitionDate);
		System.assertEquals(false, updatedPolicyManager.lockEndorsementNumber);
	}

	@isTest(seeAllData=false)
	static void testClientUpdateInIncome() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(
			new Novidea_HPC__Tax__c(name = 'Default', Novidea_HPC__DirectTax__c = 0, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		Database.insert(new Policy_Management_Page__c());
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef);

		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier', 'Account'),
			Novidea_HPC__Market_Code__c = '5322'
		);
		Account client = new Account(Name = 'Client', RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Household', 'Account'));
		Database.insert(new List<Account>{ carrier, client });

		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.REGULAR;
		policy.Novidea_HPC__Period_Between_Payments__c = 30;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Expiration_Date__c = Date.today();
		policy.Novidea_HPC__Premium_Amount__c = policy.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Fees__c = policy.Novidea_HPC__Credit_Fee__c = 1;
		policy.Novidea_HPC__Agency_Fees_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c = 'ILS';
		policy.Novidea_HPC__Client__c = client.id;
		Database.insert(policy);
		PolicyManagementController con = new PolicyManagementController();
		con.policyId = policy.Id;
		con.setPolicyOption();
		System.assertEquals(1, con.incomes.size());
		con.endorsement();
		con.Save();
		List<Novidea_HPC__Income__c> updatedIncomes = [
			SELECT Novidea_HPC__Client__c
			FROM Novidea_HPC__Income__c
			WHERE Novidea_HPC__Policy__c = :policy.Id
		];
		System.assertEquals(2, updatedIncomes.size());
		System.assertEquals(policy.Novidea_HPC__Client__c, updatedIncomes[1].Novidea_HPC__Client__c);
	}

	@isTest(seeAllData=false)
	static void testApprovedProposalCO_Nulls() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(new Novidea_HPC__Trigger__c(Novidea_HPC__Prevent_Running__c = true));
		Database.insert(
			new Novidea_HPC__Tax__c(name = 'Default', Novidea_HPC__DirectTax__c = 0, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef);

		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Carrier' AND isActive = TRUE LIMIT 1]
			.Id,
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);

		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		policy.Novidea_HPC__Period_Between_Payments__c = 30;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Expiration_Date__c = Date.today();
		policy.Novidea_HPC__Premium_Amount__c = policy.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Fees__c = policy.Novidea_HPC__Credit_Fee__c = 1;
		policy.Novidea_HPC__Agency_Fees_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c = 'ILS';

		Database.insert(policy);
		PolicyManagementController con = new PolicyManagementController();
		con.policyId = policy.Id;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 1;
		con.Save();
		Database.insert(
			new List<Novidea_HPC__Income__c>{
				new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id, Novidea_HPC__Endorsement_Number__c = -2),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Carrier__c = carrier.Id
				),
				new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id, Novidea_HPC__Endorsement_Number__c = 3),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id
				)
			}
		);
		con = new PolicyManagementController();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		Database.update(policy);
		con.policyId = policy.Id;
		con.setPolicyOption();
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.Save();
		con.policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.setPolicyOption();
		con.Save();
		con.removeLine();
		con.exitPage();
		con.cancellation();
		con.endorsement();
		con.cleanData();
		System.debug(con.paymentOptions);

		con = new PolicyManagementController();
		con.policyId = policy.Id;
	}

	@isTest(seeAllData=false)
	static void testApprovedProposalCO() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(new Novidea_HPC__Trigger__c(Novidea_HPC__Prevent_Running__c = true));
		Database.Insert(
			new Novidea_HPC__Tax__c(Name = 'Default', Novidea_HPC__DirectTax__c = 17, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef);

		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Carrier' AND isActive = TRUE LIMIT 1]
			.Id,
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);

		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		policy.Novidea_HPC__Period_Between_Payments__c = 30;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Expiration_Date__c = Date.today();
		policy.Novidea_HPC__Premium_Amount__c = policy.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Fees__c = policy.Novidea_HPC__Credit_Fee__c = 1;
		policy.Novidea_HPC__Agency_Fees_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c = 'ILS';

		Database.insert(policy);
		PolicyManagementController con = new PolicyManagementController();
		con.policyId = policy.Id;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 1;
		con.Save();
		Database.insert(
			new List<Novidea_HPC__Income__c>{
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Carrier__c = carrier.Id
				),
				new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id, Novidea_HPC__Endorsement_Number__c = 3),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				)
			}
		);
		con = new PolicyManagementController();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		Database.update(policy);
		con.policyId = policy.Id;
		con.setPolicyOption();
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.Save();
		con.policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.setPolicyOption();
		con.Save();
		con.removeLine();
		con.exitPage();
		con.cancellation();
		con.endorsement();
		con.cleanData();
		System.debug(con.paymentOptions);
		Test.startTest();
		con.incomes[0].Novidea_HPC__Fees__c = 30;
		con.incomes[1].Novidea_HPC__Agent_Discount__c = 10;
		con.incomes[1].Novidea_HPC__Tax_On_Premium__c = 15;
		con.Save();
		System.assertEquals(30, con.incomes[0].Novidea_HPC__Fees__c);
		System.assertEquals(10, con.incomes[1].Novidea_HPC__Agent_Discount__c);
		System.assertEquals(15, con.incomes[1].Novidea_HPC__Tax_On_Premium__c);

		con.policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		con.setPolicyOption();
		con.Save();
		Test.stopTest();

		con = new PolicyManagementController();
		con.policyId = policy.Id;
	}

	@isTest(seeAllData=false)
	static void testApprovedProposalCO2() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(new Novidea_HPC__Trigger__c(Novidea_HPC__Prevent_Running__c = true));
		Database.Insert(
			new Novidea_HPC__Tax__c(Name = 'Default', Novidea_HPC__DirectTax__c = 17, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef);

		Account carrier = new Account(
			Name = 'Carrier',
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Carrier' AND isActive = TRUE LIMIT 1]
			.Id,
			Novidea_HPC__Market_Code__c = '5322'
		);
		Database.insert(carrier);

		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		policy.Novidea_HPC__Period_Between_Payments__c = 30;
		policy.Novidea_HPC__Product_Definition__c = proDef.Id;
		policy.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Expiration_Date__c = Date.today();
		policy.Novidea_HPC__Premium_Amount__c = policy.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Fees__c = policy.Novidea_HPC__Credit_Fee__c = 1;
		policy.Novidea_HPC__Agency_Fees_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c = 'ILS';

		Database.insert(policy);
		PolicyManagementController con = new PolicyManagementController();
		con.policyId = policy.Id;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 1;
		con.Save();
		Database.insert(
			new List<Novidea_HPC__Income__c>{
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0,
					Novidea_HPC__Bordero_Date__c = Date.today()
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Bordero_Date__c = Date.today()
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Bordero_Date__c = Date.today()
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0,
					Novidea_HPC__Bordero_Date__c = Date.today()
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0,
					Novidea_HPC__Bordero_Date__c = Date.today()
				)
			}
		);
		con = new PolicyManagementController();
		policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		Database.update(policy);
		con.policyId = policy.Id;
		con.setPolicyOption();
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.Save();
		con.policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT;
		con.incomes[0].Novidea_HPC__Commission_Percentage__c = 0;
		con.setPolicyOption();
		con.Save();
		con.removeLine();
		con.exitPage();
		con.cancellation();
		con.endorsement();
		con.cleanData();
		System.debug(con.paymentOptions);

		con.policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
		con.setPolicyOption();
		con.currentEndorement = con.maxEndorsement;
		con.Save();
	}

	@isTest(seeAllData=false)
	static void testgetTotalIncomeForCarrier() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(new Novidea_HPC__Trigger__c(Novidea_HPC__Prevent_Running__c = true));
		Database.Insert(
			new Novidea_HPC__Tax__c(Name = 'Default', Novidea_HPC__DirectTax__c = 17, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);
		PolicyManagementControllerTester con = new PolicyManagementControllerTester();
		con.checkGetTotalIncomeForCarrier();
	}

	@isTest(seeAllData=false)
	private static void testEnhancedPolicyManagement() {
		CurrencyTriggerHelper.stopTrigger = true;
		PolicyTriggerHelperHowden.stopTrigger = true;
		Database.insert(
			new Novidea_HPC__Tax__c(name = 'Default', Novidea_HPC__DirectTax__c = 0, Novidea_HPC__FrontTax__c = 0, Novidea_HPC__LocalTax__c = 0)
		);

		Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
		Database.insert(proDef);

		Account client = new Account(Name = 'Client', RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Household', 'Account'));
		Database.insert(client);

		PolicyManagementController con = new PolicyManagementController();
		Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c(
			Novidea_HPC__Insurance_Type__c = PolicyManagementController.REGULAR,
			RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Parent_Policy', 'Novidea_HPC__Policy__c'),
			Novidea_HPC__Product_Definition__c = proDef.Id,
			Novidea_HPC__Effective_Date__c = Date.today(),
			Novidea_HPC__Expiration_Date__c = Date.today(),
			Novidea_HPC__Client__c = client.id,
			Insurance_Bank__c = 20,
			Tariff__c = 5,
			Fee_Percentage__c = 3
		);
		Database.insert(policy);

		con.policyId = policy.Id;
		System.assertEquals(true, con.shouldShowEnhancedPolicyManagementPage);
		System.assertEquals(20, con.insuranceBankValue);
		System.assertEquals(5, con.tariffValue);
		System.assertEquals(3, con.feePercentageValue);
		System.assertEquals(0, con.agencyFeePercentageValue);

		con.insuranceBankValue = 50;
		con.agencyFeePercentageValue = 8;

		con.setPolicyOption();
		con.endorsement();
		con.Save();

		System.assertEquals(50, con.insuranceBankValue);
		System.assertEquals(5, con.tariffValue);
		System.assertEquals(3, con.feePercentageValue);
		System.assertEquals(8, con.agencyFeePercentageValue);

		List<Novidea_HPC__Income__c> updatedIncomes = [
			SELECT
				Novidea_HPC__Client__c,
				Novidea_HPC__Effective_Date__c,
				Insurance_Bank__c,
				Tariff__c,
				Fee_Percentage__c,
				Agency_Fee_Percentage__c,
				Extra_Extension__c
			FROM Novidea_HPC__Income__c
			WHERE Novidea_HPC__Policy__c = :policy.Id
		];
		System.assertEquals(2, updatedIncomes.size());
		System.assertEquals(policy.Novidea_HPC__Client__c, updatedIncomes[1].Novidea_HPC__Client__c);
		System.assertEquals(policy.Novidea_HPC__Effective_Date__c, updatedIncomes[1].Novidea_HPC__Effective_Date__c);
		System.assertEquals(50, updatedIncomes[1].Insurance_Bank__c);
		System.assertEquals(5, updatedIncomes[1].Tariff__c);
		System.assertEquals(3, updatedIncomes[1].Fee_Percentage__c);
		System.assertEquals(8, updatedIncomes[1].Agency_Fee_Percentage__c);
	}

	@isTest(seeAllData=false)
	private static void testPerformException() {
		try {
			throw new TestPolicyManagementControllerException('Test perform exception');
		} catch (TestPolicyManagementControllerException ex) {
			ConstructorPoliciesUtils.performException(ex);
		}
	}

	private class TestPolicyManagementControllerException extends Exception {
	}

	private class PolicyManagementControllerTester extends PolicyManagementController {
		public void checkGetTotalIncomeForCarrier() {
			Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
			Database.insert(proDef);

			Account carrier = new Account(
				Name = 'Carrier',
				RecordTypeId = [
					SELECT Id
					FROM RecordType
					WHERE sObjectType = 'Account' AND DeveloperName = 'Carrier' AND isActive = TRUE
					LIMIT 1
				]
				.Id,
				Novidea_HPC__Market_Code__c = '5322'
			);
			Database.insert(carrier);

			Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c();
			policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.Direct;
			policy.Novidea_HPC__Period_Between_Payments__c = 30;
			policy.Novidea_HPC__Product_Definition__c = proDef.Id;
			policy.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Expiration_Date__c = Date.today();
			policy.Novidea_HPC__Premium_Amount__c = policy.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Fees__c = policy.Novidea_HPC__Credit_Fee__c = 1;
			policy.Novidea_HPC__Agency_Fees_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c = 'ILS';

			Database.insert(policy);
			incomes = new List<Novidea_HPC__Income__c>{
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = -2,
					Novidea_HPC__Carrier__c = carrier.Id
				),
				new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id, Novidea_HPC__Endorsement_Number__c = 3),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				),
				new Novidea_HPC__Income__c(
					Novidea_HPC__Policy__c = policy.Id,
					Novidea_HPC__Endorsement_Number__c = 3,
					Novidea_HPC__Carrier__c = carrier.Id,
					Novidea_HPC__Agent_Discount__c = 0,
					Novidea_HPC__Commission_Amount__c = 0,
					Novidea_HPC__Commission_Percentage__c = 0,
					Novidea_HPC__Premium__c = 0,
					Novidea_HPC__Credit_Fees__c = 0,
					Novidea_HPC__Other_Commission__c = 0,
					Novidea_HPC__Underwriter_Commission__c = 0
				)
			};
			Database.insert(incomes);
			getTotalIncomeForCarrier(incomes[0], 1, incomes[2], incomes[3], incomes[0]);
		}
	}
}