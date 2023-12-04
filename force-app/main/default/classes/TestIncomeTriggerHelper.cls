@isTest
public class TestIncomeTriggerHelper {

    @isTest(SeeAllData=true)
	static void test0011() {
		final String ACTIVE = 'Active';
		CurrencyTriggerHelper.stopTrigger = true;

		Account accClient = TestUtils.createAccount('client:2', true);
		Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('test:01', '', true);
		Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('test:001', cat.Id, true);
		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('test:0001', null, accClient.Id, prodDef.Id, ACTIVE, true);

		Date d = Date.today();
		Date d2 = d.addYears(1);
		Date d3 = d2.addYears(1);
		Date d4 = d3.addYears(1);
		Date d5 = d4.addYears(1);
		list<Novidea_HPC__Income__c> pList = new List<Novidea_HPC__Income__c>{
			TestUtils.createIncome(policy.Id, 3, d3, d4, false),
			TestUtils.createIncome(policy.Id, 3, d4, d5, false),
			TestUtils.createIncome(policy.Id, 2, d2, d3, false),
			TestUtils.createIncome(policy.Id, 1, d, d2, false)
		};

		Database.insert(pList);

		policy = [SELECT Id, Endorsemet_Effective_Date__c FROM Novidea_HPC__Policy__c WHERE Id = :policy.Id];

		//system.assertEquals(policy.Endorsemet_Effective_Date__c, d);
	}
	/*
	 *	test of splitIncome (trigger after insert)
	 */
	@isTest(SeeAllData=true)
	//public
	static void test002() {
		final String ACTIVE = 'Active';
		final String NUM_ID = '0150';
		CurrencyTriggerHelper.stopTrigger = true;
		Account accCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID, true);

		Account incomeCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID + 1, true);

		Account accClient = TestUtils.createAccount('client:' + NUM_ID, true);
		Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('cat:' + NUM_ID, '', true);
		Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('proddef:' + NUM_ID, cat.Id, true);

		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('policy:' + NUM_ID, accCarrier.Id, accClient.Id, prodDef.Id, ACTIVE, true);

		Date d = Date.today();
		Date d2 = d.addYears(1);
		Date d3 = d2.addYears(1);
		Date d4 = d3.addYears(1);

		list<Novidea_HPC__Income__c> pList = new List<Novidea_HPC__Income__c>{
			TestUtils.createIncome(policy.Id, 0, d, d2, false),
			TestUtils.createIncome(policy.Id, 0, d2, d3, false),
			TestUtils.createIncome(policy.Id, 0, d3, d4, false),
			TestUtils.createIncome(policy.Id, 0, null, null, false)
		};
		for (Integer t = 0; t < pList.size(); t++) {
			Novidea_HPC__Income__c ic = pList[t];
			ic.Novidea_HPC__Carrier__c = accCarrier.Id;
			ic.Novidea_HPC__Income_Recognition_Date__c = d;
			d = d.addYears(1);
		}
		pList[3].Novidea_HPC__Income_Recognition_Date__c = null;
		pList[3].Novidea_HPC__Carrier__c = null;
		//system.debug('\n\n\n\n test 2 incomes income list ' + pList + '\n\n\n\n');
		Database.insert(pList);
		Set<Id> ids = new Set<Id>();
		for (Integer x = 0; x < pList.size(); x++)
			ids.add(pList[x].Id);

		//system.debug('\n\n\n\n test 2 incomes ids ' + ids + '\n\n\n\n');

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
		];

		system.assert(pList[0].Split_Income__c && !pList[1].Split_Income__c && pList[0].Split_Income__c && pList[3].Split_Income__c);
	}
	/*
	 *	test of splitIncome (trigger after update,after delete)
	 */
	@isTest(SeeAllData=true)
	//public
	static void test003() {
		final String ACTIVE = 'Active';
		final String NUM_ID = '0180';
		CurrencyTriggerHelper.stopTrigger = true;
		Account accCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID, true);
		Account incomeCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID + 1, true);

		Account accClient = TestUtils.createAccount('client:' + NUM_ID, true);
		Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('cat:' + NUM_ID, '', true);
		Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('proddef:' + NUM_ID, cat.Id, true);

		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('policy:' + NUM_ID, accCarrier.Id, accClient.Id, prodDef.Id, ACTIVE, true);

		Date d = Date.today();
		Date d2 = d.addYears(1);
		Date d3 = d2.addYears(1);
		Date d4 = d3.addYears(1);

		Integer indorsmentNumber = 1;

		list<Novidea_HPC__Income__c> pList = new List<Novidea_HPC__Income__c>{
			TestUtils.createIncome(policy.Id, indorsmentNumber, d, d2, false),
			TestUtils.createIncome(policy.Id, indorsmentNumber, d2, d3, false),
			TestUtils.createIncome(policy.Id, indorsmentNumber, d3, d4, false)
		};
		for (Integer t = 0; t < pList.size(); t++) {
			Novidea_HPC__Income__c ic = pList[t];
			ic.Novidea_HPC__Carrier__c = accCarrier.Id;
			ic.Novidea_HPC__Income_Recognition_Date__c = d;
			d = d.addYears(1);
		}

		Test.startTest();
		Database.insert(pList);
		Set<Id> ids = new Set<Id>();
		for (Integer x = 0; x < pList.size(); x++)
			ids.add(pList[x].Id);

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
		];

		system.assert(!pList[0].Split_Income__c && !pList[1].Split_Income__c && pList[2].Split_Income__c && pList[3].Split_Income__c);
		//test for update
		//	A
		pList[0].Novidea_HPC__Endorsement_Number__c = 1;
		pList[0].Novidea_HPC__Income_Recognition_Date__c = d2.addYears(-2);
		Database.update(pList[0]);

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
		];

		system.assert(!pList[0].Split_Income__c && pList[1].Split_Income__c && pList[2].Split_Income__c && pList[3].Split_Income__c);
		// B
		for (Integer x = 0; x < pList.size(); x++)
			pList[x].Novidea_HPC__Endorsement_Number__c = 0;

		Database.update(pList);

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
		];

		system.assert(!pList[0].Split_Income__c && pList[1].Split_Income__c && pList[2].Split_Income__c && pList[3].Split_Income__c);
		//test for delete
		Database.delete(new List<Id>{ pList[0].Id, pList[3].Id });

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
		];

		system.assert(!pList[0].Split_Income__c && pList[1].Split_Income__c);
	}
	/*
	 *	test for the function checkRight2IncomeChanging (trigger before update)
	 */
	@isTest(SeeAllData=true)
	//public
	static void test004() {
		CurrencyTriggerHelper.stopTrigger = true;
		Approval_Process__c apPro = Approval_Process__c.getInstance();
		apPro.Allow_Income_Edit__c = false;
		Database.upsert(apPro);

		final String ACTIVE = 'Active';
		final String NUM_ID = '0180';
		Account accCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID, true);
		//Account incomeCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID + 1, true);

		Account accClient = TestUtils.createAccount('client:' + NUM_ID, true);
		Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('cat:' + NUM_ID, '', true);
		Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('proddef:' + NUM_ID, cat.Id, true);

		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('policy:' + NUM_ID, accCarrier.Id, accClient.Id, prodDef.Id, ACTIVE, true);

		Date d = Date.today();
		Date d2 = d.addYears(1);
		Date d3 = d2.addYears(1);
		Date d4 = d3.addYears(1);

		list<Novidea_HPC__Income__c> pList = new List<Novidea_HPC__Income__c>{
			TestUtils.createIncome(policy.Id, 1, d, d2, false),
			TestUtils.createIncome(policy.Id, 2, d2, d3, false),
			TestUtils.createIncome(policy.Id, 3, d3, d4, false)
		};

		for (Integer t = 0; t < pList.size(); t++) {
			Novidea_HPC__Income__c ic = pList[t];
			ic.Novidea_HPC__Carrier__c = accCarrier.Id;
		}

		Database.insert(pList);

		policy.NOVIPROD__Endorsement_Approved__c = 1;
		Database.update(policy);

		pList = [
			SELECT
				n.Id,
				n.Novidea_HPC__Policy__c,
				n.Novidea_HPC__Endorsement_Number__c,
				n.Novidea_HPC__Carrier__c,
				n.Novidea_HPC__Income_Recognition_Date__c,
				n.Split_Income__c
			FROM Novidea_HPC__Income__c n
			WHERE n.Novidea_HPC__Policy__c = :policy.Id
			ORDER BY n.Novidea_HPC__Endorsement_Number__c
		];

		pList[0].Novidea_HPC__Carrier__c = null;
		Exception exp = null;
		try {
			Database.update(pList[0]);
		} catch (Exception e) {
			exp = e;
			system.debug('\n\n\n\n' + IncomeTriggerHelper.exceptionDump(e) + '\n\n\n\n');
		}
		//system.assertNotEquals( exp,  null );
		system.assert(exp.getMessage().containsAny(Label.no_rights_to_change_confirmed_income));

		pList[0].Novidea_HPC__Endorsement_Number__c = 2;
		exp = null;
		try {
			Database.update(pList[0]);
		} catch (Exception e) {
			exp = e;
			system.debug('\n\n\n\n' + IncomeTriggerHelper.exceptionDump(e) + '\n\n\n\n');
		}
		//system.assertNotEquals( exp,  null );
		system.assert(exp.getMessage().containsAny(Label.no_rights_to_change_confirmed_income));
		exp = null;
		try {
			Database.update(pList[2]);
		} catch (Exception e) {
			exp = e;
			system.debug('\n\n\n\n' + IncomeTriggerHelper.exceptionDump(e) + '\n\n\n\n');
		}
		system.assertEquals(exp, null);

		apPro = Approval_Process__c.getInstance();
		apPro.Allow_Income_Edit__c = true;
		Database.upsert(apPro);
		exp = null;
		Database.update(pList[0]);
		system.assertEquals(exp, null);
	}
}