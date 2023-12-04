public class IncomeTriggerHelper {
	public class NoRightIncomeChangingException extends Exception {
		public NoRightIncomeChangingException(Novidea_HPC__Income__c income, Novidea_HPC__Policy__c policy) {
			String msg = Label.no_rights_to_change_confirmed_income;
			this.setMessage(msg.replace('{0}', income.Name).replace('{1}', policy.Name)); //.replace('{2}', policy.Novidea_HPC__Client__r.Name));
		}
	}

	public static boolean stopTrigger = false;

	/*
		raniz 06/11/2012:
		Partial Copy from IncomeTriggerHelper, to cover the case where the commision amount is not available for currency update
	*/
	public static void updateCommissions(list<Novidea_HPC__Income__c> newIncomes) {
		for (Novidea_HPC__Income__c income : newIncomes) {
			income.PolicyId__c = income.Novidea_HPC__Policy__c;
			Double brutoPremium = income.Novidea_HPC__Premium__c, brutoPremiumProduction = income.Novidea_HPC__Premium_From_Production__c;

			if (
				(income.Novidea_HPC__Commission_Amount__c == null ||
				income.Novidea_HPC__Commission_Amount__c == 0) &&
				income.Novidea_HPC__Commission_Percentage__c != null &&
				brutoPremium != null &&
				brutoPremium != 0
			) {
				income.Novidea_HPC__Commission_Amount__c = income.Novidea_HPC__Commission_Percentage__c / 100.0 * brutoPremium;
			}

			if (
				(income.Novidea_HPC__Commission_Amount_from_Production__c == null ||
				income.Novidea_HPC__Commission_Amount_from_Production__c == 0) &&
				income.Novidea_HPC__Commission_From_Production__c != null &&
				brutoPremiumProduction != null &&
				brutoPremiumProduction != 0
			) {
				income.Novidea_HPC__Commission_Amount_from_Production__c =
					income.Novidea_HPC__Commission_From_Production__c /
					100.0 *
					brutoPremiumProduction;
			}
		}
	}

	/*
	 *  The function checks whether the user has rights to modify approved income.
	 *	newIncomeList 	: list of modified incomes
	 *	id2incomeOld  	: map  of incomes before modifying
	 *	isAllowed  		: flag - whether the user has rights to modify approved income.
	 */
	public static void checkRight2IncomeChanging(
		list<Novidea_HPC__Income__c> newIncomeList,
		map<Id, Novidea_HPC__Income__c> id2incomeOld,
		Boolean isAllowed
	) {
		if (stopTrigger)
			return;

		set<Id> policyIds = new Set<Id>();
		for (Novidea_HPC__Income__c income : newIncomeList)
			policyIds.add(income.Novidea_HPC__Policy__c);

		//Boolean isAllowed = (triggerSetting != null) ? triggerSetting.Confirmed_Income_Changed__c : Novidea_HPC__Trigger__c.getInstance().Confirmed_Income_Changed__c;

		map<Id, Novidea_HPC__Policy__c> id2Policy = initId2Policy(policyIds);

		for (Novidea_HPC__Income__c income : newIncomeList) {
			Novidea_HPC__Policy__c policy = id2Policy.get(income.Novidea_HPC__Policy__c);
			Novidea_HPC__Income__c oldIncome = id2incomeOld.get(income.Id);
			Decimal endorsementApproved = policy.NOVIPROD__Endorsement_Approved__c;
			if (
				(income.Novidea_HPC__Endorsement_Number__c <= endorsementApproved ||
				oldIncome.Novidea_HPC__Endorsement_Number__c <= endorsementApproved) && !isAllowed
			) {
				throw new NoRightIncomeChangingException(income, policy);
			}
		}
	}

	/*
	 * 	The function sets the flag (Split_Income__c) in Income, depending on a Income belong to a sequence.
	 *	If that is the case, the flag will be set to 'true'.
	 *	If the Income is the head of a sequence, the flag will be set to false.
	 *	Accessory of a Income to a sequence determineds by three parameters :
	 *	Policy Id (Novidea_HPC__Policy__c), Carrier Id (Novidea_HPC__Carrier__c), Endorsement Number (Endorsement_Number__c)
	 *	<Params>
	 *	newIncomeList: list of inserted or updated or deleted incomes
	 *	oldIncomeMap : map  of incomes before modifying
	 */
	public static void splitIncome(list<Novidea_HPC__Income__c> newIncomeList, map<Id, Novidea_HPC__Income__c> oldIncomeMap) {
		if (stopTrigger)
			return;
		//Preparation for processing: request of necessary data from CRM , etc
		IncomeSplitter splitter = new IncomeSplitter(newIncomeList, oldIncomeMap);
		//processing : setting of flags(Split_Income__c) in list of incomes
		splitter.updateSplitIncome();
	}
	/*
	 *	the function updates Endorsemet Effective Date of policy depends on effective date of last entered Income.
	 *	policyIds 	: set of ID's polisies that belong to the list of icomes (incomeList).
	 *	incomeList 	: list of inserted or updated incomes
	 */
	public static void updateEndorsemetEffectiveDateInPolicy(set<Id> policyIds, list<Novidea_HPC__Income__c> incomeList) {
		if (stopTrigger)
			return;

		map<Id, Novidea_HPC__Policy__c> id2Policy = initId2Policy(policyIds);

		list<Novidea_HPC__Policy__c> policiesToUpdate = new List<Novidea_HPC__Policy__c>();
		map<Id, Decimal> policyId2EndorsementNumber = new Map<Id, Decimal>();

		for (Novidea_HPC__Income__c income : incomeList) {
			Novidea_HPC__Policy__c policy = id2Policy.get(income.Novidea_HPC__Policy__c);
			if (policy == null) {
				continue;
			}
			if (
				(income.Novidea_HPC__Endorsement_Number__c != null &&
				policy.Novidea_HPC__Endorsement_Number__c <= income.Novidea_HPC__Endorsement_Number__c) &&
				(policy.Endorsemet_Effective_Date__c == null ||
				(//policy.Endorsemet_Effective_Date__c != null
				income.Novidea_HPC__Effective_Date__c != null &&
				!policy.Endorsemet_Effective_Date__c.isSameDay(income.Novidea_HPC__Effective_Date__c)))
			) {
				//Case: few Incomes have been at the same time entered  that belong to same Policy
				if (
					policyId2EndorsementNumber.containsKey(policy.Id) &&
					policyId2EndorsementNumber.get(policy.Id) <= income.Novidea_HPC__Endorsement_Number__c
				) {
					policy.Endorsemet_Effective_Date__c = income.Novidea_HPC__Effective_Date__c;
					policyId2EndorsementNumber.put(policy.Id, income.Novidea_HPC__Endorsement_Number__c);
				} else {
					policy.Endorsemet_Effective_Date__c = income.Novidea_HPC__Effective_Date__c;
					if (!policyId2EndorsementNumber.containsKey(policy.Id))
						policiesToUpdate.add(policy);
					policyId2EndorsementNumber.put(policy.Id, income.Novidea_HPC__Endorsement_Number__c);
				}
			}
		}

		Boolean stopTrigger0 = PolicyTriggerHelper.stopTrigger;
		PolicyTriggerHelper.stopTrigger = true;
		Boolean stopTrigger2 = CurrencyTriggerHelper.stopTrigger;
		CurrencyTriggerHelper.stopTrigger = true;
		Boolean stopTrigger4 = stopTrigger;
		stopTrigger = true;

		if (!policiesToUpdate.isEmpty()) {
			Database.update(policiesToUpdate);
		}

		PolicyTriggerHelper.stopTrigger = stopTrigger0;
		CurrencyTriggerHelper.stopTrigger = stopTrigger2;
		stopTrigger = stopTrigger4;
	}

	static map<Id, Novidea_HPC__Policy__c> initId2Policy(set<Id> policyIds) {
		map<Id, Novidea_HPC__Policy__c> id2Policy = new Map<Id, Novidea_HPC__Policy__c>(
			[
				SELECT
					Id,
					Name,
					//Novidea_HPC__Client__r.Name,
					Novidea_HPC__Endorsement_Number__c,
					Endorsemet_Effective_Date__c,
					NOVIPROD__Endorsement_Approved__c
				FROM Novidea_HPC__Policy__c
				WHERE Id IN :policyIds
			]
		);
		return id2Policy;
	}

	class IncomeSplitter {
		private list<Novidea_HPC__Income__c> incomesToPerform;

		private map<string, Date> key2DateMin;
		private map<string, list<Novidea_HPC__Income__c>> key2IncomeAll;

		private string makeKey(Novidea_HPC__Income__c income) {
			return income.Novidea_HPC__Policy__c + string.valueOf(income.Novidea_HPC__Endorsement_Number__c) + income.Novidea_HPC__Carrier__c;
		}

		public IncomeSplitter(list<Novidea_HPC__Income__c> newIncomeList, map<Id, Novidea_HPC__Income__c> oldIncomeMap) {
			init(newIncomeList, oldIncomeMap);
		}

		private void init(list<Novidea_HPC__Income__c> newIncomeList, map<Id, Novidea_HPC__Income__c> oldIncomeMap) {
			this.incomesToPerform = newIncomeList.clone();
			Set<Id> policiesIds = new Set<Id>();

			for (Novidea_HPC__Income__c ic : newIncomeList) {
				policiesIds.add(ic.Novidea_HPC__Policy__c);
				Novidea_HPC__Income__c old = oldIncomeMap.get(ic.Id);
				//case : if id of policy in income have been changed
				if (ic.Novidea_HPC__Policy__c != old.Novidea_HPC__Policy__c)
					policiesIds.add(old.Novidea_HPC__Policy__c);
				//case : if id of policy or id of carrier or endorsement number have been changed
				if (makeKey(ic) != makeKey(old))
					this.incomesToPerform.add(old);
			}

			list<Novidea_HPC__Income__c> existIncomeList = [
				SELECT
					n.Id,
					n.Novidea_HPC__Policy__c,
					n.Novidea_HPC__Endorsement_Number__c,
					n.Novidea_HPC__Carrier__c,
					n.Novidea_HPC__Income_Recognition_Date__c,
					n.Split_Income__c
				FROM Novidea_HPC__Income__c n
				WHERE n.Novidea_HPC__Policy__c IN :policiesIds
			];

			// Creating list of realated incomes.
			key2IncomeAll = new Map<string, list<Novidea_HPC__Income__c>>();
			for (Novidea_HPC__Income__c income : existIncomeList) {
				string key = makeKey(income);
				if (key2IncomeAll.containsKey(key)) {
					list<Novidea_HPC__Income__c> exlist = key2IncomeAll.get(key);
					exlist.add(income);
				} else {
					list<Novidea_HPC__Income__c> exlist = new List<Novidea_HPC__Income__c>();
					exlist.add(income);
					key2IncomeAll.put(key, exlist);
				}
			}

			// For each list of related incomes find the minimum date and put it in a map ordered by the key of those incomes.
			this.key2DateMin = new Map<string, Date>();
			for (string key : this.key2IncomeAll.keySet()) {
				Date start = date.newInstance(2100, 1, 1);
				Date min = date.newInstance(2100, 1, 1);
				for (Novidea_HPC__Income__c income : this.key2IncomeAll.get(key)) {
					if (
						income.Novidea_HPC__Income_Recognition_Date__c != null &&
						min.daysBetween(income.Novidea_HPC__Income_Recognition_Date__c) < 0
					)
						min = income.Novidea_HPC__Income_Recognition_Date__c;
				}
				min = !min.isSameDay(start) ? min : null;
				this.key2DateMin.put(key, min);
			}
		}

		private void updateSplitIncome() {
			list<Novidea_HPC__Income__c> updatedList = new List<Novidea_HPC__Income__c>();
			for (Novidea_HPC__Income__c income : this.incomesToPerform) {
				string key = makeKey(income);
				Date min = (Date) this.key2DateMin.get(key);
				//updating for exist incomes
				list<Novidea_HPC__Income__c> incomeList4key = this.key2IncomeAll.get(key);

				if (incomeList4key == null)
					continue;

				//if exist  only one income for the key.
				for (Novidea_HPC__Income__c exist : incomeList4key) {
					Boolean valueBefore = exist.Split_Income__c;
					if (incomeList4key.size() == 1) {
						exist.Split_Income__c = false;
					} else
						exist.Split_Income__c =
							exist.Novidea_HPC__Income_Recognition_Date__c == null ||
							!min.isSameDay(exist.Novidea_HPC__Income_Recognition_Date__c);

					if (exist.Split_Income__c != valueBefore)
						updatedList.add(exist);
				}
			}
			boolean stopTrigger0 = CurrencyTriggerHelper.stopTrigger;
			CurrencyTriggerHelper.stopTrigger = true;
			Boolean stopTrigger2 = PolicyTriggerHelper.stopTrigger;
			PolicyTriggerHelper.stopTrigger = true;
			Boolean stopTrigger4 = stopTrigger;
			stopTrigger = true;
			//debug
			//dumpIncamList(updatedList, 'before upadte updatedList');

			Database.update(updatedList);

			CurrencyTriggerHelper.stopTrigger = stopTrigger0;
			PolicyTriggerHelper.stopTrigger = stopTrigger2;
			stopTrigger = stopTrigger4;
		}
	} //end of class IncomeSplitter

	/*
    	Test for function updateEndorsemetEffectiveDateInPolicy (trigger after update)
    */
	/*
    @isTest(SeeAllData=true)
    //public
    static void test001() {
    	final String ACTIVE = 'Active';
    	CurrencyTriggerHelper.stopTrigger = true;
		Account accClient =  TestUtils.createAccount('client:2', true);
		Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('test:01', '', true);
		Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('test:001', cat.Id, true);
		Novidea_HPC__Policy__c policy = TestUtils.createPolicy('test:0001', null, accClient.Id, prodDef.Id, ACTIVE, true);
		//raniz change 23/12/2012: canceled trigger also within package. Otherwise a confirm coverage process created 2 new renewal apps with 2 new prods.
        Novidea_HPC__Trigger__c pkgInst  = Novidea_HPC__Trigger__c.getInstance();
        Boolean  pkgSt = pkgInst.Novidea_HPC__Prevent_Policy_Running__c;
        pkgInst.Novidea_HPC__Prevent_Policy_Running__c = true;
        Database.update(pkgInst);
		Date d = Date.today();
		Date d2 = d.addYears(1);
		TestUtils.createIncome(policy.Id, 0, d, d2, true);
		policy = [SELECT Id, Endorsemet_Effective_Date__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
		
		system.assertEquals(policy.Endorsemet_Effective_Date__c, d);
			
		Date d3 = d2.addYears(1);
		Novidea_HPC__Income__c icm = TestUtils.createIncome(policy.Id, 1, d2, d3, true);
		policy = [SELECT Id, Endorsemet_Effective_Date__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
		system.assertEquals(policy.Endorsemet_Effective_Date__c, d2);
		
		Date d4 = d2.addMonths(1);
		icm.Novidea_HPC__Effective_Date__c = d4;
		Database.update(icm);
		
		policy = [SELECT Id, Endorsemet_Effective_Date__c FROM Novidea_HPC__Policy__c WHERE Id =: policy.Id];
		system.assertEquals(policy.Endorsemet_Effective_Date__c, d4);	
		
		Novidea_HPC__Income__c inc2 =  TestUtils.createIncome(policy.Id, 2, d, null, true);
		Novidea_HPC__Income__c inc3 = TestUtils.createIncome(policy.Id, 3, null, d2, true);
		TestUtils.createIncome(policy.Id, 3, null, null , true);
        pkgInst.Novidea_HPC__Prevent_Policy_Running__c = false;
        Database.update(pkgInst);
    }*/
	
	/*
    static String incomeToString(Novidea_HPC__Income__c income) {
    	return 'Id : '+ income.Id + ' Split Income : ' + income.Split_Income__c + ' Endorsement : ' + income.Novidea_HPC__Endorsement_Number__c + ' Carrier : ' + income.Novidea_HPC__Carrier__c + ' RecognitionDate ' + income.Novidea_HPC__Income_Recognition_Date__c;
    }
    
    static void dumpIncamList(list<Novidea_HPC__Income__c> pList) {
    	String dump = '';      		 
        for( Integer x=0;x < pList.size(); x++ ) 
       		dump += incomeToString(pList[x]) + '\n';
       
        system.debug('\n\n\n\n RESULT >> \n' + dump + '\n\n\n\n');
    }
    
    static void dumpIncamList(list<Novidea_HPC__Income__c> pList, String msg) {
    	String dump = '';      		 
        for( Integer x=0;x < pList.size(); x++ ) 
       		dump += incomeToString(pList[x]) + '\n';
       
        String str = '\n\n\n\n' + msg +' >> \n' + dump + '\n\n\n\n';
        system.debug(str);
    }*/

	public static string exceptionDump(Exception exp) {
		return ' line number : ' +
			exp.getLineNumber() +
			'\n stack : ' +
			exp.getStackTraceString() +
			'\n message :' +
			exp.getMessage() +
			'\n type :' +
			exp.getTypeName();
	}
}