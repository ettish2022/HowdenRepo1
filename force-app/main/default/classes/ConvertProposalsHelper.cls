public with sharing class ConvertProposalsHelper {
	private static final Novidea_HPC__General_Switches__c DEFAULT_GENERAL_SWITCHES;
	@TestVisible
	private static final String CONVERTED = 'Converted';
	@TestVisible
	private static final String REJECTED = 'Rejected';
	@TestVisible
	private static final String NTU = 'NTU';
	@TestVisible
	private static final String COVERAGE_CONFIRMATION = 'Coverage Confirmation';

	static {
		DEFAULT_GENERAL_SWITCHES = Novidea_HPC__General_Switches__c.getInstance('Default');
	}

	public static PageReference convertProductsToPolicies(
		Novidea_HPC__Application__c application,
		List<Novidea_HPC__Proposal__c> listAllProposals,
		List<SalesProcessHelper.productToPolicy> onlySelectedProposalAcceptedProudcsList,
		Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers,
		String selectedProfitCenter
	) {
		return convertProductsToPolicies(application, listAllProposals, onlySelectedProposalAcceptedProudcsList, brokerNumbers, selectedProfitCenter, null);
	}

	public static PageReference convertProductsToPolicies(
		Novidea_HPC__Application__c application,
		List<Novidea_HPC__Proposal__c> listAllProposals,
		List<SalesProcessHelper.productToPolicy> onlySelectedProposalAcceptedProudcsList,
		Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers,
		String selectedProfitCenter,
		String filterId
	) {
		Set<Novidea_HPC__Product__c> propProducts = new Set<Novidea_HPC__Product__c>();
		List<Novidea_HPC__Proposal__c> proposalsForUpdate = new List<Novidea_HPC__Proposal__c>();
		Map<Id, Decimal> sharePercentageByProductDefId = new Map<Id, Decimal>();

		setProductsAndProposalsConvertedStatus(
			onlySelectedProposalAcceptedProudcsList,
			brokerNumbers,
			selectedProfitCenter,
			propProducts,
			proposalsForUpdate
		);
		if (
			DEFAULT_GENERAL_SWITCHES != null &&
			DEFAULT_GENERAL_SWITCHES.Novidea_HPC__Enable_Same_Product_Def__c &&
			DEFAULT_GENERAL_SWITCHES.Novidea_HPC__Enable_Sharing_Percentage__c
		) {
			for (Novidea_HPC__Proposal__c prop : proposalsForUpdate) {
				System.debug(prop.Novidea_HPC__Share_Percentage__c);
				for (Novidea_HPC__Product__c product : propProducts) {
					System.debug(product.Novidea_HPC__Product_Definition__c);
					if (product.Novidea_HPC__Proposal__c == prop.Id) {
						if (sharePercentageByProductDefId.keySet().contains(product.Novidea_HPC__Product_Definition__c)) {
							sharePercentageByProductDefId.put(
								product.Novidea_HPC__Product_Definition__c,
								sharePercentageByProductDefId.get(product.Novidea_HPC__Product_Definition__c) +
								(prop.Novidea_HPC__Share_Percentage__c != null ? prop.Novidea_HPC__Share_Percentage__c : 100)
							);
						} else {
							sharePercentageByProductDefId.put(
								product.Novidea_HPC__Product_Definition__c,
								(prop.Novidea_HPC__Share_Percentage__c != null ? prop.Novidea_HPC__Share_Percentage__c : 100)
							);
						}
					}
				}
			}
			for (Decimal percentage : sharePercentageByProductDefId.values()) {
				if (percentage != 100) {
					throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Sharing_Percentage_Error);
				}
			}
		}
		if (DEFAULT_GENERAL_SWITCHES != null && DEFAULT_GENERAL_SWITCHES.Novidea_HPC__Mark_NTU_On_Not_Converted_Proposals__c) {
			setProductsAndProposalsNTUStatus(listAllProposals, propProducts, proposalsForUpdate);
		}
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
			NOVU.SecurityUtils.checkFields('Novidea_HPC__Product__c', new Set<String>{ 'Novidea_HPC__Status__c' }, NOVU.SecurityUtils.FLS.UPDT);
		}
		Database.update(new List<Novidea_HPC__Product__c>(propProducts));
		if (!proposalsForUpdate.isEmpty()) {
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Proposal__c',
					new Set<String>{ 'Novidea_HPC__Status__c' },
					NOVU.SecurityUtils.FLS.UPDT
				);
			}
			Database.update(proposalsForUpdate);
		}
		return SalesProcessHelper.convertingProductToPolicy(onlySelectedProposalAcceptedProudcsList, application, filterId);
	}

	/**
	 *	Updates statuses of proposals, and proposal\application products to Converted.
	 *	@returns A set of ids of product application that were converted
	 */
	private static void setProductsAndProposalsConvertedStatus(
		List<SalesProcessHelper.productToPolicy> onlySelectedProposalAcceptedProudcsList,
		Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers,
		String selectedProfitCenter,
		Set<Novidea_HPC__Product__c> propProducts,
		List<Novidea_HPC__Proposal__c> proposalsForUpdate
	) {
		Set<Id> proposalsIdsForUpdate = new Set<Id>();

		// onlySelectedProposalAcceptedProudcsList contains ONLY proposal products
		for (SalesProcessHelper.productToPolicy ptp : onlySelectedProposalAcceptedProudcsList) {
			if (
				!ptp.showOverride ||
				(DEFAULT_GENERAL_SWITCHES != null &&
				DEFAULT_GENERAL_SWITCHES.Novidea_HPC__Enable_Same_Product_Def__c == true)
			) {
				ptp.product.Novidea_HPC__Status__c = CONVERTED;
				propProducts.add(ptp.product);

				ptp.proposal.Novidea_HPC__Status__c = COVERAGE_CONFIRMATION;
				if (!proposalsIdsForUpdate.contains(ptp.proposal.id)) {
					proposalsForUpdate.add(ptp.proposal);
					proposalsIdsForUpdate.add(ptp.proposal.id);
				}

				// Code Review: This might reflect in reports that are based on the Novidea_HPC__Product__c.Novidea_HPC__Status__c.
				//AEF:change status of product in the Application
				if (null != ptp.product.Novidea_HPC__Product__c)
					propProducts.add(new Novidea_HPC__Product__c(Id = ptp.product.Novidea_HPC__Product__c, Novidea_HPC__Status__c = CONVERTED));

				//AEF:change status of product in the Application
				if (null != ptp.product.Novidea_HPC__Product__r.Novidea_HPC__Product__c)
					propProducts.add(
						new Novidea_HPC__Product__c(
							Id = ptp.product.Novidea_HPC__Product__r.Novidea_HPC__Product__c,
							Novidea_HPC__Status__c = CONVERTED
						)
					);

				if (
					null !=
					ptp.product.Novidea_HPC__Broker_In_Carrier__c //AEF: for choosing profit center without page runing
				)
					ptp.brokerNumber = ptp.product.Novidea_HPC__Broker_In_Carrier__c;
				else
					ptp.brokerNumber = brokerNumbers.get(ptp.proposal.Novidea_HPC__Carrier__c).profitCentersIds.get(selectedProfitCenter);
			}
		}
	}

	private static void setProductsAndProposalsNTUStatus(
		List<Novidea_HPC__Proposal__c> listAllProposals,
		Set<Novidea_HPC__Product__c> propProducts,
		List<Novidea_HPC__Proposal__c> proposalsForUpdate
	) {
		Map<Id, List<Novidea_HPC__Product__c>> proposalIdToProducts = new Map<Id, List<Novidea_HPC__Product__c>>();

		for (Novidea_HPC__Proposal__c prop : listAllProposals) {
			if (NOVU.ArrayUtils.isListNullOrEmpty(prop.Novidea_HPC__Products__r)) {
				continue;
			}

			for (Novidea_HPC__Product__c product : prop.Novidea_HPC__Products__r) {
				if (product.Novidea_HPC__Status__c != CONVERTED && product.Novidea_HPC__Status__c != REJECTED) {
					product.Novidea_HPC__Status__c = NTU;
					propProducts.add(product);
				}
				// spilt proposal products by proposals
				List<Novidea_HPC__Product__c> productList = proposalIdToProducts.get(prop.id);
				if (productList == null) {
					productList = new List<Novidea_HPC__Product__c>();
					proposalIdToProducts.put(prop.id, productList);
				}
				productList.add(product);
			}
		}

		// update NTU to proposals that all their product are in state of NTU
		for (Id proposalId : proposalIdToProducts.keySet()) {
			Boolean allProductsAreNTU = true;
			for (Novidea_HPC__Product__c product : proposalIdToProducts.get(proposalId)) {
				if (product.Novidea_HPC__Status__c != NTU) {
					allProductsAreNTU = false;
					break;
				}
			}

			if (allProductsAreNTU == true) {
				proposalsForUpdate.add(new Novidea_HPC__Proposal__c(Id = proposalId, Novidea_HPC__Status__c = NTU));
			}
		}
	}

	public static String getProposalQueryBase(Boolean includeProdIds) {
		String productFieldsCsv = ProductHelper.getRnewalDynamicProductFields();
		String queryText =
			'SELECT Id, OwnerId, Novidea_HPC__Status__c, Novidea_HPC__Status_Date__c, Novidea_HPC__Request_for_Proposal__c,\n' +
			'Novidea_HPC__Proposal_Expiration_Date__c, Novidea_HPC__Premium__c, Novidea_HPC__Premium_Currency__c, Novidea_HPC__Net_Premium__c,\n' +
			'Novidea_HPC__Fees_del__c, Novidea_HPC__Fees_Currency__c, Novidea_HPC__Estimated_Commission__c, Novidea_HPC__Complex_Policy__c, Novidea_HPC__Share_Percentage__c,\n' +
			'Novidea_HPC__Commission_from_Fees__c, Novidea_HPC__Commission_Currency__c, Novidea_HPC__Commission_Amount__c, Novidea_HPC__Comment__c, Novidea_HPC__Carrier__c, Novidea_HPC__Carrier__r.Name,\n' +
			'Novidea_HPC__Calculated_Premium__c, Novidea_HPC__Calculated_Net_Premium__c, Novidea_HPC__Calculated_Fees__c, Novidea_HPC__Calculated_Commission__c, Novidea_HPC__Application__c, Novidea_HPC__Account__c, Name,\n' +
			'Novidea_HPC__Application__r.Novidea_HPC__Account__r.Name, Novidea_HPC__Application__r.Novidea_HPC__Account__r.AccountNumber, Novidea_HPC__Application__r.Novidea_HPC__Account__c,\n' +
			'(SELECT OwnerId, Name, Novidea_HPC__Product_Definition__c, Novidea_HPC__Product_Definition__r.Name, Novidea_HPC__Lead__c, Novidea_HPC__Proposal__c, Novidea_HPC__Status__c, Novidea_HPC__Status_Date__c,\n' +
			'Novidea_HPC__Coverages_Created__c, Novidea_HPC__Application__c, Novidea_HPC__Premium__c, Novidea_HPC__Premium_Currency__c, Novidea_HPC__Commission__c, Novidea_HPC__Commission_Amount__c,\n' +
			'Novidea_HPC__Commission_Currency__c, Novidea_HPC__Effective_Date__c, Novidea_HPC__Expiration_Date__c, Novidea_HPC__Fee_Amount__c, Novidea_HPC__Fee_Currency__c,\n' +
			'Novidea_HPC__Old_Policy_Number__c, Novidea_HPC__Budget__c, Novidea_HPC__Net_Premium__c, Novidea_HPC__Commission_Targrt__c, Novidea_HPC__Calculated_Premium__c,\n' +
			'Novidea_HPC__Calculated_Fees__c, Novidea_HPC__Calculated_Net_Premium__c, Novidea_HPC__Product_Type__c, Novidea_HPC__Expected_Renewal_Date__c, Novidea_HPC__Other_Commission__c, Novidea_HPC__Discount__c,\n' +
			'Novidea_HPC__Expected_Commission_Amount__c, Novidea_HPC__Expected_Premium__c, Novidea_HPC__Expected_Fees__c, Novidea_HPC__Premium_Target__c,\n' +
			'Novidea_HPC__Target_Agency_Fee__c, Novidea_HPC__Agency_Fee_Currency__c, Novidea_HPC__Current_Agency_Fees__c, Novidea_HPC__Previous_Policy__c,\n' +
			'Novidea_HPC__Proposal__r.Novidea_HPC__Application__r.Novidea_HPC__Account__c, Novidea_HPC__Proposal__r.Novidea_HPC__Application__c,\n' +
			'Novidea_HPC__Product__c,Novidea_HPC__Broker_In_Carrier__c, Novidea_HPC__Product__r.Novidea_HPC__Product__c,\n' + //AEF:
			'Novidea_HPC__Liability_Limit_Per_Case__c, Novidea_HPC__Lower_Limit_of_Liability__c, Novidea_HPC__Liability_Limit__c, Novidea_HPC__Liability_Limit_Currency__c,\n' +
			'Novidea_HPC__Credit_Fee__c,Novidea_HPC__Premium_Net__c ' +
			// Include fields defined in the generic fieldsets for the renewal process
			(productFieldsCsv != '' ? ',' : '') +
			productFieldsCsv +
			'\n' +
			'FROM Novidea_HPC__Products__r ' +
			((DEFAULT_GENERAL_SWITCHES != null &&
				DEFAULT_GENERAL_SWITCHES.Novidea_HPC__Mark_NTU_On_Not_Converted_Proposals__c != true)
				? 'WHERE Novidea_HPC__Status__c = \'Accepted\''
				: '') +
			(includeProdIds ? '\nAND Id IN:prodIds' : '') +
			')\n' +
			'FROM Novidea_HPC__Proposal__c\n';
		return queryText;
	}
}