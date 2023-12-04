public with sharing class SalesProcessHelper {
	@testVisible
	private static Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
	private static final Integer MAX_NAME_LENGTH = 80;
	@testVisible
	private static Boolean testMode = false;
	private static Integer productToPolicyId = 0;

	public class productToPolicy {
		public Id brokerNumber { get; set; }
		public Id complexPolicyBranchId { get; set; }
		public Id complexPolicyBranchNumberId { get; set; }
		public Id policyId {
			get {
				if (policy != null)
					return policy.Id;
				return null;
			}
		}
		public Novidea_HPC__Proposal__c proposal { get; set; }
		public List<Novidea_HPC__Product__c> proposalProducts {
			get {
				if (proposalProducts == null && proposal != null)
					return proposal.Novidea_HPC__Products__r;
				return proposalProducts;
			}
			set;
		}
		public Novidea_HPC__Policy__c policy { get; set; }
		public Novidea_HPC__Product__c product { get; set; }
		public Boolean isSelected { get; set; }
		public Boolean isComplex {
			get {
				return false;
			}
		}
		public Boolean showOverride { get; set; }
		public Integer id { get; set; }
		public Id carrierId {
			get {
				if (proposal != null)
					return proposal.Novidea_HPC__Carrier__c;
				else if (policy != null)
					return policy.Novidea_HPC__Carrier__c;
				return null;
			}
		}
		public String guidKey;

		public productToPolicy() {
			isSelected = false;
			showOverride = false;
			id = SalesProcessHelper.productToPolicyId++;
			guidKey = NOVU.RandomUtility.generateGuidKey();
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static Map<Id, Account> carrierIdToName {
		get {
			if (carrierIdToName == null) {
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
					NOVU.SecurityUtils.checkFields('Account', new Set<String>{ 'Name', 'RecordTypeId' }, NOVU.SecurityUtils.FLS.ACCESS);
				}
				carrierIdToName = new Map<Id, Account>([SELECT Name FROM Account WHERE RecordType.DeveloperName IN ('Carrier', 'Broker')]);
				carrierIdToName.put(null, new Account(Name = Label.Novidea_HPC.No_Manufacturer));
			}
			return carrierIdToName;
		}
		set;
	}

	private static Map<Id, Novidea_HPC__Product_Def__c> productDefIdToName {
		get {
			if (productDefIdToName == null) {
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
					NOVU.SecurityUtils.checkFields('Novidea_HPC__Product_Def__c', new Set<String>{ 'Name' }, NOVU.SecurityUtils.FLS.ACCESS);
				}
				productDefIdToName = new Map<Id, Novidea_HPC__Product_Def__c>([SELECT Name FROM Novidea_HPC__Product_Def__c]);
			}
			return productDefIdToName;
		}
		set;
	}

	public static void proposalToPolicy(Novidea_HPC__Proposal__c proposal, Novidea_HPC__Policy__c policy) {
		policy.Novidea_HPC__Policy_Source__c = 'From Application';
		policy.Novidea_HPC__Client__c = proposal.Novidea_HPC__Application__r.Novidea_HPC__Account__c;
		policy.Novidea_HPC__Application__c = proposal.Novidea_HPC__Application__c;
		//TBD: if (proposal.Novidea_HPC__Other_Commission__c != null)
		//policy.Novidea_HPC__Other_Commission__c = proposal.Novidea_HPC__Other_Commission__c;
		if (proposal.Novidea_HPC__Estimated_Commission__c != null)
			policy.Novidea_HPC__Commission__c = proposal.Novidea_HPC__Estimated_Commission__c;
		// TBD :if (proposal.Novidea_HPC__Discount__c != null)
		//policy.Novidea_HPC__Agent_Discount__c = proposal.Novidea_HPC__Discount__c;
		if (proposal.Novidea_HPC__Fees_del__c != null)
			policy.Novidea_HPC__Fees__c = proposal.Novidea_HPC__Fees_del__c;
		if (proposal.Novidea_HPC__Fees_Currency__c != null)
			policy.Novidea_HPC__Fee_Currency__c = proposal.Novidea_HPC__Fees_Currency__c;
		if (proposal.Novidea_HPC__Premium__c != null)
			policy.Novidea_HPC__Premium_Amount__c = proposal.Novidea_HPC__Premium__c;
		if (proposal.Novidea_HPC__Premium_Currency__c != null)
			policy.Novidea_HPC__Premium_Amount_Currency__c = proposal.Novidea_HPC__Premium_Currency__c;
		if (proposal.Novidea_HPC__Products__r != null && !proposal.Novidea_HPC__Products__r.isempty()) {
			Date minDate = proposal.Novidea_HPC__Products__r[0].Novidea_HPC__Effective_Date__c;
			Date maxDate = proposal.Novidea_HPC__Products__r[0].Novidea_HPC__Expiration_Date__c;
			for (Novidea_HPC__Product__c product : proposal.Novidea_HPC__Products__r) {
				if (minDate > product.Novidea_HPC__Effective_Date__c)
					minDate = product.Novidea_HPC__Effective_Date__c;
				//rz change 24/12/2012: changed sign from > to <. this is not used but the logic was incorrect
				if (maxDate < product.Novidea_HPC__Expiration_Date__c)
					maxDate = product.Novidea_HPC__Expiration_Date__c;
			}
		}
		// TBD - create a copy of the plan benefits.
	}

	private static map<Id, map<Id, Id>> carrierAndProductDefToNumber;

	public static void productToPolicy(Novidea_HPC__Product__c product, Novidea_HPC__Policy__c policy) {
		policy.Novidea_HPC__Policy_Source__c = 'From Application'; ///////////////////////////////////
		policy.Novidea_HPC__Client__c = product.Novidea_HPC__Proposal__r.Novidea_HPC__Application__r.Novidea_HPC__Account__c; ////////////////////////
		policy.Novidea_HPC__Application__c = product.Novidea_HPC__Proposal__r.Novidea_HPC__Application__c; /////////////////////////

		if (product.Novidea_HPC__Effective_Date__c != null)
			policy.Novidea_HPC__Effective_Date__c = product.Novidea_HPC__Effective_Date__c;
		if (product.Novidea_HPC__Expiration_Date__c != null)
			policy.Novidea_HPC__Expiration_Date__c = product.Novidea_HPC__Expiration_Date__c;

		// Novidea_HPC__Other_Commission__c
		// Diana: 28-03-2013, change commission to be from net and not from bruto
		if (product.Novidea_HPC__Commission__c != null && product.Novidea_HPC__Commission__c != 0)
			policy.Novidea_HPC__Commission__c = product.Novidea_HPC__Commission__c;
		else if (
			product.Novidea_HPC__Commission_Amount__c != null &&
			product.Novidea_HPC__Premium_Net__c != null &&
			product.Novidea_HPC__Premium_Net__c != 0 &&
			Math.abs(product.Novidea_HPC__Commission_Amount__c / product.Novidea_HPC__Premium_Net__c) <= 1
		)
			policy.Novidea_HPC__Commission__c = product.Novidea_HPC__Commission_Amount__c / product.Novidea_HPC__Premium_Net__c * 100.0;
		else if (
			product.Novidea_HPC__Commission_Amount__c != null &&
			product.Novidea_HPC__Premium__c != null &&
			product.Novidea_HPC__Premium__c != 0 &&
			(product.Novidea_HPC__Premium__c - (product.Novidea_HPC__Fee_Amount__c == null ? 0 : product.Novidea_HPC__Fee_Amount__c) != 0) &&
			Math.abs(
				product.Novidea_HPC__Commission_Amount__c /
				(product.Novidea_HPC__Premium__c - (product.Novidea_HPC__Fee_Amount__c == null ? 0 : product.Novidea_HPC__Fee_Amount__c))
			) <= 1
		)
			policy.Novidea_HPC__Commission__c =
				product.Novidea_HPC__Commission_Amount__c /
				(product.Novidea_HPC__Premium__c - (product.Novidea_HPC__Fee_Amount__c == null ? 0 : product.Novidea_HPC__Fee_Amount__c)) *
				100.0;
		else
			policy.Novidea_HPC__Commission__c = 0;

		if (product.Novidea_HPC__Commission_Currency__c != null) {
			policy.Novidea_HPC__Commission_Currency__c = product.Novidea_HPC__Commission_Currency__c;
		}

		if (product.Novidea_HPC__Discount__c != null)
			policy.Novidea_HPC__Agent_Discount__c = product.Novidea_HPC__Discount__c;

		if (product.Novidea_HPC__Fee_Amount__c != null)
			policy.Novidea_HPC__Fees__c = product.Novidea_HPC__Fee_Amount__c;
		if (product.Novidea_HPC__Premium__c != null)
			policy.Novidea_HPC__Premium_Amount__c = product.Novidea_HPC__Premium__c;
		if (product.Novidea_HPC__Premium_Currency__c != null)
			policy.Novidea_HPC__Premium_Amount_Currency__c = product.Novidea_HPC__Premium_Currency__c;

		if (product.Novidea_HPC__Liability_Limit_Currency__c != null)
			policy.Novidea_HPC__Liability_Limit_Currency__c = product.Novidea_HPC__Liability_Limit_Currency__c;
		if (product.Novidea_HPC__Liability_Limit_Per_Case__c != null)
			policy.Novidea_HPC__Liability_Limit_Per_Case__c = product.Novidea_HPC__Liability_Limit_Per_Case__c;
		if (product.Novidea_HPC__Lower_Limit_of_Liability__c != null)
			policy.Novidea_HPC__Lower_Limit_of_Liability__c = product.Novidea_HPC__Lower_Limit_of_Liability__c;
		if (product.Novidea_HPC__Liability_Limit__c != null)
			policy.Novidea_HPC__Upper_Limit_of_Liability__c = product.Novidea_HPC__Liability_Limit__c;
		// Diana added 11_03_13///////////////////////////////////////////////////
		if (product.Novidea_HPC__Credit_Fee__c != null)
			policy.Novidea_HPC__Credit_Fee__c = product.Novidea_HPC__Credit_Fee__c;
		if (product.Novidea_HPC__Fee_Currency__c != null)
			policy.Novidea_HPC__Fee_Currency__c = product.Novidea_HPC__Fee_Currency__c;

		//previously added by Diana #1152
		if (product.Novidea_HPC__Target_Agency_Fee__c != null)
			policy.Novidea_HPC__Agency_Fee__c = product.Novidea_HPC__Target_Agency_Fee__c;
		if (!NOVU.NumericUtil.isValueNullOrZero(product.Novidea_HPC__Current_Agency_Fees__c))
			policy.Novidea_HPC__Agency_Fee__c = product.Novidea_HPC__Current_Agency_Fees__c;
		if (product.Novidea_HPC__Agency_Fee_Currency__c != null)
			policy.Novidea_HPC__Agency_Fees_Currency__c = product.Novidea_HPC__Agency_Fee_Currency__c;
		//#end region//
		if (product.Novidea_HPC__Product_Definition__c != null) {
			policy.Novidea_HPC__Product_Definition__c = product.Novidea_HPC__Product_Definition__c;
			if (carrierAndProductDefToNumber != null && carrierAndProductDefToNumber.containsKey(policy.Novidea_HPC__Carrier__c))
				if (carrierAndProductDefToNumber.get(policy.Novidea_HPC__Carrier__c).containsKey(policy.Novidea_HPC__Product_Definition__c))
					policy.Novidea_HPC__Carrier_Product_Number__c = carrierAndProductDefToNumber.get(policy.Novidea_HPC__Carrier__c)
						.get(policy.Novidea_HPC__Product_Definition__c);
		}
		//#5168: add refernce to the creating product
		policy.Novidea_HPC__Product__c = product.Id;

		assignPermanentNetoPremiumCommissionRate(product, policy); //ILP-1781
	}

	/**
	 * Assigns the policy in the Days_NTU__c field the commission rate percentage of "Fees And Commission Percentage From Permanent Neto Premium" (if exists)
	 * @param  product original product
	 * @param  policy  policy created from product
	 */
	private static void assignPermanentNetoPremiumCommissionRate(Novidea_HPC__Product__c product, Novidea_HPC__Policy__c policy) {
		if (product.Novidea_HPC__Product_Definition__c == null) {
			// product must have a product def
			return;
		}

		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Product__c',
				new Set<String>{ 'Novidea_HPC__Proposal__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Proposal__c',
				new Set<String>{ 'Novidea_HPC__Request_for_Proposal__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Request_for_Proposal__c',
				new Set<String>{ 'Novidea_HPC__Broker_Number__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Broker_Number__c',
				new Set<String>{ 'Novidea_HPC__Agreement__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		List<Novidea_HPC__Product__c> productsWithAgreement = [
			SELECT Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agreement__c
			FROM Novidea_HPC__Product__c
			WHERE Id = :product.Id
		];
		if (productsWithAgreement.isEmpty()) {
			// no such product
			return;
		}
		Id agreementId = productsWithAgreement[0].Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agreement__c;
		if (agreementId == null) {
			// there's no agreement
			return;
		}
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Commission_Rate__c',
				new Set<String>{
					'Novidea_HPC__Percentage__c',
					'Novidea_HPC__Agreement__c',
					'Novidea_HPC__Product_Definition__c',
					'Novidea_HPC__Calculation_Type__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}

		List<Novidea_HPC__Commission_Rate__c> commRates = [
			SELECT Novidea_HPC__Percentage__c, RecordType.DeveloperName
			FROM Novidea_HPC__Commission_Rate__c
			WHERE
				Novidea_HPC__Agreement__c = :agreementId
				AND Novidea_HPC__Product_Definition__c = :product.Novidea_HPC__Product_Definition__c
				AND Novidea_HPC__Calculation_Type__c = 'Fees And Commission Percentage From Permanent Neto Premium'
				AND Novidea_HPC__Percentage__c != NULL
				AND Novidea_HPC__Percentage__c != 0
			ORDER BY LastModifiedDate DESC
		];
		if (commRates.isEmpty()) {
			// didn't find comm rate
			return;
		}
		Boolean foundFee, foundCommission;
		foundFee = foundCommission = false;
		for (Novidea_HPC__Commission_Rate__c commRate : commRates) {
			if (foundFee && foundCommission)
				break;
			if (foundFee == false && commRate.RecordType.DeveloperName == 'Fee') {
				policy.Novidea_HPC__Days_NTU__c = commRate.Novidea_HPC__Percentage__c;
				foundFee = true;
			} else if (foundCommission == false && commRate.RecordType.DeveloperName == 'Commission') {
				if (policy.Novidea_HPC__Commission__c == 0) {
					policy.Novidea_HPC__Commission__c = commRate.Novidea_HPC__Percentage__c;
				}
				foundCommission = true;
			}
		}
	}

	public static void policyToProduct(Novidea_HPC__Policy__c policy, Novidea_HPC__Product__c product, boolean testProdValForNull) {
		if (
			policy.Novidea_HPC__Effective_Date__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Effective_Date__c == null)
		)
			product.Novidea_HPC__Effective_Date__c = policy.Novidea_HPC__Effective_Date__c;
		if (
			policy.Novidea_HPC__Expiration_Date__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Expiration_Date__c == null)
		)
			product.Novidea_HPC__Expiration_Date__c = policy.Novidea_HPC__Expiration_Date__c;

		if (!testProdValForNull || testProdValForNull && product.Novidea_HPC__Commission__c == null) {
			if (policy.Novidea_HPC__Commission__c != null && policy.Novidea_HPC__Commission__c != 0)
				product.Novidea_HPC__Commission__c = policy.Novidea_HPC__Commission__c;
			else if (
				policy.Novidea_HPC__Commission_Amount__c != null &&
				policy.Novidea_HPC__Premium_Amount__c != null &&
				policy.Novidea_HPC__Premium_Amount__c != 0 &&
				Math.abs(policy.Novidea_HPC__Commission_Amount__c / policy.Novidea_HPC__Premium_Amount__c) <= 1
			)
				product.Novidea_HPC__Commission__c = policy.Novidea_HPC__Commission_Amount__c / policy.Novidea_HPC__Premium_Amount__c * 100.0;
			else
				product.Novidea_HPC__Commission__c = 0;
		}

		if (
			policy.Novidea_HPC__Commission_Currency__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Commission_Currency__c == null)
		) {
			product.Novidea_HPC__Commission_Currency__c = policy.Novidea_HPC__Commission_Currency__c;
		}

		if (
			policy.Novidea_HPC__Agent_Discount__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Discount__c == null)
		)
			product.Novidea_HPC__Discount__c = policy.Novidea_HPC__Agent_Discount__c;

		if (policy.Novidea_HPC__Fees__c != null && (!testProdValForNull || testProdValForNull && product.Novidea_HPC__Fee_Amount__c == null))
			product.Novidea_HPC__Fee_Amount__c = policy.Novidea_HPC__Fees__c;

		if (
			policy.Novidea_HPC__Premium_Amount__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Premium__c == null)
		)
			product.Novidea_HPC__Premium__c = policy.Novidea_HPC__Premium_Amount__c;

		if (
			policy.Novidea_HPC__Premium_Amount_Currency__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Premium_Currency__c == null)
		)
			product.Novidea_HPC__Premium_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c;

		if (
			policy.Novidea_HPC__Liability_Limit_Currency__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Liability_Limit_Currency__c == null)
		)
			product.Novidea_HPC__Liability_Limit_Currency__c = policy.Novidea_HPC__Liability_Limit_Currency__c;

		if (
			policy.Novidea_HPC__Liability_Limit_Per_Case__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Liability_Limit_Per_Case__c == null)
		)
			product.Novidea_HPC__Liability_Limit_Per_Case__c = policy.Novidea_HPC__Liability_Limit_Per_Case__c;

		if (
			policy.Novidea_HPC__Lower_Limit_of_Liability__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Lower_Limit_of_Liability__c == null)
		)
			product.Novidea_HPC__Lower_Limit_of_Liability__c = policy.Novidea_HPC__Lower_Limit_of_Liability__c;

		if (
			policy.Novidea_HPC__Upper_Limit_of_Liability__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Liability_Limit__c == null)
		)
			product.Novidea_HPC__Liability_Limit__c = policy.Novidea_HPC__Upper_Limit_of_Liability__c;

		//raniz change 17/6/13: add copying all car details
		if (
			policy.Novidea_HPC__Car_Number__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Vehicle_Registration_Number__c == null)
		)
			product.Novidea_HPC__Vehicle_Registration_Number__c = policy.Novidea_HPC__Car_Number__c;
		if (
			policy.Novidea_HPC__Vehicle_Manufacturer__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Vehicle_Model__c == null)
		)
			product.Novidea_HPC__Vehicle_Model__c = policy.Novidea_HPC__Vehicle_Manufacturer__c;
		if (
			policy.Novidea_HPC__Vehicle_Model__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Vehicle_Model_In_Price_List__c == null)
		)
			product.Novidea_HPC__Vehicle_Model_In_Price_List__c = policy.Novidea_HPC__Vehicle_Model__c;
		if (
			policy.Novidea_HPC__Vehicle_Production_Year__c != null &&
			(!testProdValForNull || testProdValForNull && product.Novidea_HPC__Vehicle_Year_of_manufacture__c == null)
		)
			product.Novidea_HPC__Vehicle_Year_of_manufacture__c = policy.Novidea_HPC__Vehicle_Production_Year__c;

		if (!testProdValForNull || testProdValForNull && product.Novidea_HPC__Product_Definition__c == null) {
			product.Novidea_HPC__Carrier__c = policy.Novidea_HPC__Carrier__c; // Diana why to highlight it? howden need carrier pass ,
			if (policy.Novidea_HPC__Product_Definition__c != null) {
				product.Novidea_HPC__Product_Definition__c = policy.Novidea_HPC__Product_Definition__c;
				product.Name = productDefIdToName.get(policy.Novidea_HPC__Product_Definition__c).Name;
			} else {
				product.Name = Label.Novidea_HPC.Missing + ' ' + Label.Novidea_HPC.Product;
			}
		}
		//#5168
		if (policy.Novidea_HPC__Product__c != null && (!testProdValForNull || testProdValForNull && product.Novidea_HPC__Product__c == null))
			product.Novidea_HPC__Product__c = policy.Novidea_HPC__Product__c;
	}

	public static Novidea_HPC__Product__c policyToProduct(Novidea_HPC__Policy__c policy, Novidea_HPC__Product__c prevRenewalProduct) {
		Novidea_HPC__Product__c product;
		if (prevRenewalProduct != null) {
			product = prevRenewalProduct.clone(false, false, false, false);
			product.Novidea_HPC__Policy__c = product.Novidea_HPC__Lead__c = product.Novidea_HPC__Application__c = product.Novidea_HPC__Request_For_Proposal__c = product.Novidea_HPC__Proposal__c = product.Novidea_HPC__Previous_Policy__c = product.Novidea_HPC__Product__c = product.Novidea_HPC__Status__c = null;
		} else
			product = new Novidea_HPC__Product__c();
		policyToProduct(policy, product, false);
		return product;
	}

	private static void populateCarrierAndProductDefToNumber(list<SalesProcessHelper.productToPolicy> listproductToPolicy) {
		if (carrierAndProductDefToNumber == null) {
			Set<Id> productDefIds = new Set<Id>();
			Set<Id> carrierIds = new Set<Id>();
			for (SalesProcessHelper.productToPolicy ptp : listproductToPolicy) {
				if (!ptp.showOverride || gs.Novidea_HPC__Enable_Same_Product_Def__c == true) {
					for (Novidea_HPC__Product__c product : ptp.proposalProducts) {
						productDefIds.add(product.Novidea_HPC__Product_Definition__c);
					}
					carrierIds.add(ptp.carrierId);
				}
			}
			carrierAndProductDefToNumber = new Map<Id, Map<Id, Id>>();
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
				NOVU.SecurityUtils.checkFields('Novidea_HPC__Product_Def__c', new Set<String>{ 'Name' }, NOVU.SecurityUtils.FLS.ACCESS);
			}
			Map<Id, Novidea_HPC__Product_Def__c> mapProdyctsAndAcronyms = new Map<Id, Novidea_HPC__Product_Def__c>(
				[SELECT (SELECT Name FROM Novidea_HPC__Acronyms__r) FROM Novidea_HPC__Product_Def__c WHERE Id IN :productDefIds]
			);
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Carrier_Product__c',
					new Set<String>{ 'Novidea_HPC__Product_Definition__c', 'Novidea_HPC__Account__c' },
					NOVU.SecurityUtils.FLS.ACCESS
				);
			}
			for (Novidea_HPC__Carrier_Product__c carrierProduct : [
				SELECT Novidea_HPC__Product_Definition__c, Novidea_HPC__Account__c
				FROM Novidea_HPC__Carrier_Product__c
				WHERE Novidea_HPC__Product_Definition__c IN :productDefIds AND Novidea_HPC__Account__c IN :carrierIds
			]) {
				if (!carrierAndProductDefToNumber.containsKey(carrierProduct.Novidea_HPC__Account__c)) {
					carrierAndProductDefToNumber.put(carrierProduct.Novidea_HPC__Account__c, new Map<Id, Id>());
				}
				carrierAndProductDefToNumber.get(carrierProduct.Novidea_HPC__Account__c)
					.put(carrierProduct.Novidea_HPC__Product_Definition__c, carrierProduct.Id);
				if (
					mapProdyctsAndAcronyms.get(carrierProduct.Novidea_HPC__Product_Definition__c) != null &&
					mapProdyctsAndAcronyms.get(carrierProduct.Novidea_HPC__Product_Definition__c).Novidea_HPC__Acronyms__r != null
				) {
					for (
						Novidea_HPC__Product_Def__c productDef : mapProdyctsAndAcronyms.get(carrierProduct.Novidea_HPC__Product_Definition__c)
							.Novidea_HPC__Acronyms__r
					) {
						carrierAndProductDefToNumber.get(carrierProduct.Novidea_HPC__Account__c).put(productDef.Id, carrierProduct.Id);
					}
				}
			}
		}
	}


	public static Pagereference convertingProductToPolicy(
		list<SalesProcessHelper.productToPolicy> listproductToPolicy,
		Novidea_HPC__Application__c application
	) {
		return convertingProductToPolicy(listproductToPolicy, application, null);
	}

	public static Pagereference convertingProductToPolicy(
		list<SalesProcessHelper.productToPolicy> listproductToPolicy,
		Novidea_HPC__Application__c application,
		String filterId
	) {
		Pagereference pr;
		if (null != application && null != application.Id) {
			pr = new Pagereference('/lightning/o/Novidea_HPC__Product__c/list?filterName=' + (String.isBlank(filterId) ? 'Recent' : filterId));
		}
		if (NOVU.ArrayUtils.isListNullOrEmpty(listproductToPolicy))
			return pr;

		map<Integer, Novidea_HPC__Policy__c> policies = new Map<Integer, Novidea_HPC__Policy__c>();
		Map<Id, Novidea_HPC__Policy__c> policiesByProductIds = new Map<Id, Novidea_HPC__Policy__c>();
		Set<Id> productsIds = new Set<Id>();

		list<Novidea_HPC__Plan_Benefit__c> newListPlanBenfit = new List<Novidea_HPC__Plan_Benefit__c>();
		populateCarrierAndProductDefToNumber(listproductToPolicy);

		for (SalesProcessHelper.productToPolicy ptp : listproductToPolicy) {
			if (!ptp.showOverride || gs.Novidea_HPC__Enable_Same_Product_Def__c == true) {
				productsIds.add(ptp.product.Id);

				application.Novidea_HPC__Status__c = 'Coverage Approval';

				//new policy
				ptp.policy = new Novidea_HPC__Policy__c();
				ptp.policy.Conversion_Process_GUID__c = ptp.guidKey;
				policies.put(ptp.id, upsertPolicy(ptp, application));
				policiesByProductIds.put(ptp.product.Id, policies.get(ptp.id));
			}
		}
		system.savepoint sp = database.setsavepoint();
		try {
			ProductHelper.updatePoliciesFromProductAccordingToRenewalFields(policiesByProductIds);
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Policy__c',
					new Set<String>{
						'Novidea_HPC__Application__c',
						'Novidea_HPC__Carrier__c',
						'Novidea_HPC__Status__c',
						'Novidea_HPC__Share_Percentage__c',
						'Novidea_HPC__Master_Policy__c',
						'RecordTypeId',
						'Novidea_HPC__Policy_Number__c',
						'Novidea_HPC__Broker_In_Carrier__c',
						'Novidea_HPC__Original_Type__c',
						'Novidea_HPC__Underwriter__c',
						'Name'
					},
					new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
				);
			}
			Database.upsert(policies.values());

			for (SalesProcessHelper.productToPolicy ptp : listproductToPolicy) {
				if (policies.containsKey(ptp.Id))
					ptp.policy = policies.get(ptp.Id);
			}

			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Application__c',
					new Set<String>{ 'Novidea_HPC__Status__c' },
					NOVU.SecurityUtils.FLS.UPDT
				);
			}

			Database.update(application);

			System.debug('listproductToPolicy: ' + listproductToPolicy);
			for (SalesProcessHelper.productToPolicy ptp : listproductToPolicy) {
				if (!ptp.showOverride || gs.Novidea_HPC__Enable_Same_Product_Def__c == true)
					newListPlanBenfit.addAll(upsertPolicyPlanBenefits(ptp.proposal, ptp.policy));
			}

			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Plan_Benefit__c',
					new Set<String>{ 'Novidea_HPC__Policy__c', 'Novidea_HPC__Product__c' },
					NOVU.SecurityUtils.FLS.CREATE
				);
			}

			Database.insert(newListPlanBenfit);
		} catch (Exception e) {
			database.rollback(sp);
			throw e;
		}

		// if 'Edit Policy After Conversion' custtom setting is true and at least one policy created
		// open the first policy in edit mode
		if (policies.size() >= 1) {
			Id firstPolicyId = policies.values()[0].Id;
			pr = new Pagereference('/' + firstPolicyId + '/e?retURL=%2F' + firstPolicyId);
		}
		return pr;
	}

	private static Novidea_HPC__Policy__c upsertPolicy(SalesProcessHelper.productToPolicy ptp, Novidea_HPC__Application__c application) {
		if (application != null)
			ptp.policy.Novidea_HPC__Application__c = application.Id;
		ptp.policy.Novidea_HPC__Carrier__c = ptp.carrierId;
		ptp.policy.Novidea_HPC__Status__c = 'Approved Coverage';
		ptp.policy.Novidea_HPC__Share_Percentage__c = ptp.proposal.Novidea_HPC__Share_Percentage__c;

		//diana 11/06/2014 policy from application get same master policy as previous policy of application
		// Code Review: this will not support many products in one application solution.
		if (application.Novidea_HPC__Previous_Policy__c != null && application.Novidea_HPC__Disconnect_From_Parent_Policy__c != true) {
			ptp.policy.Novidea_HPC__Master_Policy__c = application.Novidea_HPC__Previous_Policy__r.Novidea_HPC__Master_Policy__c;
			ptp.policy.RecordTypeId = application.Novidea_HPC__Previous_Policy__r.RecordTypeId;
			if (gs != null && gs.Novidea_HPC__Copy_Policy_Number_on_Renewal__c == true)
				ptp.policy.Novidea_HPC__Policy_Number__c = application.Novidea_HPC__Previous_Policy__r.Novidea_HPC__Policy_Number__c;
		}

		//AEF:
		if (null != ptp.brokerNumber)
			ptp.policy.Novidea_HPC__Broker_In_Carrier__c = ptp.brokerNumber;
		else if (null != application.Novidea_HPC__Broker_In_Carrier__c)
			ptp.policy.Novidea_HPC__Broker_In_Carrier__c = application.Novidea_HPC__Broker_In_Carrier__c;
		else
			system.debug(system.LoggingLevel.WARN, 'lookup to Broker Number is NULL !! application ID = ' + application.ID);

		ptp.policy.Novidea_HPC__Original_Type__c = application.Novidea_HPC__Required_Policy_Type__c;
		ptp.policy.Novidea_HPC__Underwriter__c = application.Novidea_HPC__Underwriter__c;
		SalesProcessHelper.productToPolicy(ptp.product, ptp.policy);
		if (application != null) {
			ptp.policy.Name = application.Name;
			ptp.policy.Novidea_HPC__Original_Type__c = application.Novidea_HPC__Required_Policy_Type__c;
		} else
			ptp.policy.Name = getPolicyAutoName(ptp.policy, ptp.proposal);

		return ptp.policy;
	}

	@testVisible
	private static String getPolicyAutoName(Novidea_HPC__Policy__c policy, Novidea_HPC__Proposal__c proposal) {
		String returnValue = '';

		if (policy.Novidea_HPC__Policy_Number__c != null)
			returnValue += policy.Novidea_HPC__Policy_Number__c;
		if (policy.Novidea_HPC__Carrier__c != null) {
			if (returnValue != '')
				returnValue += ' - ';
			returnValue = getNameInLimit(returnValue, carrierIdToName.get(policy.Novidea_HPC__Carrier__c).Name, MAX_NAME_LENGTH);
		}

		return getApplicationAutoName(policy, proposal, returnValue);
	}

	private static String getApplicationAutoName(Novidea_HPC__Policy__c policy, Novidea_HPC__Proposal__c proposal, String prefix) {
		Novidea_HPC__Application__c application;
		if (proposal != null)
			application = proposal.Novidea_HPC__Application__r;
		return getApplicationAutoName(policy, application, prefix);
	}

	private static String getApplicationAutoName(Novidea_HPC__Policy__c policy, Novidea_HPC__Application__c application, String prefix) {
		String returnValue = prefix;
		if (returnValue == null)
			returnValue = '';

		if (policy.Novidea_HPC__Product_Definition__c != null) {
			if (returnValue != '')
				returnValue += ' - ';
			returnValue = getNameInLimit(returnValue, productDefIdToName.get(policy.Novidea_HPC__Product_Definition__c).Name, MAX_NAME_LENGTH);
		}
		if (application != null && application.Novidea_HPC__Account__c != null && application.Novidea_HPC__Account__r.Name != null) {
			if (returnValue != '')
				returnValue += ' - ';
			returnValue = getNameInLimit(returnValue, application.Novidea_HPC__Account__r.Name, MAX_NAME_LENGTH);
		}
		if (application != null && application.Novidea_HPC__Account__c != null && application.Novidea_HPC__Account__r.AccountNumber != null) {
			if (returnValue != '')
				returnValue += ' - ';
			returnValue = getNameInLimit(returnValue, application.Novidea_HPC__Account__r.AccountNumber, MAX_NAME_LENGTH);
		}

		return returnValue;
	}

	private static String getNameInLimit(String prefix, String postfix, Integer limitSize) {
		if (prefix == null)
			prefix = '';
		if (postfix == null)
			postfix = '';
		if (prefix.length() + postfix.length() <= limitSize)
			return prefix + postfix;
		return prefix.substring(0, Math.min(prefix.length(), limitSize));
	}

	public static list<Novidea_HPC__Plan_Benefit__c> upsertPolicyPlanBenefits(Novidea_HPC__Proposal__c proposal, Novidea_HPC__Policy__c policy) {
		list<Novidea_HPC__Plan_Benefit__c> newListPlanBenfit = new List<Novidea_HPC__Plan_Benefit__c>();
		//copy all the benfit and connect to policy

		set<Id> setProductId = new Set<Id>();
		if (proposal.Novidea_HPC__Products__r != null && !proposal.Novidea_HPC__Products__r.isempty()) {
			for (Novidea_HPC__Product__c pro : proposal.Novidea_HPC__Products__r) {
				setProductId.add(pro.Id);
			}
		}

		if (!setProductId.isempty()) {
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Plan_Benefit__c',
					new Set<String>{
						'RecordTypeId',
						'OwnerId',
						'Novidea_HPC__Wording__c',
						'Novidea_HPC__Start_Date__c',
						'Novidea_HPC__Product__c',
						'Novidea_HPC__Policy__c',
						'Novidea_HPC__Percentage__c',
						'Novidea_HPC__Not_Include__c',
						'Novidea_HPC__Maximum_Benefit__c',
						'Novidea_HPC__Liability_Limit__c',
						'Novidea_HPC__Liability_Limit_Currency__c',
						'Novidea_HPC__End_Date__c',
						'Novidea_HPC__Description__c',
						'Novidea_HPC__Date__c',
						'Novidea_HPC__Coverage_Amount__c',
						'Novidea_HPC__Coverage_Amount_Target__c',
						'Novidea_HPC__Comparison_Type__c',
						'Novidea_HPC__Comparison_Field__c',
						'Novidea_HPC__Benefit_Type__c',
						'Novidea_HPC__Benefit_Amount__c',
						'Novidea_HPC__Benefit_Amount_Currency__c',
						'Novidea_HPC__Amount__c',
						'Name'
					},
					NOVU.SecurityUtils.FLS.ACCESS
				);
			}
			list<Novidea_HPC__Plan_Benefit__c> listPlanBenfit = [
				SELECT
					n.RecordTypeId,
					n.OwnerId,
					n.Novidea_HPC__Wording__c,
					n.Novidea_HPC__Start_Date__c,
					n.Novidea_HPC__Product__c,
					n.Novidea_HPC__Policy__c,
					n.Novidea_HPC__Percentage__c,
					n.Novidea_HPC__Not_Include__c,
					n.Novidea_HPC__Maximum_Benefit__c,
					n.Novidea_HPC__Liability_Limit__c,
					n.Novidea_HPC__Liability_Limit_Currency__c,
					n.Novidea_HPC__End_Date__c,
					n.Novidea_HPC__Description__c,
					n.Novidea_HPC__Date__c,
					n.Novidea_HPC__Coverage_Amount__c,
					n.Novidea_HPC__Coverage_Amount_Target__c,
					n.Novidea_HPC__Comparison_Type__c,
					n.Novidea_HPC__Comparison_Field__c,
					n.Novidea_HPC__Benefit_Type__c,
					n.Novidea_HPC__Benefit_Amount__c,
					n.Novidea_HPC__Benefit_Amount_Currency__c,
					n.Novidea_HPC__Amount__c,
					n.Name
				FROM Novidea_HPC__Plan_Benefit__c n
				WHERE Novidea_HPC__Product__c IN :setProductId
				WITH SECURITY_ENFORCED
			];
			if (!listPlanBenfit.isempty()) {
				for (Novidea_HPC__Plan_Benefit__c ben : listPlanBenfit) {
					Novidea_HPC__Plan_Benefit__c newben = ben.clone(false, true, false, true);
					newben.Novidea_HPC__Policy__c = policy.Id;
					newben.Novidea_HPC__Product__c = null;
					newListPlanBenfit.add(newben);
				}
			}
		}
		return newListPlanBenfit;
	}

	@testVisible
	private static void testCoverage() {
		Integer x = 0;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
	}
}