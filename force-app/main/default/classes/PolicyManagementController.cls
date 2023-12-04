// Code copied from HPC package version 1.182
public virtual with sharing class PolicyManagementController {
	public static final String REGULAR = 'Local';
	public static final String DIRECT = 'Direct';
	public static final String FRONT = 'Front';

	public class PolicyBreakdownWrapper {
		public Novidea_HPC__Policy_Breakdown__c breakdown { get; set; }
		public Integer id { get; set; }
		public String carrierName { get; set; }
		public PolicyBreakdownWrapper(Novidea_HPC__Policy_Breakdown__c breakdown, Integer id) {
			this.breakdown = breakdown;
			this.carrierName = breakdown.Novidea_HPC__Carrier__r.Name;
			breakdown.Name = breakdown.Novidea_HPC__Carrier__r.Name;
			this.id = id;
		}
	}

	public String filterId { get; set; }
	public Boolean advancedMode { get; set; } //AEF:
	public Boolean cancelPolicy { get; set; }
	public Integer lineToRemove { get; set; }
	public String incomeReason { get; set; }
	private Boolean dontValidateBreakdownCommission;
	public Boolean hideOtherCommissionField {
		get {
			if (policyManage != null) {
				return policyManage.Hide_Other_Commission_Field__c == null ? false : policyManage.Hide_Other_Commission_Field__c;
			}

			return false;
		}
	}
	public String feesLabel {
		get {
			String label = NOVU.FlatModelHelper.getFieldLabel('Novidea_HPC__Income__c', 'Novidea_HPC__Fees__c');
			if (policyManage != null) {
				Boolean checkCustomLabel = policyManage.Change_Fees_Text_In_Front__c == null ? false : policyManage.Change_Fees_Text_In_Front__c;
				if (checkCustomLabel && policy != null && policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT) {
					label = System.Label.Fees_In_Front;
				}
			}
			return label;
		}
	}
	public Boolean showIncomeReason {
		get {
			if (policyManage != null) {
				return policyManage.Show_Income_Reason__c == null ? false : policyManage.Show_Income_Reason__c;
			}
			return false;
		}
	}
	public Boolean showPolicyCancellation {
		get {
			if (policyManage != null) {
				return policyManage.Show_Policy_Cancellation_CheckBox__c == null ? false : policyManage.Show_Policy_Cancellation_CheckBox__c;
			}
			return false;
		}
	}
	public Boolean showBreakdownTB {
		get {
			if (policyManage != null) {
				return policyManage.Add_Breakdown_TB_fields__c == null ? false : policyManage.Add_Breakdown_TB_fields__c;
			}
			return false;
		}
	}
	public Boolean showAgreement {
		get {
			return showAgreement == null
				? (policyManage?.Show_Policy_Agreement__c != null ? policyManage.Show_Policy_Agreement__c : false)
				: showAgreement;
		}
		private set;
	}
	public Boolean removeIncomeRecognitionDate {
		get {
			if (policyManage != null) {
				return policyManage.Remove_Income_Recognition_Date__c == null ? false : policyManage.Remove_Income_Recognition_Date__c;
			}
			return false;
		}
	}
	public Boolean lockEndorsementNumber {
		get {
			if (policyManage != null) {
				return policyManage.Lock_Endorsement_Number__c == null ? false : policyManage.Lock_Endorsement_Number__c;
			}
			return false;
		}
	}

	public List<PolicyBreakdownWrapper> breakdowns { get; set; }
	public List<Novidea_HPC__Income__c> incomes { get; set; }
	public Map<Id, String> carrierIdToName { get; set; }
	public Novidea_HPC__Income__c agencyFees { get; set; }
	public List<SelectOption> paymentOptions {
		get {
			List<SelectOption> paymentOptions = new List<SelectOption>{
				new SelectOption('30', '30'),
				new SelectOption('60', '60'),
				new SelectOption('90', '90'),
				new SelectOption('120', '120')
			};
			if (policy.Novidea_HPC__Period_Between_Payments__c == null)
				policy.Novidea_HPC__Period_Between_Payments__c = 30;
			return paymentOptions;
		}
	}

	public List<SelectOption> incomeReasonOptions {
		get {
			List<SelectOption> incomeReasonOptions = new List<SelectOption>();

			List<NOVU.Structures.ValueLabelPair> pickListPairs = NOVU.FlatModelHelper.getPickListData(
				'Novidea_HPC__Income__c',
				'Novidea_HPC__Income_Reason__c'
			);

			if (!pickListPairs.isEmpty()) {
				for (integer i = 0; i < pickListPairs.size(); i++) {
					incomeReasonOptions.add(new SelectOption(pickListPairs[i].value, pickListPairs[i].label));
				}
			}
			return incomeReasonOptions;
		}
	}

	public Boolean getDontValidateBreakdownCommission() {
		Novidea_HPC__General_Switches__c settings = Novidea_HPC__General_Switches__c.getInstance('Default');
		if (settings != null) {
			return settings.Novidea_HPC__Do_Not_Validate_Breakdown_Commissions__c == null
				? false
				: settings.Novidea_HPC__Do_Not_Validate_Breakdown_Commissions__c;
		}

		return false;
	}

	public void setPolicyOption() {
		if (policyOption != policy.Novidea_HPC__Insurance_Type__c) {
			// Insurance Type was changed
			if (policyOption == PolicyManagementController.FRONT) {
				// it was FRONT so remove excessive income
				while (incomes.size() > 1) {
					Novidea_HPC__Income__c income = incomes.remove(0);
					if (income.Id != null)
						incomesForDeletion.add(income);
				}
				changedToFront = false;
			}
			if (policy.Novidea_HPC__Insurance_Type__c != PolicyManagementController.REGULAR) {
				// changed to something other than 'Local'
				if (this.isFromConversion && incomes[0].Novidea_HPC__Carrier__c != null) {
					breakdowns[0].carrierName = breakdowns[0].breakdown.Novidea_HPC__Carrier__c = null;
				}
				if (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT) {
					// changed to FRONT so add another income
					updateIncomeListForFront();
				}
			}
			policyOption = policy.Novidea_HPC__Insurance_Type__c;
			setPremiumTax(true);
		}
	}

	/** AEF:
	 * The function sets tax rate dependent on insurance type
	 * oldValueChanged : a flag - whether the existing value of tax rate would be changed
	 **/
	public void setPremiumTax(Boolean oldValueChanged) {
		Novidea_HPC__Tax__c tax = Novidea_HPC__Tax__c.getInstance('Default');
		Decimal newTaxValue = 0.0;
		if (policyOption == PolicyManagementController.REGULAR)
			newTaxValue = tax.Novidea_HPC__LocalTax__c;
		else if (policyOption == PolicyManagementController.FRONT)
			newTaxValue = tax.Novidea_HPC__FrontTax__c;
		else
			//if( policyOption == PolicyManagementController.DIRECT )
			newTaxValue = tax.Novidea_HPC__DirectTax__c;

		if (oldValueChanged) {
			for (Novidea_HPC__Income__c inc : incomes)
				inc.Novidea_HPC__Local_Tax__c = newTaxValue;
		} else {
			for (Novidea_HPC__Income__c inc : incomes)
				if (null == inc.Novidea_HPC__Local_Tax__c)
					inc.Novidea_HPC__Local_Tax__c = newTaxValue;
		}
	}

	private void updateIncomeListForFront() {
		changedToFront = true;
		if (incomes.size() != 2) {
			Novidea_HPC__Income__c income = new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id);
			//if type has been changed and tehre were incomes before then reuse them
			if (incomesForDeletion.size() > 0)
				income = incomesForDeletion.remove(0);
			//oreder is important. because when FRONT need to add broker and otherwise remove broker
			//the order is importatnt in the UI component
			incomes.add(income);
			incomes.set(1, incomes[0]);
			incomes.set(0, income);
		}
	}

	private String policyOption;
	private Boolean changedToFront;
	public String error { get; set; }
	public Boolean cancellationProcess { get; set; }
	public Boolean endorsementProcess { get; set; }
	public Integer maxEndorsement { get; set; }
	public Integer currentEndorement { get; set; }
	private List<Novidea_HPC__Income__c> maxEndorsementIncomes;
	public Novidea_HPC__Policy__c policy { get; set; }
	//AEF: values for validation of time period
	public String timePeriodErrorCssClass { get; set; }
	public String effectiveDatePrevValueStr { get; set; }
	public String expirationDatePrevValueStr { get; set; }
	public Boolean timePeriodConfirm { get; set; }

	private List<Novidea_HPC__Policy_Breakdown__c> breakdownsForDeletion;
	private List<Novidea_HPC__Income__c> incomesForDeletion;
	private Map<Integer, Map<Id, List<Novidea_HPC__Income__c>>> incomesByEndorementByCarrier;
	private Map<Id, Novidea_HPC__Income__c> incomesByEndorementByCarrierBeforeChange;

	public Integer totalPremium { get; set; }
	public Integer totalFee { get; set; }
	public Integer totalCredit { get; set; }
	public Integer totalCommission { get; set; }
	Policy_Management_Page__c policyManage;

	private Boolean initialized = false;
	public String policyId {
		get;
		set {
			if (policyId != value) {
				policyId = value;
				init();
			} else if (policyId == null && !initialized)
				init();
		}
	}
	public Boolean newPolicy { get; set; }
	public Boolean isFromConversion {
		get {
			if (isFromConversion == null)
				return false;
			return isFromConversion;
		}
		set;
	}
	public Boolean controlledByFlow {
		get {
			if (controlledByFlow == null)
				return false;
			return controlledByFlow;
		}
		set;
	}

	public Boolean shouldShowEnhancedPolicyManagementPage { get; private set; }
	public Boolean extraExtensionValue { get; set; }
	public Decimal insuranceBankValue { get; set; }
	public Double tariffValue { get; set; }
	public Double feePercentageValue { get; set; }
	public Double agencyFeePercentageValue { get; set; }
	public Decimal extraNetoExtensionValue { get; set; }
	public Double extensionFeePercentageValue { get; set; }
	public Double extensionAgencyFeePercentageValue { get; set; }
	public String extensionCommentsValue { get; set; }

	public PolicyManagementController() {
		newPolicy = Apexpages.currentPage().getParameters().get('Id') == null;
		controlledByFlow = false;
		policyManage = Policy_Management_Page__c.getInstance();
		shouldShowEnhancedPolicyManagementPage = false;
		extraExtensionValue = false;
	}

	/*
		1. search for policy and all its incomes
		2. iterate over incomes and look for the highest endorsement (a group of incomes with the same endorsement #)
		3. if there is no income for agency fee then create one
		4. if there is more then 1 income if there is 1 carrier then its layers and then need to reperesent the incomes as one income. 
			in order to do that - sum the incomes up.
		5. if more then 1 carrier (the screen supports 2 carriers front & broker), need to decide which is front and which broker\carrier 
			and calc the layers (if found) as in #4.
	*/
	private void init() {
		changedToFront = false;
		initialized = true;
		cancellationProcess = false;
		endorsementProcess = false;
		showSubAgentAgreementDialog = false;
		breakdownsForDeletion = new List<Novidea_HPC__Policy_Breakdown__c>();
		incomesForDeletion = new List<Novidea_HPC__Income__c>();
		breakdowns = new List<PolicyBreakdownWrapper>();
		List<Novidea_HPC__Income__c> incomesList;

		maxEndorsement = 0;
		if (policyId != null) {
			policy = [
				SELECT
					Name,
					Main_Policy1__c,
					Novidea_HPC__Client__c,
					Novidea_HPC__Client__r.Agreement__c,
					Novidea_HPC__Original_Type__c,
					Novidea_HPC__Liability_Limit_Per_Case__c,
					Novidea_HPC__Liability_Limit_Currency__c,
					Novidea_HPC__Payments_Number__c,
					Novidea_HPC__Lower_Limit_of_Liability__c,
					Novidea_HPC__Upper_Limit_of_Liability__c,
					Novidea_HPC__Carrier__c,
					Novidea_HPC__Carrier__r.Name,
					Novidea_HPC__Effective_Date__c,
					Novidea_HPC__Expiration_Date__c,
					Novidea_HPC__Product_Definition__c,
					Novidea_HPC__Product_Definition__r.Name,
					Novidea_HPC__Insurance_Type__c,
					Novidea_HPC__Period_Between_Payments__c,
					Novidea_HPC__Next_Payment_Date__c,
					Novidea_HPC__First_Payment_Date__c,
					Novidea_HPC__Action__c,
					Novidea_HPC__Application__c,
					Novidea_HPC__Policy_Number__c,
					Novidea_HPC__Agreement__r.Name,
					Novidea_HPC__Agreement__c,
					Novidea_HPC__Master_Policy__c,
					RecordTypeId,
					RecordType.DeveloperName,
					Insurance_Bank__c,
					Tariff__c,
					Fee_Percentage__c,
					Agency_Fee_Percentage__c,
					Extra_Extension__c,
					SubAgent_Agreement_Exist_And_Is_Rewarded__c
				FROM Novidea_HPC__Policy__c
				WHERE Id = :policyId
			];
			List<Novidea_HPC__Policy_Breakdown__c> policyBreakdowns = [
				SELECT
					Id,
					Novidea_HPC__Carrier__c,
					Novidea_HPC__Commission_Breakdown__c,
					Novidea_HPC__Credit_Fee_Breakdown__c,
					Novidea_HPC__Fees_Breakdown__c,
					Novidea_HPC__Premium_Breakdown__c,
					Novidea_HPC__Carrier__r.Name,
					Novidea_HPC__Policy__c,
					Novidea_HPC__TB__c,
					Novidea_HPC__TB_Amount__c
				FROM Novidea_HPC__Policy_Breakdown__c
				WHERE Novidea_HPC__Policy__c = :policyId
			];
			for (Novidea_HPC__Policy_Breakdown__c policyBreakdown : policyBreakdowns) {
				breakdowns.add(new PolicyBreakdownWrapper(policyBreakdown, breakdowns.Size()));
			}
			incomesList = [
				SELECT
					Id,
					Novidea_HPC__Endorsement_Number__c,
					Novidea_HPC__Agency_Fee_Currency__c,
					Novidea_HPC__Agency_Fee__c,
					Novidea_HPC__Agent_Discount__c,
					Novidea_HPC__Income_Recognition_Date__c,
					Novidea_HPC__Carrier__c,
					Novidea_HPC__Commission_Amount__c,
					Novidea_HPC__Commission_Percentage__c,
					Novidea_HPC__Credit_Fees__c,
					Novidea_HPC__Carrier__r.Name,
					Novidea_HPC__Policy__c,
					Novidea_HPC__Fees__c,
					Novidea_HPC__Local_Tax__c,
					Novidea_HPC__Other_Commission__c,
					Novidea_HPC__Premium_Currency__c,
					Novidea_HPC__Premium__c,
					Novidea_HPC__Tax_On_Premium__c,
					Novidea_HPC__Underwriter_Commission__c,
					Novidea_HPC__Income_Reason__c,
					Insurance_Bank__c,
					Tariff__c,
					Fee_Percentage__c,
					Agency_Fee_Percentage__c,
					Extra_Extension__c,
					Neto_Extra_Extension__c,
					Extension_Fee_Percentage__c,
					Extension_Agency_Fee_Percentage__c,
					Extension_Comments__c
				FROM Novidea_HPC__Income__c
				WHERE Novidea_HPC__Policy__c = :policyId
			];
		} else {
			newPolicy = true;
			policy = new Novidea_HPC__Policy__c(
				Novidea_HPC__Insurance_Type__c = PolicyManagementController.REGULAR,
				RecordTypeId = Apexpages.currentPage().getParameters().get('RecordType')
			);
			incomesList = new List<Novidea_HPC__Income__c>();
			breakdowns.add(
				new PolicyBreakdownWrapper(
					new Novidea_HPC__Policy_Breakdown__c(
						Novidea_HPC__Commission_Breakdown__c = 100,
						Novidea_HPC__Credit_Fee_Breakdown__c = 100,
						Novidea_HPC__Fees_Breakdown__c = 100,
						Novidea_HPC__Premium_Breakdown__c = 100
					),
					breakdowns.Size()
				)
			);
		}

		incomesByEndorementByCarrier = new Map<Integer, Map<Id, List<Novidea_HPC__Income__c>>>();
		incomesByEndorementByCarrierBeforeChange = new Map<Id, Novidea_HPC__Income__c>();

		String agencyFeeCurrency = null;
		Integer agencyFeeAmount = 0;
		Novidea_HPC__Income__c agencyFeesFromNoCarrierIncome = null;

		carrierIdToName = new Map<Id, String>();
		carrierIdToName.put(null, '');
		for (Account account : [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Carrier'])
			carrierIdToName.put(account.id, account.Name);

		for (Novidea_HPC__Income__c income : incomesList) {
			currentEndorement = 0;
			if (income.Novidea_HPC__Endorsement_Number__c == null)
				income.Novidea_HPC__Endorsement_Number__c = 0;
			currentEndorement = (Integer) income.Novidea_HPC__Endorsement_Number__c;
			if (income.Novidea_HPC__Carrier__c == null) {
				if (currentEndorement > maxEndorsement || agencyFeesFromNoCarrierIncome == null) {
					agencyFeesFromNoCarrierIncome = income;
				}
				continue;
			}

			if (currentEndorement > maxEndorsement) {
				maxEndorsement = currentEndorement;
			}
			if (!incomesByEndorementByCarrier.containsKey(currentEndorement))
				incomesByEndorementByCarrier.put(currentEndorement, new Map<Id, List<Novidea_HPC__Income__c>>());
			if (!incomesByEndorementByCarrier.get(currentEndorement).containsKey(income.Novidea_HPC__Carrier__c))
				incomesByEndorementByCarrier.get(currentEndorement).put(income.Novidea_HPC__Carrier__c, new List<Novidea_HPC__Income__c>());
			incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c).add(income);
		}
		/*
		if (agencyFees != null && !incomesByEndorementByCarrier.containsKey(currentEndorement)) {
			incomesByEndorementByCarrier.put(currentEndorement, new Map<Id,List<Novidea_HPC__Income__c>>());
			incomesByEndorementByCarrier.get(currentEndorement).put(agencyFees.Novidea_HPC__Carrier__c, new List<Novidea_HPC__Income__c>());
			incomesByEndorementByCarrier.get(currentEndorement).get(agencyFees.Novidea_HPC__Carrier__c).add(agencyFees);
			agencyFees = null;
		}
		*/

		currentEndorement = maxEndorsement;
		if (incomesByEndorementByCarrier.containsKey(maxEndorsement)) {
			maxEndorsementIncomes = new List<Novidea_HPC__Income__c>();
			for (Id carrierId : incomesByEndorementByCarrier.get(maxEndorsement).keySet())
				maxEndorsementIncomes.add(getTotalIncomeForCarrier(incomesByEndorementByCarrier.get(maxEndorsement).get(carrierId)));
		}
		if (maxEndorsementIncomes == null) {
			maxEndorsementIncomes = new List<Novidea_HPC__Income__c>();
			if (incomesByEndorementByCarrier.get(null) != null)
				for (Id carrierId : incomesByEndorementByCarrier.get(null).keySet())
					maxEndorsementIncomes.add(getTotalIncomeForCarrier(incomesByEndorementByCarrier.get(null).get(carrierId)));
		}
		if (maxEndorsementIncomes == null)
			maxEndorsementIncomes = new List<Novidea_HPC__Income__c>();
		if (maxEndorsementIncomes.size() == 2) {
			incomes = new List<Novidea_HPC__Income__c>(maxEndorsementIncomes.size());
			for (Novidea_HPC__Income__c income : maxEndorsementIncomes) {
				if (income.Novidea_HPC__Carrier__c == policy.Novidea_HPC__Carrier__c)
					incomes[0] = income;
				else
					incomes[1] = income;
			}
		} else
			incomes = maxEndorsementIncomes;
		if (incomes.size() == 0)
			incomes = new List<Novidea_HPC__Income__c>{ new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id) };

		if (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT)
			updateIncomeListForFront();

		if (agencyFeesFromNoCarrierIncome == null) {
			for (Novidea_HPC__Income__c income : maxEndorsementIncomes) {
				if (income.Novidea_HPC__Agency_Fee__c != null && income.Novidea_HPC__Agency_Fee_Currency__c != null) {
					agencyFeeCurrency = income.Novidea_HPC__Agency_Fee_Currency__c;
					agencyFeeAmount += Integer.valueOf(income.Novidea_HPC__Agency_Fee__c);
				}
			}
			agencyFees = new Novidea_HPC__Income__c(
				Novidea_HPC__Policy__c = policy.Id,
				Novidea_HPC__Agency_Fee__c = agencyFeeAmount,
				Novidea_HPC__Agency_Fee_Currency__c = agencyFeeCurrency
			);
		} else
			agencyFees = agencyFeesFromNoCarrierIncome;

		if (breakdowns.Size() == 0) {
			addLine();
			breakdowns[0].carrierName = policy.Novidea_HPC__Carrier__r.Name;
			breakdowns[0].breakdown.Novidea_HPC__Carrier__c = policy.Novidea_HPC__Carrier__c;
		}

		if (policy.Novidea_HPC__Insurance_Type__c == null) {
			if (incomes.size() == 2) {
				policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT;
			} else {
				if (incomes[0].Novidea_HPC__Carrier__c != policy.Novidea_HPC__Carrier__c)
					policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.FRONT;
				else if (breakdowns.Size() > 0 && incomes[0].Novidea_HPC__Carrier__c != breakdowns[0].breakdown.Novidea_HPC__Carrier__c)
					policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.DIRECT;
				else
					policy.Novidea_HPC__Insurance_Type__c = PolicyManagementController.REGULAR;
			}
		}
		policyOption = policy.Novidea_HPC__Insurance_Type__c;
		//AEF:
		setPremiumTax(false);
		// Replace all current data with duplicates for comperison:
		for (Integer endorsement : incomesByEndorementByCarrier.keySet()) {
			for (Id carrierId : incomesByEndorementByCarrier.get(endorsement).keySet()) {
				for (Novidea_HPC__Income__c income : incomesByEndorementByCarrier.get(endorsement).get(carrierId))
					incomesByEndorementByCarrierBeforeChange.put(income.Id, income.clone(false, true, false, true));
			}
		}

		shouldShowEnhancedPolicyManagementPage = showEnhancedPolicyManagementPage();
		if (shouldShowEnhancedPolicyManagementPage) {
			insuranceBankValue = policy.Insurance_Bank__c != null ? policy.Insurance_Bank__c : 0;
			tariffValue = policy.Tariff__c != null ? policy.Tariff__c : 0;
			feePercentageValue = policy.Fee_Percentage__c != null ? policy.Fee_Percentage__c : 0;
			agencyFeePercentageValue = policy.Agency_Fee_Percentage__c != null ? policy.Agency_Fee_Percentage__c : 0;
		}

		if (subAgentLogic && policy.Novidea_HPC__Agreement__c == null) {
			showAgreement = false;
			if (String.isBlank(policy.SubAgent_Agreement_Exist_And_Is_Rewarded__c) && policy.Novidea_HPC__Client__r.Agreement__c != null) {
				showSubAgentAgreementDialog = true;
			}
		}
	}

	/*
		turns several incomes to one
	*/
	private Novidea_HPC__Income__c getTotalIncomeForCarrier(List<Novidea_HPC__Income__c> incomes) {
		if (incomes.size() == 1)
			return incomes[0];
		Novidea_HPC__Income__c returnValue = new Novidea_HPC__Income__c(Novidea_HPC__Policy__c = policy.Id);
		Integer commissionCounter = 0;
		String agencyFeeCurrency, premiumCurrency;
		Decimal localTax, taxOnPremium;
		Id carrierId;
		for (Novidea_HPC__Income__c income : incomes) {
			if (agencyFeeCurrency == null)
				agencyFeeCurrency = income.Novidea_HPC__Agency_Fee_Currency__c;
			if (premiumCurrency == null)
				premiumCurrency = income.Novidea_HPC__Premium_Currency__c;
			if (localTax == null)
				localTax = income.Novidea_HPC__Local_Tax__c;
			if (taxOnPremium == null)
				taxOnPremium = income.Novidea_HPC__Tax_On_Premium__c;
			if (carrierId == null)
				carrierId = income.Novidea_HPC__Carrier__c;

			if (income.Novidea_HPC__Agent_Discount__c != null) {
				if (returnValue.Novidea_HPC__Agent_Discount__c == null)
					returnValue.Novidea_HPC__Agent_Discount__c = 0;
				returnValue.Novidea_HPC__Agent_Discount__c += income.Novidea_HPC__Agent_Discount__c;
			}
			if (income.Novidea_HPC__Commission_Amount__c != null) {
				if (returnValue.Novidea_HPC__Commission_Amount__c == null)
					returnValue.Novidea_HPC__Commission_Amount__c = 0;
				returnValue.Novidea_HPC__Commission_Amount__c += income.Novidea_HPC__Commission_Amount__c;
			}
			if (income.Novidea_HPC__Credit_Fees__c != null) {
				if (returnValue.Novidea_HPC__Credit_Fees__c == null)
					returnValue.Novidea_HPC__Credit_Fees__c = 0;
				returnValue.Novidea_HPC__Credit_Fees__c += income.Novidea_HPC__Credit_Fees__c;
			}
			if (income.Novidea_HPC__Fees__c != null) {
				if (returnValue.Novidea_HPC__Fees__c == null)
					returnValue.Novidea_HPC__Fees__c = 0;
				returnValue.Novidea_HPC__Fees__c += income.Novidea_HPC__Fees__c;
			}
			if (income.Novidea_HPC__Other_Commission__c != null) {
				if (returnValue.Novidea_HPC__Other_Commission__c == null)
					returnValue.Novidea_HPC__Other_Commission__c = 0;
				returnValue.Novidea_HPC__Other_Commission__c += income.Novidea_HPC__Other_Commission__c;
			}
			if (income.Novidea_HPC__Premium__c != null) {
				if (returnValue.Novidea_HPC__Premium__c == null)
					returnValue.Novidea_HPC__Premium__c = 0;
				returnValue.Novidea_HPC__Premium__c += income.Novidea_HPC__Premium__c;
			}
			if (income.Novidea_HPC__Underwriter_Commission__c != null) {
				if (returnValue.Novidea_HPC__Underwriter_Commission__c == null)
					returnValue.Novidea_HPC__Underwriter_Commission__c = 0;
				returnValue.Novidea_HPC__Underwriter_Commission__c += income.Novidea_HPC__Underwriter_Commission__c;
			}
		}
		returnValue.Novidea_HPC__Agency_Fee_Currency__c = agencyFeeCurrency;
		returnValue.Novidea_HPC__Premium_Currency__c = premiumCurrency;
		returnValue.Novidea_HPC__Local_Tax__c = localTax;
		returnValue.Novidea_HPC__Tax_On_Premium__c = taxOnPremium;
		returnValue.Novidea_HPC__Carrier__c = carrierId;

		// Net premium.
		if (
			returnValue.Novidea_HPC__Commission_Amount__c != null &&
			returnValue.Novidea_HPC__Premium__c != null &&
			returnValue.Novidea_HPC__Premium__c != 0
		)
			returnValue.Novidea_HPC__Commission_Percentage__c =
				returnValue.Novidea_HPC__Commission_Amount__c /
				returnValue.Novidea_HPC__Premium__c *
				100.0;

		return returnValue;
	}

	private Integer getMaxIdVal() {
		Integer max = -1;
		if (breakdowns == null)
			return max;
		for (PolicyBreakdownWrapper cw : breakdowns) {
			if (cw.id > max)
				max = cw.Id;
		}
		return max;
	}

	public void addLine() {
		breakdowns.add(
			new PolicyBreakdownWrapper(
				new Novidea_HPC__Policy_Breakdown__c(Novidea_HPC__Policy__c = policy.Id),
				getMaxIdVal() + 1
			)
		);
	}

	public void removeLine() {
		Integer breakdownsSize = breakdowns.Size();
		for (Integer breakdownIndex = 0; breakdownIndex < breakdownsSize; breakdownIndex++) {
			PolicyBreakdownWrapper cw = breakdowns[breakdownIndex];
			if (cw.id == lineToRemove) {
				Novidea_HPC__Policy_Breakdown__c removedBreakdown = breakdowns.remove(breakdownIndex).breakdown;
				if (cw.breakdown.Id != null)
					breakdownsForDeletion.add(removedBreakdown);
				break;
			}
		}
	}
	//AEF:

	public Pagereference exitPage() {
		if (true == this.advancedMode && null != policy.Novidea_HPC__Application__c) {
			return new Pagereference('/' + policy.Novidea_HPC__Application__c).setRedirect(true);
		}
		return null;
	}

	public void cancellation() {
		currentEndorement++;

		cleanData();
		for (Novidea_HPC__Income__c income : incomes)
			income.Novidea_HPC__Expiration_Date__c = Date.today();
		cancellationProcess = true;
	}

	public void endorsement() {
		System.debug('In endorsement!!');
		currentEndorement++;
		cleanData();
		endorsementProcess = true;
	}

	// Sub-agent from client
	public Boolean subAgentLogic {
		get {
			return policyManage?.Show_Sub_Agent_Agreement_From_Client__c != null ? policyManage.Show_Sub_Agent_Agreement_From_Client__c : false;
		}
	}
	public Boolean showSubAgentAgreementDialog { get; set; }

	public void hideSubAgentAgreementDialog() {
		policy.SubAgent_Agreement_Exist_And_Is_Rewarded__c = Label.No;
		showSubAgentAgreementDialog = false;
	}

	public void handleSubAgent() {
		policy.Novidea_HPC__Agreement__c = policy.Novidea_HPC__Client__r.Agreement__c;
		policy.SubAgent_Agreement_Exist_And_Is_Rewarded__c = Label.Yes;
		showSubAgentAgreementDialog = false;
		showAgreement = true;
	}

	/*
		when duplicating previous incomes cleans the data
	*/
	@testVisible
	private void cleanData() {
		List<Novidea_HPC__Income__c> cleanIncomes = new List<Novidea_HPC__Income__c>();
		Map<Id, Decimal> comRatesByPolicy;
		// if we don't use default commission update get the commission percentage from the commission rate object.
		if (!Novidea_HPC.TriggerUtils.isTriggerEnabled('DefaultCommissionUpdate')) {
			comRatesByPolicy = getCommissionComRatesByPolicy(incomes);
		}
		agencyFees.Novidea_HPC__Agency_Fee__c = 0;
		for (Novidea_HPC__Income__c income : incomes) {
			Novidea_HPC__Income__c newIncome = income.clone(false, true, false, true);
			newIncome.Novidea_HPC__Agency_Fee__c = 0;
			newIncome.Novidea_HPC__Agent_Discount__c = 0;
			newIncome.Novidea_HPC__Commission_Amount__c = 0;
			newIncome.Novidea_HPC__Credit_Fees__c = 0;
			newIncome.Novidea_HPC__Fees__c = 0;
			newIncome.Novidea_HPC__Other_Commission__c = 0;
			newIncome.Novidea_HPC__Other_Commission__c = 0;
			newIncome.Novidea_HPC__Premium__c = 0;
			newIncome.Novidea_HPC__Client__c = policy.Novidea_HPC__Client__c;
			newIncome.Novidea_HPC__Underwriter_Commission__c = 0;
			newIncome.Novidea_HPC__Income_Recognition_Date__c = null; //diana 16.02.2014 howden ask to clear this field after click on Extension_Change btn
			if (!Novidea_HPC.TriggerUtils.isTriggerEnabled('DefaultCommissionUpdate')) {
				if (comRatesByPolicy != null) {
					if (comRatesByPolicy.containsKey(income.Novidea_HPC__Policy__c)) {
						newIncome.Novidea_HPC__Commission_Percentage__c = comRatesByPolicy.get(income.Novidea_HPC__Policy__c);
					}
				}
			}
			cleanIncomes.add(newIncome);
		}
		incomes = cleanIncomes;
		incomesByEndorementByCarrier = new Map<Integer, Map<Id, List<Novidea_HPC__Income__c>>>();
		incomesByEndorementByCarrierBeforeChange = new Map<Id, Novidea_HPC__Income__c>();
		for (Novidea_HPC__Income__c income : incomes) {
			if (!incomesByEndorementByCarrier.containsKey(currentEndorement))
				incomesByEndorementByCarrier.put(currentEndorement, new Map<Id, List<Novidea_HPC__Income__c>>());
			if (!incomesByEndorementByCarrier.get(currentEndorement).containsKey(income.Novidea_HPC__Carrier__c))
				incomesByEndorementByCarrier.get(currentEndorement).put(income.Novidea_HPC__Carrier__c, new List<Novidea_HPC__Income__c>());
			incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c).add(income);
		}
		for (Integer endorsement : incomesByEndorementByCarrier.keySet()) {
			for (Id carrierId : incomesByEndorementByCarrier.get(endorsement).keySet()) {
				for (Novidea_HPC__Income__c income : incomesByEndorementByCarrier.get(endorsement).get(carrierId))
					incomesByEndorementByCarrierBeforeChange.put(income.Id, income.clone(false, true, false, true));
			}
		}
	}
	/*AEF:
		A function checks whether the time period of policy is not little as a defined value (PolicyTimePeriodLimit).
	*/
	private ApexPages.message validatePolicyTimePeriod() {
		if (timePeriodConfirm != true) {
			Integer daysNumberLimit = Novidea_HPC__Time_Periods__c.getInstance().Novidea_HPC__Minimum_Number_of_Days_for_Policy__c.intValue();
			Date effectiveDatePreviousValue = !ConstructorPoliciesUtils.isNullOrEmpty(this.effectiveDatePrevValueStr)
				? Date.parse(this.effectiveDatePrevValueStr)
				: null;
			Date expirationDatePreviousValue = !ConstructorPoliciesUtils.isNullOrEmpty(this.expirationDatePrevValueStr)
				? Date.parse(this.expirationDatePrevValueStr)
				: null;
			if (
				policy.Novidea_HPC__Effective_Date__c.daysBetween(policy.Novidea_HPC__Expiration_Date__c.addDays(1)) < daysNumberLimit &&
				((effectiveDatePreviousValue == null && expirationDatePreviousValue == null) ||
				(!policy.Novidea_HPC__Effective_Date__c.isSameDay(effectiveDatePreviousValue) ||
				!policy.Novidea_HPC__Expiration_Date__c.isSameDay(expirationDatePreviousValue)))
			) {
				String t = string.valueOf(policy.Novidea_HPC__Effective_Date__c.daysBetween(policy.Novidea_HPC__Expiration_Date__c) + 1);
				this.timePeriodErrorCssClass = 'timePeriodErrorCssClass';
				this.effectiveDatePrevValueStr = policy.Novidea_HPC__Effective_Date__c.format();
				this.expirationDatePrevValueStr = policy.Novidea_HPC__Expiration_Date__c.format();
				error = System.Label.Policy_time_period_too_small.replace('{0}', String.valueOf(daysNumberLimit));
				return (new ApexPages.message(ApexPages.severity.ERROR, error));
			} else {
				this.timePeriodErrorCssClass = '';
				this.effectiveDatePrevValueStr = null;
				this.expirationDatePrevValueStr = null;
				this.timePeriodConfirm = true;
				return null;
			}
		}
		return null;
	}

	public PageReference Save() {
		// TBD - deletion of split income (the case where income of more then one year is split to years) is not covered.
		try {
			error = null;

			ApexPages.Message errMsg = validatePolicyTimePeriod();
			if (null != errMsg) {
				ApexPages.addMessage(errMsg);
				return null;
			}

			if (currentEndorement < maxEndorsement) {
				error = System.Label.Cannot_input_lower_value_than_exist_in_the_system;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, error));
				return null;
			}

			if (cancellationProcess)
				policy.Novidea_HPC__Action__c = 'Cancelled';
			if (
				(policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.REGULAR ||
				policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.DIRECT) &&
				incomes[0].Novidea_HPC__Commission_Percentage__c == null &&
				incomes[0].Novidea_HPC__Commission_Amount__c == null
			) {
				error = System.Label.Commission_input_in_percentage_or_round_number + ' ';
				if (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.REGULAR)
					error += System.Label.For_local_carrier;
				else
					error += System.Label.For_external_carrier_broker;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, error));
				return null;
			} else if (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT) {
				if (incomes[1].Novidea_HPC__Commission_Percentage__c == null && incomes[1].Novidea_HPC__Commission_Amount__c == null)
					error = System.Label.Commission_input_in_percentage_or_round_number_for_external_carrier_broker;
				else if (incomes[0].Novidea_HPC__Other_Commission__c == null) {
					// TBD - is this an error?
				}

				if (error != null) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, error));
					return null;
				}
			}

			if (policy.Novidea_HPC__Insurance_Type__c != PolicyManagementController.REGULAR) {
				List<Novidea_HPC__Policy_Breakdown__c> upsertBreakdowns = new List<Novidea_HPC__Policy_Breakdown__c>();
				List<Id> carrierIds = new List<Id>();
				for (PolicyBreakdownWrapper breakdown : breakdowns) {
					upsertBreakdowns.add(breakdown.breakdown);
					carrierIds.add(breakdown.breakdown.Novidea_HPC__Carrier__c);
				}
				Map<Id, Account> carrierIdToName = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :carrierIds]);
				carrierIdToName.put(null, new Account(name = ''));
				for (Novidea_HPC__Policy_Breakdown__c breakdown : upsertBreakdowns) {
					breakdown.Name = carrierIdToName.get(breakdown.Novidea_HPC__Carrier__c).Name;
				}
				if (upsertBreakdowns.size() > 0)
					Database.upsert(upsertBreakdowns);
				if (breakdownsForDeletion.size() > 0) {
					if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
						NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Policy_Breakdown__c' }, NOVU.SecurityUtils.CRUD.DLT);
					}

					Database.delete(breakdownsForDeletion);
				}
			}
			if (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT) {
				incomes[0].Novidea_HPC__Premium__c = incomes[0].Novidea_HPC__Commission_Percentage__c = incomes[0]
					.Novidea_HPC__Commission_Amount__c = incomes[0].Novidea_HPC__Agent_Discount__c = null;
			}
			List<Novidea_HPC__Income__c> upsertIncomes = getUpdatedIncomes();

			policy.Novidea_HPC__Carrier__c = incomes[0].Novidea_HPC__Carrier__c;
			policy.Novidea_HPC__Is_PPW__c = (policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.FRONT ||
			policy.Novidea_HPC__Insurance_Type__c == PolicyManagementController.DIRECT);

			if (currentEndorement > maxEndorsement) {
				policy.Novidea_HPC__Next_Payment_Date__c = Date.today();
			} else {
				if (policy.Novidea_HPC__Effective_Date__c != null) {
					// TBD - replace the 15 and 30 days with custom settings
					if (policy.Novidea_HPC__Is_PPW__c)
						policy.Novidea_HPC__Next_Payment_Date__c =
							policy.Novidea_HPC__Effective_Date__c +
							Integer.valueOf(policy.Novidea_HPC__Period_Between_Payments__c) -
							15;
					else
						policy.Novidea_HPC__Next_Payment_Date__c = policy.Novidea_HPC__Effective_Date__c + 30;
				}
			}

			if (policy.Novidea_HPC__First_Payment_Date__c == null)
				policy.Novidea_HPC__First_Payment_Date__c = policy.Novidea_HPC__Next_Payment_Date__c;

			if (cancelPolicy == true) {
				policy.Novidea_HPC__Action__c = 'Cancelled';
			}

			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckFLSCreate')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Policy__c',
					new Set<String>{
						'Novidea_HPC__Action__c',
						'Novidea_HPC__Carrier__c',
						'Novidea_HPC__Is_PPW__c',
						'Novidea_HPC__First_Payment_Date__c',
						'Novidea_HPC__Next_Payment_Date__c'
					},
					new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
				);
			}
			Database.upsert(policy);
			for (Novidea_HPC__Income__c income : upsertIncomes)
				if (income.Novidea_HPC__Policy__c == null)
					income.Novidea_HPC__Policy__c = policy.Id;

			System.debug(upsertIncomes);

			if (upsertIncomes.size() > 0) {
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckFLSCreate')) {
					NOVU.SecurityUtils.checkFields(
						'Novidea_HPC__Income__c',
						new Set<String>{
							'Novidea_HPC__Premium__c',
							'Novidea_HPC__Commission_Amount__c',
							'Novidea_HPC__Commission_Percentage__c',
							'Novidea_HPC__Agency_Fee__c',
							'Novidea_HPC__Agent_Discount__c',
							'Novidea_HPC__Credit_Fees__c',
							'Novidea_HPC__Fees__c',
							'Novidea_HPC__Income_Recognition_Date__c',
							'Novidea_HPC__Other_Commission__c',
							'Novidea_HPC__Underwriter_Commission__c',
							'Novidea_HPC__Agency_Fee_Currency__c',
							'Novidea_HPC__Carrier__c',
							'Novidea_HPC__Local_Tax__c',
							'Novidea_HPC__Premium_Currency__c',
							'Novidea_HPC__Tax_On_Premium__c',
							'Novidea_HPC__Effective_Date__c',
							'Novidea_HPC__Expiration_Date__c'
						},
						new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
					);
				}
				Database.upsert(upsertIncomes);
			}
			if (incomesForDeletion.size() > 0) {
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
					NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Income__c' }, NOVU.SecurityUtils.CRUD.DLT);
				}

				Database.delete(incomesForDeletion);
			}

			if (newPolicy && !controlledByFlow)
				return new Pagereference('/' + policy.Id);
		} catch (Exception exp) {
			ConstructorPoliciesUtils.performException(exp);
		}
		return null;
	}

	/*
		this method extrcts the actuall incomes from the unified income (if neccesary)
	*/
	private List<Novidea_HPC__Income__c> getUpdatedIncomes() {
		List<Novidea_HPC__Income__c> upsertIncomes = new List<Novidea_HPC__Income__c>();
		for (Novidea_HPC__Income__c income : incomes) {
			if (changedToFront) {
				// If the user changed to front it means there are no current incomes that need the special treatment.
				//That is because policy doesn't change to front after admitted.
				upsertIncomes.add(income);
				//in case the currentEndorsement has changed not through the change\extend button
			} else if (currentEndorement > maxEndorsement) {
				Novidea_HPC__Income__c clonedInc = income.clone(false, true, false, true);
				clonedInc.Novidea_HPC__Income_Recognition_Date__c = null;
				clonedInc.Novidea_HPC__Bordero_Date__c = null;
				upsertIncomes.add(clonedInc);
			} else {
				if (
					incomesByEndorementByCarrier.get(currentEndorement) == null ||
					incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c) == null ||
					incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c).size() <= 1
				) {
					//simple action: just add the income
					if (
						incomesByEndorementByCarrier.get(currentEndorement) != null &&
						incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c) != null
					) {
						upsertIncomes.add(
							getTotalIncomeForCarrier(
								incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c)[0],
								1,
								incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c)[0],
								income,
								incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c)[0]
							)
						);
					} else
						upsertIncomes.add(income);
				} else {
					//here an amount changed is splitted between the incomes according to original proportion
					List<Novidea_HPC__Income__c> oldIncomes = new List<Novidea_HPC__Income__c>();
					for (
						Novidea_HPC__Income__c newIncome : incomesByEndorementByCarrier.get(currentEndorement)
							.get(income.Novidea_HPC__Carrier__c)
					)
						oldIncomes.add(incomesByEndorementByCarrierBeforeChange.get(newIncome.Id));
					//here we get the total of incomes in order to judge the change in relation to the screen income
					Novidea_HPC__Income__c oldTotalIncome = getTotalIncomeForCarrier(oldIncomes);
					for (Integer incomeIndex = 0; incomeIndex < oldIncomes.size(); incomeIndex++) {
						//updatet the old income with the proportion deduced from the relation between oldTotalIncome and income (aka newTotalIncome)
						Novidea_HPC__Income__c upsertIncome = getTotalIncomeForCarrier(
							oldTotalIncome,
							oldIncomes.size(),
							oldIncomes[incomeIndex],
							income,
							incomesByEndorementByCarrier.get(currentEndorement).get(income.Novidea_HPC__Carrier__c)[incomeIndex]
						);
						upsertIncome.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Effective_Date__c;
						upsertIncome.Novidea_HPC__Expiration_Date__c = policy.Novidea_HPC__Expiration_Date__c;
						if (upsertIncome.Novidea_HPC__Commission_Percentage__c != 0 && upsertIncome.Novidea_HPC__Commission_Amount__c == 0)
							upsertIncome.Novidea_HPC__Commission_Amount__c = null;
						else if (upsertIncome.Novidea_HPC__Commission_Percentage__c == 0 && upsertIncome.Novidea_HPC__Commission_Amount__c != 0)
							upsertIncome.Novidea_HPC__Commission_Percentage__c = null;
						upsertIncomes.add(upsertIncome);
					}
				}
			}
		}
		if (agencyFees != null) {
			if (agencyFees.Id != null)
				upsertIncomes.add(agencyFees);
			else {
				Novidea_HPC__Income__c incomeWithAgencyFee = upsertIncomes[0];
				if (
					upsertIncomes.size() > 1 &&
					upsertIncomes[1].Novidea_HPC__Agency_Fee__c != 0 &&
					upsertIncomes[1].Novidea_HPC__Agency_Fee__c != null
				) {
					incomeWithAgencyFee = upsertIncomes[1];
				}
				incomeWithAgencyFee.Novidea_HPC__Agency_Fee__c = agencyFees.Novidea_HPC__Agency_Fee__c;
				incomeWithAgencyFee.Novidea_HPC__Agency_Fee_Currency__c = agencyFees.Novidea_HPC__Agency_Fee_Currency__c;
			}
		}

		for (Novidea_HPC__Income__c income : upsertIncomes) {
			income.Novidea_HPC__Endorsement_Number__c = currentEndorement;
			income.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Effective_Date__c;
			income.Novidea_HPC__Expiration_Date__c = policy.Novidea_HPC__Expiration_Date__c;
			income.Novidea_HPC__Income_Reason__c = incomeReason;
			//if (income.Novidea_HPC__Agency_Fee__c == null || income.Novidea_HPC__Agency_Fee__c == 0)
			//income.Novidea_HPC__Agency_Fee_Currency__c = null;
			if (shouldShowEnhancedPolicyManagementPage) {
				income.Insurance_Bank__c = insuranceBankValue;
				income.Tariff__c = tariffValue;
				income.Fee_Percentage__c = feePercentageValue;
				income.Agency_Fee_Percentage__c = agencyFeePercentageValue;
				income.Extra_Extension__c = extraExtensionValue;
				if (extraExtensionValue) {
					income.Neto_Extra_Extension__c = extraNetoExtensionValue;
					income.Extension_Fee_Percentage__c = extensionFeePercentageValue;
					income.Extension_Agency_Fee_Percentage__c = extensionAgencyFeePercentageValue;
					income.Extension_Comments__c = extensionCommentsValue?.left(250);
				}
			}
		}
		return upsertIncomes;
	}

	protected Novidea_HPC__Income__c getTotalIncomeForCarrier(
		Novidea_HPC__Income__c totalIncome,
		Integer numberOfOldIncomes,
		Novidea_HPC__Income__c oldIncome,
		Novidea_HPC__Income__c updatedTotalIncome,
		Novidea_HPC__Income__c income
	) {
		if (
			oldIncome.Novidea_HPC__Agent_Discount__c != null &&
			updatedTotalIncome.Novidea_HPC__Agent_Discount__c != null &&
			totalIncome.Novidea_HPC__Agent_Discount__c != 0 &&
			totalIncome.Novidea_HPC__Agent_Discount__c != null
		) {
			income.Novidea_HPC__Agent_Discount__c =
				updatedTotalIncome.Novidea_HPC__Agent_Discount__c *
				oldIncome.Novidea_HPC__Agent_Discount__c /
				totalIncome.Novidea_HPC__Agent_Discount__c;
		} else {
			if (updatedTotalIncome.Novidea_HPC__Agent_Discount__c != null)
				income.Novidea_HPC__Agent_Discount__c = updatedTotalIncome.Novidea_HPC__Agent_Discount__c / numberOfOldIncomes;
		}

		if (
			oldIncome.Novidea_HPC__Commission_Amount__c != null &&
			updatedTotalIncome.Novidea_HPC__Commission_Amount__c != null &&
			totalIncome.Novidea_HPC__Commission_Amount__c != 0 &&
			totalIncome.Novidea_HPC__Commission_Amount__c != null
		) {
			income.Novidea_HPC__Commission_Amount__c =
				updatedTotalIncome.Novidea_HPC__Commission_Amount__c *
				oldIncome.Novidea_HPC__Commission_Amount__c /
				totalIncome.Novidea_HPC__Commission_Amount__c;
		} else {
			if (updatedTotalIncome.Novidea_HPC__Commission_Amount__c != null)
				income.Novidea_HPC__Commission_Amount__c = updatedTotalIncome.Novidea_HPC__Commission_Amount__c / numberOfOldIncomes;
		}

		//income.Novidea_HPC__Commission_Percentage__c = null;
		if (!extraExtensionValue) {
			if (
				oldIncome.Novidea_HPC__Commission_Percentage__c != null &&
				updatedTotalIncome.Novidea_HPC__Commission_Percentage__c != null &&
				totalIncome.Novidea_HPC__Commission_Percentage__c != 0 &&
				totalIncome.Novidea_HPC__Commission_Percentage__c != null
			) {
				income.Novidea_HPC__Commission_Percentage__c =
					updatedTotalIncome.Novidea_HPC__Commission_Percentage__c *
					oldIncome.Novidea_HPC__Commission_Percentage__c /
					totalIncome.Novidea_HPC__Commission_Percentage__c;
			} else {
				if (updatedTotalIncome.Novidea_HPC__Commission_Percentage__c != null)
					income.Novidea_HPC__Commission_Percentage__c = updatedTotalIncome.Novidea_HPC__Commission_Percentage__c / numberOfOldIncomes;
			}
		}
		if (income.Novidea_HPC__Commission_Percentage__c == null) {
			if (
				!extraExtensionValue &&
				income.Novidea_HPC__Commission_Amount__c != null &&
				income.Novidea_HPC__Premium__c != null &&
				income.Novidea_HPC__Premium__c != 0 &&
				income.Novidea_HPC__Commission_Percentage__c == null
			) {
				income.Novidea_HPC__Commission_Percentage__c = income.Novidea_HPC__Commission_Amount__c / income.Novidea_HPC__Premium__c * 100.0;
			}
		} else if (income.Novidea_HPC__Premium__c != null) {
			income.Novidea_HPC__Commission_Amount__c = income.Novidea_HPC__Commission_Percentage__c / 100.0 * income.Novidea_HPC__Premium__c;
		}

		if (
			oldIncome.Novidea_HPC__Credit_Fees__c != null &&
			updatedTotalIncome.Novidea_HPC__Credit_Fees__c != null &&
			totalIncome.Novidea_HPC__Credit_Fees__c != 0 &&
			totalIncome.Novidea_HPC__Credit_Fees__c != null
		) {
			income.Novidea_HPC__Credit_Fees__c =
				updatedTotalIncome.Novidea_HPC__Credit_Fees__c *
				oldIncome.Novidea_HPC__Credit_Fees__c /
				totalIncome.Novidea_HPC__Credit_Fees__c;
		} else {
			if (updatedTotalIncome.Novidea_HPC__Credit_Fees__c != null)
				income.Novidea_HPC__Credit_Fees__c = updatedTotalIncome.Novidea_HPC__Credit_Fees__c / numberOfOldIncomes;
		}

		if (!extraExtensionValue) {
			if (
				oldIncome.Novidea_HPC__Fees__c != null &&
				updatedTotalIncome.Novidea_HPC__Fees__c != null &&
				totalIncome.Novidea_HPC__Fees__c != 0 &&
				totalIncome.Novidea_HPC__Fees__c != null
			) {
				income.Novidea_HPC__Fees__c =
					updatedTotalIncome.Novidea_HPC__Fees__c *
					oldIncome.Novidea_HPC__Fees__c /
					totalIncome.Novidea_HPC__Fees__c;
			} else if (updatedTotalIncome.Novidea_HPC__Fees__c != null) {
				income.Novidea_HPC__Fees__c = updatedTotalIncome.Novidea_HPC__Fees__c / numberOfOldIncomes;
			}
		}

		if (
			oldIncome.Novidea_HPC__Other_Commission__c != null &&
			updatedTotalIncome.Novidea_HPC__Other_Commission__c != null &&
			totalIncome.Novidea_HPC__Other_Commission__c != 0 &&
			totalIncome.Novidea_HPC__Other_Commission__c != null
		) {
			income.Novidea_HPC__Other_Commission__c =
				updatedTotalIncome.Novidea_HPC__Other_Commission__c *
				oldIncome.Novidea_HPC__Other_Commission__c /
				totalIncome.Novidea_HPC__Other_Commission__c;
		} else {
			if (updatedTotalIncome.Novidea_HPC__Other_Commission__c != null)
				income.Novidea_HPC__Other_Commission__c = updatedTotalIncome.Novidea_HPC__Other_Commission__c / numberOfOldIncomes;
		}

		if (!extraExtensionValue) {
			if (
				oldIncome.Novidea_HPC__Premium__c != null &&
				updatedTotalIncome.Novidea_HPC__Premium__c != null &&
				totalIncome.Novidea_HPC__Premium__c != 0 &&
				totalIncome.Novidea_HPC__Premium__c != null
			) {
				income.Novidea_HPC__Premium__c =
					updatedTotalIncome.Novidea_HPC__Premium__c *
					oldIncome.Novidea_HPC__Premium__c /
					totalIncome.Novidea_HPC__Premium__c;
			} else if (updatedTotalIncome.Novidea_HPC__Premium__c != null) {
				income.Novidea_HPC__Premium__c = updatedTotalIncome.Novidea_HPC__Premium__c / numberOfOldIncomes;
			}
		}

		if (
			oldIncome.Novidea_HPC__Underwriter_Commission__c != null &&
			updatedTotalIncome.Novidea_HPC__Underwriter_Commission__c != null &&
			totalIncome.Novidea_HPC__Underwriter_Commission__c != 0 &&
			totalIncome.Novidea_HPC__Underwriter_Commission__c != null
		) {
			income.Novidea_HPC__Underwriter_Commission__c =
				updatedTotalIncome.Novidea_HPC__Underwriter_Commission__c *
				oldIncome.Novidea_HPC__Underwriter_Commission__c /
				totalIncome.Novidea_HPC__Underwriter_Commission__c;
		} else {
			if (updatedTotalIncome.Novidea_HPC__Underwriter_Commission__c != null)
				income.Novidea_HPC__Underwriter_Commission__c = updatedTotalIncome.Novidea_HPC__Underwriter_Commission__c / numberOfOldIncomes;
		}

		income.Novidea_HPC__Agency_Fee_Currency__c = updatedTotalIncome.Novidea_HPC__Agency_Fee_Currency__c;
		income.Novidea_HPC__Premium_Currency__c = updatedTotalIncome.Novidea_HPC__Premium_Currency__c;
		income.Novidea_HPC__Local_Tax__c = updatedTotalIncome.Novidea_HPC__Local_Tax__c;
		income.Novidea_HPC__Tax_On_Premium__c = updatedTotalIncome.Novidea_HPC__Tax_On_Premium__c;
		income.Novidea_HPC__Carrier__c = updatedTotalIncome.Novidea_HPC__Carrier__c;

		return income;
	}

	private Boolean showEnhancedPolicyManagementPage() {
		String policyRecordTypeName = policy.RecordType.DeveloperName;
		return policyRecordTypeName.equals('Parent_Policy') || // Local parent record type
			policyRecordTypeName.equals('Contractors_Policy_Management') || // Policy recrdtype in HPC Lead Extension package
			policy.Main_Policy1__c != null;
	}

	/*
	 * set the maps of policy Id and commision rate for commissions by calling createComRatesByCarrierAndProdDef method
	 */
	public static Map<Id, Decimal> getCommissionComRatesByPolicy(List<Novidea_HPC__Income__c> incomes) {
		Set<Id> carriers = new Set<Id>();
		Set<Id> productsDef = new Set<Id>();
		List<Id> policiesId = new List<Id>();
		Map<Id, Decimal> commissionComRatesByPolicy = new Map<Id, Decimal>();
		Map<String, Decimal> commissionComRatesByCarrierAndProdDef;

		for (Novidea_HPC__Income__c income : incomes) {
			policiesId.add(income.Novidea_HPC__Policy__c);
		}

		List<Novidea_HPC__Policy__c> policies = [
			SELECT Novidea_HPC__Carrier__c, Novidea_HPC__Product_Definition__c
			FROM Novidea_HPC__Policy__c
			WHERE Id IN :policiesId
		];
		commissionComRatesByCarrierAndProdDef = createComRatesByCarrierAndProdDef(policies);
		for (Novidea_HPC__Policy__c policy : policies) {
			String carrierAndProdDefIds = (String) policy.Novidea_HPC__Carrier__c + (String) policy.Novidea_HPC__Product_Definition__c;
			if (commissionComRatesByCarrierAndProdDef.containsKey(carrierAndProdDefIds)) {
				commissionComRatesByPolicy.put(policy.Id, commissionComRatesByCarrierAndProdDef.get(carrierAndProdDefIds));
			}
		}
		return commissionComRatesByPolicy;
	}

	/*
	 * set the maps of carrier and product Def and commision rate for commissions
	 */
	private static Map<String, Decimal> createComRatesByCarrierAndProdDef(List<Novidea_HPC__Policy__c> policies) {
		Set<Id> carriers = new Set<Id>();
		Set<Id> productsDef = new Set<Id>();
		List<String> recordTypeNames = new List<String>{ 'Commission' };

		for (Novidea_HPC__Policy__c policy : policies) {
			carriers.add(policy.Novidea_HPC__Carrier__c);
			productsDef.add(policy.Novidea_HPC__Product_Definition__c);
		}

		List<Novidea_HPC__Commission_Rate__c> commissionRates = [
			SELECT
				Id,
				Novidea_HPC__Agreement__r.Novidea_HPC__Carrier__c,
				Novidea_HPC__Product_Definition__c,
				Novidea_HPC__Percentage__c,
				RecordType.DeveloperName
			FROM Novidea_HPC__Commission_Rate__c
			WHERE
				Novidea_HPC__Agreement__r.Novidea_HPC__Expiration_Date__c > :Date.today()
				AND RecordType.DeveloperName IN :recordTypeNames
				AND Novidea_HPC__Product_Definition__c IN :productsDef
				AND Novidea_HPC__Agreement__r.Novidea_HPC__Carrier__r.Id IN :carriers
		];

		Map<String, Decimal> commissionComRatesByCarrierAndProdDef = new Map<String, Decimal>();
		for (Novidea_HPC__Commission_Rate__c commissionRate : commissionRates) {
			String carrierAndProdDefIds =
				(String) commissionRate.Novidea_HPC__Agreement__r.Novidea_HPC__Carrier__c +
				(String) commissionRate.Novidea_HPC__Product_Definition__c;
			commissionComRatesByCarrierAndProdDef.put(carrierAndProdDefIds, commissionRate.Novidea_HPC__Percentage__c);
		}

		return commissionComRatesByCarrierAndProdDef;
	}
}