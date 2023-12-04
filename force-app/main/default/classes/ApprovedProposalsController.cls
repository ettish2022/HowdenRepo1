public with sharing class ApprovedProposalsController {
	// This controller is a workaround for a problem where the autocomplete doesn't works because the component was not rendered with the original page.
	private static Novidea_HPC__General_Switches__c gs;
	private static Boolean markNTUOnNotConvertedProposals;

	static {
		gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		markNTUOnNotConvertedProposals = (gs != null && gs.Novidea_HPC__Mark_NTU_On_Not_Converted_Proposals__c == true);
	}

	public Novidea_HPC.AutoComplete_Controller dummyController { get; set; }
	public boolean hasErrors {
		get {
			if (hasErrors == null)
				return false;
			return hasErrors;
		}
		private set;
	}
	public String uiParam {
		get {
			if (uiParam == null)
				uiParam = ApexPages.currentPage().getParameters().get('ui');
			return uiParam;
		}
		set;
	}

	public class ApprovedProposalException extends Exception {
	} //TODO: Change to private
	public static Map<Id, BrokerNumberWrapper> getBrokerNumberWrapperForMultiCarriers(List<Id> carrierIds, Set<Id> productDefs) {
		Map<Id, Map<String, Id>> profitCentersIdsByCarrierId = getProfitCentersIds(carrierIds, productDefs, null);
		Map<Id, BrokerNumberWrapper> returnValue = new Map<Id, BrokerNumberWrapper>();

		for (Id carrierId : profitCentersIdsByCarrierId.keySet()) {
			BrokerNumberWrapper newBrokerNumberWrapper = new BrokerNumberWrapper();
			newBrokerNumberWrapper.profitCentersIds = profitCentersIdsByCarrierId.get(carrierId);
			newBrokerNumberWrapper.profitCenters = newBrokerNumberWrapper.profitCentersIds.keySet();
			returnValue.put(carrierId, newBrokerNumberWrapper);
		}

		return returnValue;
	}
	private static void initBrokerNumberWrapper(BrokerNumberWrapper newBrokerNumberWrapper, Id carrierId, Set<Id> productDefs) {
		newBrokerNumberWrapper.profitCentersIds = getProfitCentersIds(new List<Id>{ carrierId }, productDefs, null).get(carrierId);
		newBrokerNumberWrapper.profitCenters = newBrokerNumberWrapper.profitCentersIds.keySet();
	}
	public static Map<Id, Map<String, Id>> getProfitCentersIds(List<Id> carrierIds, Set<Id> productDefs, Id brokerFromProductId) {
		Map<Id, Map<String, Id>> profitCentersIdsByCarrierId = new Map<Id, Map<String, Id>>();
		for (Id carrierId : carrierIds) {
			profitCentersIdsByCarrierId.put(carrierId, new Map<String, Id>());
			profitCentersIdsByCarrierId.get(carrierId).put(System.Label.Novidea_HPC.None, null);
		}

		Set<Id> borkerNumbers = new Set<Id>();
		Set<Id> agreementsIds = new Set<Id>();
		//raniz: fetch all broker numbers that have commission rate for the given products
		//TODO: consider filtering by carrier and getting all required data that is achieved in query below.
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Commission_Rate__c',
				new Set<String>{ 'Novidea_HPC__Agreement__c', 'Novidea_HPC__Product_Definition__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Agreement__c',
				new Set<String>{
					'Novidea_HPC__Carrier_Producer_del__c',
					'Novidea_HPC__Carrier__c',
					'Novidea_HPC__Effective_Date__c',
					'Novidea_HPC__Expiration_Date__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Broker_Number__c',
				new Set<String>{ 'Novidea_HPC__Carrier__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		for (AggregateResult commissionRate : [
			SELECT Novidea_HPC__Agreement__c, Novidea_HPC__Agreement__r.Novidea_HPC__Carrier_Producer_del__c
			FROM Novidea_HPC__Commission_Rate__c
			WHERE
				Novidea_HPC__Product_Definition__c IN :productDefs
				AND (Novidea_HPC__Agreement__r.Novidea_HPC__Carrier_Producer_del__r.Novidea_HPC__Carrier__c IN :carrierIds
				OR Novidea_HPC__Agreement__r.Novidea_HPC__Carrier__c IN :carrierIds)
				AND (Novidea_HPC__Agreement__r.Novidea_HPC__Effective_Date__c = NULL
				OR Novidea_HPC__Agreement__r.Novidea_HPC__Effective_Date__c <= TODAY)
				AND (Novidea_HPC__Agreement__r.Novidea_HPC__Expiration_Date__c = NULL
				OR Novidea_HPC__Agreement__r.Novidea_HPC__Expiration_Date__c >= TODAY)
			GROUP BY Novidea_HPC__Agreement__c, Novidea_HPC__Agreement__r.Novidea_HPC__Carrier_Producer_del__c
		]) {
			borkerNumbers.add((Id) commissionRate.get('Novidea_HPC__Carrier_Producer_del__c'));
			agreementsIds.add((Id) commissionRate.get('Novidea_HPC__Agreement__c'));
		}

		//raniz: itterate through all broker numbers for the given carrier
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Broker_Number__c',
				new Set<String>{
					'Name',
					'Novidea_HPC__Agency__c',
					'Novidea_HPC__Carrier__c',
					'Novidea_HPC__Profit_Center__c',
					'Novidea_HPC__Agreement__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields('Account', new Set<String>{ 'Name' }, NOVU.SecurityUtils.FLS.ACCESS);
		}
		for (Novidea_HPC__Broker_Number__c brokerNumber : [
			SELECT
				Novidea_HPC__Agency__c,
				Name,
				Novidea_HPC__Carrier__c,
				Novidea_HPC__Profit_Center__c,
				Novidea_HPC__Agency__r.Name,
				Novidea_HPC__Profit_Center__r.Name,
				Novidea_HPC__Profit_Center__r.Id
			FROM Novidea_HPC__Broker_Number__c
			WHERE Id IN :borkerNumbers OR Id = :brokerFromProductId OR Novidea_HPC__Agreement__c IN :agreementsIds
		]) {
			if (!profitCentersIdsByCarrierId.containsKey(brokerNumber.Novidea_HPC__Carrier__c))
				continue;

			String profitCenterName = composeProfitCenterName(brokerNumber);

			profitCentersIdsByCarrierId.get(brokerNumber.Novidea_HPC__Carrier__c).put(profitCenterName, brokerNumber.Id);
		}
		return profitCentersIdsByCarrierId;
	}

	@testVisible
	private static String composeProfitCenterName(Novidea_HPC__Broker_Number__c brokerNumber) {
		if (brokerNumber == null)
			return null;
		String agencyName = '';
		if (brokerNumber.Novidea_HPC__Agency__c != null)
			agencyName = ' (' + brokerNumber.Novidea_HPC__Agency__r.Name + ')';
		else
			agencyName = ' (' + Label.Novidea_HPC.No_Brokerage_In_Brober_Number + ')';
		return brokerNumber.Name +
			' - ' +
			(brokerNumber.Novidea_HPC__Profit_Center__c == null ||
				brokerNumber.Novidea_HPC__Profit_Center__r.Name == null
				? ''
				: brokerNumber.Novidea_HPC__Profit_Center__r.Name) +
			agencyName;
	}

	//TODO: Take this out to a new file? if not make the class and all the fields private
	public class BrokerNumberWrapper {
		public Id selectedProfitCenter;
		public Set<String> profitCenters;
		public map<String, Id> profitCentersIds;
		public BrokerNumberWrapper() {
		}

		public BrokerNumberWrapper(Id carrierId, Set<Id> productDefs) {
			ApprovedProposalsController.initBrokerNumberWrapper(this, carrierId, productDefs);
		}
	}

	public set<Id> setAllSelectedProposals { get; set; }
	@TestVisible
	Novidea_HPC__Application__c application;
	public Integer pageNumber { get; set; }

	public Boolean isComplexPolicy { get; set; }
	public Boolean shortConvertion { get; set; }

	public Map<Id, BrokerNumberWrapper> brokerNumbers;
	public List<SelectOption> profitCenters { get; set; }
	public String selectedProfitCenter { get; set; }

	// It is safe to assume that there will be only one complex policy (Business Policy) in all the Proposals for a given application
	public Id selectedBranch { get; set; }
	public List<SelectOption> complexPolicyBranches { get; set; }
	public Map<Id, Id> branchNumberToDef { get; set; }

	public id applicationId { get; set; }

	public list<Novidea_HPC__Proposal__c> listAllProposals;

	public Boolean firstCheck { get; set; }
	public Boolean hasDuplicateProductDefs { get; set; }

	public SalesProcessHelper.productToPolicy currentPolicy { get; set; }
	public List<SalesProcessHelper.productToPolicy> onlySelectedProposalAcceptedProudcsList { get; set; }

	public Boolean proposalView { get; set; }
	public Boolean advancedModeVal {
		get {
			if (null == advancedModeVal)
				advancedModeVal = 'true'.equalsIgnoreCase(Apexpages.currentPage().getParameters().get('advancedMode'));
			return advancedModeVal;
		}
		set;
	}
	public String filterId { get; set; }


	public Boolean asyncModeVal {
		get {
			if (null == asyncModeVal) {
				asyncModeVal = gs.Convert_To_Policies_Asynchronously__c == true;
			}
			return asyncModeVal;
		}
		set;
	}

	public Boolean asyncConversionFinished {
		get {
			if (null == asyncConversionFinished) {
				asyncConversionFinished = false;
			}
			return asyncConversionFinished;
		}
		set;
	}

	private Id asyncJobId;

	public ApprovedProposalsController(ApexPages.StandardController controller) {
		try {
			if (Apexpages.currentPage().getParameters().get('filterId') != null) {
				filterId = Apexpages.currentPage().getParameters().get('filterId');
			}
			pageNumber = 1;
			proposalView = true;
			setAllSelectedProposals = new Set<Id>();
			set<Id> prodIds = null;

			if (null != controller.getId()) {
				setAllSelectedProposals.add(controller.getId());
				Id productId = Apexpages.currentPage().getParameters().get('productId');
				prodIds = productId != null ? new Set<Id>{ productId } : null;
			} else if (advancedModeVal) {
				//AEF: request page for many proposals
				String proposalIds = Apexpages.currentPage().getParameters().get('proposalIds');

				if (String.isBlank(proposalIds))
					throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Please_choose_proposal);

				setAllSelectedProposals.addAll((list<Id>) proposalIds.split(','));
			}

			init(prodIds);
			if (!listAllProposals.isEmpty() && listAllProposals[0].Novidea_HPC__Application__c != null) {
				applicationId = listAllProposals[0].Novidea_HPC__Application__c;
				getApplicationById(applicationId);
			}
		} catch (exception exp) {
			ConstructorPoliciesUtils.performException(exp);
		}
	}

	public ApprovedProposalsController(ApexPages.StandardSetController controller) {
		if (Apexpages.currentPage().getParameters().get('filterId') != null) {
			filterId = Apexpages.currentPage().getParameters().get('filterId');
		}
		pageNumber = 1;
		proposalView = false;
		applicationId = Apexpages.currentPage().getParameters().get('id');
		if (applicationId != null) {
			getApplicationById(applicationId);
		}

		setAllSelectedProposals = new Set<Id>();
		Novidea_HPC__Proposal__c[] listProposals = controller.getSelected();
		if (listProposals.isEmpty() && Apexpages.currentPage().getParameters().get('proposalCsv') != null) {
			for (String proposalId : Apexpages.currentPage().getParameters().get('proposalCsv').split(','))
				setAllSelectedProposals.add(proposalId);
		} else if (!listProposals.isEmpty()) {
			for (Novidea_HPC__Proposal__c proposal : listProposals) {
				setAllSelectedProposals.add(proposal.Id);
			}
		}
		if (listProposals.isEmpty() && Apexpages.currentPage().getParameters().get('proposalCsv') == null) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Novidea_HPC.Please_choose_proposal));
			listAllProposals = new List<Novidea_HPC__Proposal__c>();
			onlySelectedProposalAcceptedProudcsList = new List<SalesProcessHelper.productToPolicy>();
		} else
			init();
	}
	/*
		AEF:
	*/
	private Boolean runWithoutPage {
		get {
			if (null == runWithoutPage)
				runWithoutPage = false;
			return runWithoutPage;
		}
		set;
	}

	@TestVisible
	private ApprovedProposalsController() {
		runWithoutPage = true;
	}

	public static ApprovedProposalsController createControllerWithoutPage(set<Id> setAllSelectedProposals, set<Id> prodIds) {
		ApprovedProposalsController apController = new ApprovedProposalsController();
		apController.setAllSelectedProposals = setAllSelectedProposals;
		apController.init(prodIds);
		return apController;
	}

	private void getApplicationById(Id applicationId) {
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Application__c',
				new Set<String>{
					'Name',
					'Novidea_HPC__Status__c',
					'Novidea_HPC__Underwriter__c',
					'Novidea_HPC__Broker_In_Carrier__c',
					'Novidea_HPC__Required_Policy_Type__c',
					'Novidea_HPC__Renewal_Grouping_Key__c',
					'Novidea_HPC__Account__c',
					'Novidea_HPC__Previous_Policy__c',
					'Novidea_HPC__Disconnect_From_Parent_Policy__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields('Account', new Set<String>{ 'Name', 'AccountNumber' }, NOVU.SecurityUtils.FLS.ACCESS);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Policy__c',
				new Set<String>{
					'Novidea_HPC__Policy_Number__c',
					'Novidea_HPC__Broker_In_Carrier__c',
					'Novidea_HPC__Master_Policy__c',
					'RecordTypeId'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		//Expected a single application in the process. This is the only place where it is queried.
		if (application == null || application.Id != applicationId)
			application = [
				SELECT
					Name,
					Novidea_HPC__Status__c,
					Novidea_HPC__Underwriter__c,
					Novidea_HPC__Broker_In_Carrier__c,
					Novidea_HPC__Required_Policy_Type__c,
					Novidea_HPC__Renewal_Grouping_Key__c,
					Novidea_HPC__Account__r.Name,
					Novidea_HPC__Account__r.AccountNumber,
					Novidea_HPC__Previous_Policy__c,
					Novidea_HPC__Previous_Policy__r.Novidea_HPC__Policy_Number__c,
					Novidea_HPC__Previous_Policy__r.Novidea_HPC__Broker_In_Carrier__c,
					Novidea_HPC__Previous_Policy__r.Novidea_HPC__Master_Policy__c,
					Novidea_HPC__Disconnect_From_Parent_Policy__c,
					Novidea_HPC__Previous_Policy__r.RecordTypeId
				FROM Novidea_HPC__Application__c
				WHERE Id = :applicationId
			];
	}

	private List<Novidea_HPC__Proposal__c> queryProposal(set<Id> prodIds) {
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Proposal__c',
				new Set<String>{
					'OwnerId',
					'Novidea_HPC__Status__c',
					'Novidea_HPC__Status_Date__c',
					'Novidea_HPC__Request_for_Proposal__c',
					'Novidea_HPC__Proposal_Expiration_Date__c',
					'Novidea_HPC__Premium__c',
					'Novidea_HPC__Premium_Currency__c',
					'Novidea_HPC__Net_Premium__c',
					'Novidea_HPC__Fees_del__c',
					'Novidea_HPC__Fees_Currency__c',
					'Novidea_HPC__Estimated_Commission__c',
					'Novidea_HPC__Complex_Policy__c',
					'Novidea_HPC__Share_Percentage__c',
					'Novidea_HPC__Commission_from_Fees__c',
					'Novidea_HPC__Commission_Currency__c',
					'Novidea_HPC__Commission_Amount__c',
					'Novidea_HPC__Comment__c',
					'Novidea_HPC__Carrier__c',
					'Novidea_HPC__Calculated_Premium__c',
					'Novidea_HPC__Calculated_Net_Premium__c',
					'Novidea_HPC__Calculated_Fees__c',
					'Novidea_HPC__Calculated_Commission__c',
					'Novidea_HPC__Application__c',
					'Novidea_HPC__Account__c',
					'Name'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Product__c',
				new Set<String>{
					'OwnerId',
					'Name',
					'Novidea_HPC__Product_Definition__c',
					'Novidea_HPC__Lead__c',
					'Novidea_HPC__Proposal__c',
					'Novidea_HPC__Status__c',
					'Novidea_HPC__Status_Date__c',
					'Novidea_HPC__Coverages_Created__c',
					'Novidea_HPC__Application__c',
					'Novidea_HPC__Premium__c',
					'Novidea_HPC__Premium_Currency__c',
					'Novidea_HPC__Commission__c',
					'Novidea_HPC__Commission_Amount__c',
					'Novidea_HPC__Commission_Currency__c',
					'Novidea_HPC__Effective_Date__c',
					'Novidea_HPC__Expiration_Date__c',
					'Novidea_HPC__Fee_Amount__c',
					'Novidea_HPC__Fee_Currency__c',
					'Novidea_HPC__Old_Policy_Number__c',
					'Novidea_HPC__Budget__c',
					'Novidea_HPC__Net_Premium__c',
					'Novidea_HPC__Commission_Targrt__c',
					'Novidea_HPC__Calculated_Premium__c',
					'Novidea_HPC__Calculated_Fees__c',
					'Novidea_HPC__Calculated_Net_Premium__c',
					'Novidea_HPC__Product_Type__c',
					'Novidea_HPC__Expected_Renewal_Date__c',
					'Novidea_HPC__Other_Commission__c',
					'Novidea_HPC__Discount__c',
					'Novidea_HPC__Expected_Commission_Amount__c',
					'Novidea_HPC__Expected_Premium__c',
					'Novidea_HPC__Expected_Fees__c',
					'Novidea_HPC__Premium_Target__c',
					'Novidea_HPC__Target_Agency_Fee__c',
					'Novidea_HPC__Agency_Fee_Currency__c',
					'Novidea_HPC__Current_Agency_Fees__c',
					'Novidea_HPC__Previous_Policy__c',
					'Novidea_HPC__Product__c',
					'Novidea_HPC__Broker_In_Carrier__c',
					'Novidea_HPC__Product__c',
					'Novidea_HPC__Liability_Limit_Per_Case__c',
					'Novidea_HPC__Lower_Limit_of_Liability__c',
					'Novidea_HPC__Liability_Limit__c',
					'Novidea_HPC__Liability_Limit_Currency__c',
					'Novidea_HPC__Credit_Fee__c',
					'Novidea_HPC__Premium_Net__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields('Account', new Set<String>{ 'Name', 'AccountNumber' }, NOVU.SecurityUtils.FLS.ACCESS);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Application__c',
				new Set<String>{ 'Novidea_HPC__Account__c', 'Novidea_HPC__Status__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields('Novidea_HPC__Product_Def__c', new Set<String>{ 'Name' }, NOVU.SecurityUtils.FLS.ACCESS);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Request_for_Proposal__c',
				new Set<String>{ 'Novidea_HPC__Status__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}

		String queryText =
			ConvertProposalsHelper.getProposalQueryBase(prodIds != null) +
			(markNTUOnNotConvertedProposals == true
				? 'WHERE Novidea_HPC__Application__c =:applicationId '
				: 'WHERE Id IN: setAllSelectedProposals');

		Novidea_HPC__Hierarchical_General_Settings__c generalSettings = Novidea_HPC__Hierarchical_General_Settings__c.getInstance();

		if (generalSettings != null && !String.isBlank(generalSettings.Novidea_HPC__Proposal_Cancelled_Statuses__c)) {
			String statusNames = ConstructorPoliciesUtils.addQoutationToStringOfNames(
				generalSettings.Novidea_HPC__Proposal_Cancelled_Statuses__c
			);
			queryText += '\n AND Novidea_HPC__Status__c NOT IN (' + statusNames + ')';
		}

		if (generalSettings != null && !String.isBlank(generalSettings.Novidea_HPC__RFP_Cancelled_Statuses__c)) {
			String statusNames = ConstructorPoliciesUtils.addQoutationToStringOfNames(generalSettings.Novidea_HPC__RFP_Cancelled_Statuses__c);
			queryText += '\n AND Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Status__c NOT IN (' + statusNames + ')';
		}

		if (generalSettings != null && !String.isBlank(generalSettings.Novidea_HPC__Application_Cancelled_Statuses__c)) {
			String statusNames = ConstructorPoliciesUtils.addQoutationToStringOfNames(
				generalSettings.Novidea_HPC__Application_Cancelled_Statuses__c
			);
			queryText += '\n AND Novidea_HPC__Application__r.Novidea_HPC__Status__c NOT IN (' + statusNames + ')';
		}
		return (Novidea_HPC__Proposal__c[]) Database.query(queryText);
	}

	@TestVisible
	private void init() {
		init(null);
	}

	private void init(set<Id> prodIds) {
		brokerNumbers = new Map<Id, BrokerNumberWrapper>();
		profitCenters = new List<SelectOption>();
		complexPolicyBranches = new List<SelectOption>();
		branchNumberToDef = new Map<Id, Id>();
		onlySelectedProposalAcceptedProudcsList = new List<SalesProcessHelper.productToPolicy>();
		hasDuplicateProductDefs = false;
		firstCheck = false;

		listAllProposals = queryProposal(prodIds);
		if (listAllProposals.isEmpty())
			return;

		// diana moved from createControllerWithoutPage method 09/09/2014
		applicationId = listAllProposals[0].Novidea_HPC__Application__c;
		getApplicationById(applicationId);

		Set<Id> carrierIds = new Set<Id>();
		Set<Id> productDefs = new Set<Id>();
		for (Novidea_HPC__Proposal__c proposal : listAllProposals) {
			carrierIds.add(proposal.Novidea_HPC__Carrier__c);

			for (Novidea_HPC__Product__c product : proposal.Novidea_HPC__Products__r) {
				productDefs.add(product.Novidea_HPC__Product_Definition__c);
			}
		}
		if (selectedBranch == null)
			isComplexPolicy = false;

		Set<Id> productDefsIncludingAllProducts = new Set<Id>();
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Product_Def__c',
				new Set<String>{ 'Novidea_HPC__Master_Product_Definition__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		for (Novidea_HPC__Product_Def__c productDef : [
			SELECT Novidea_HPC__Master_Product_Definition__c
			FROM Novidea_HPC__Product_Def__c
			WHERE Id IN :productDefs
		]) {
			productDefsIncludingAllProducts.add(productDef.Id);
			if (productDef.Novidea_HPC__Master_Product_Definition__c != null)
				productDefsIncludingAllProducts.add(productDef.Novidea_HPC__Master_Product_Definition__c);
		}
		for (Id carrierId : carrierIds) {
			brokerNumbers.put(carrierId, new BrokerNumberWrapper(carrierId, productDefsIncludingAllProducts));
		}
		if (!brokerNumbers.isempty()) {
			//commented out during #4183: the contains test cannot work for more than one carrier and its purpose is unclear
			//if its meant to verify that proit center exists then its already verified in the calling controller
			//it seems inappropriate to tst it here since not always the conversion requires profit center
			/*for(BrokerNumberWrapper brokerNumber:brokerNumbers.values()){
				if(!brokerNumber.profitCenters.containsAll(brokerNumbers.values()[0].profitCenters) && (runWithOutPage))//diana 09/09/14
					throw new ApprovedProposalException(label.Broker_Number_Missing_Error);
			}*/

			for (String profitCenterName : brokerNumbers.values()[0].profitCenters) {
				profitCenters.add(new SelectOption(profitCenterName, profitCenterName));
			}

			selectedProfitCenter = System.Label.Novidea_HPC.None;
			for (Id brokerNumberId : brokerNumbers.values()[0].profitCentersIds.values()) {
				if (application.Novidea_HPC__Previous_Policy__r.Novidea_HPC__Broker_In_Carrier__c == brokerNumberId && brokerNumberId != null)
					selectedProfitCenter = application.Novidea_HPC__Previous_Policy__r.Novidea_HPC__Broker_In_Carrier__c;
			}
		}
		if (
			!runWithoutPage //AEF:
		)
			shortConvertion = Apexpages.currentPage().getParameters().get('shortConvertion') == 'true';
	}

	public Pagereference cancel() {
		if (null != this.applicationId && true == this.advancedModeVal)
			return new Pagereference('/' + applicationId).setRedirect(true);
		else
			return null;
	}

	public Pagereference convertToPolicy() {
		SavePoint sp;
		try {
			sp = Database.setSavepoint();

			if (!listAllProposals.isEmpty()) {
				// if there is a policy already connected to the product, then we need to ask the user if he wants to override the policy data
				// (if the policy and the product have the sameProductDef)
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
					NOVU.SecurityUtils.checkFields(
						'Novidea_HPC__Policy__c',
						new Set<String>{
							'Novidea_HPC__Product_Definition__c',
							'Novidea_HPC__Application__c',
							'Novidea_HPC__Expiration_Date__c',
							'Novidea_HPC__Client__c',
							'Novidea_HPC__Carrier__c',
							'Novidea_HPC__Status__c',
							'Name',
							'Novidea_HPC__Complex_Policy__c',
							'OwnerId',
							'Novidea_HPC__Process__c',
							'Novidea_HPC__Renewal_Grouping_Key__c'
						},
						NOVU.SecurityUtils.FLS.ACCESS
					);
				}
				map<Id, Id> mapProductDefIdToPolicyId = new Map<Id, Id>();
				//check if there is a policy already conected to this Application
				map<Id, Novidea_HPC__Policy__c> mapAllPolicyWithRelationToTheApplication = new Map<Id, Novidea_HPC__Policy__c>(
					[
						SELECT
							Novidea_HPC__Product_Definition__c,
							Novidea_HPC__Application__c,
							Novidea_HPC__Expiration_Date__c,
							Novidea_HPC__Client__c,
							Novidea_HPC__Carrier__c,
							Novidea_HPC__Status__c,
							Name,
							Novidea_HPC__Complex_Policy__c,
							OwnerId,
							Novidea_HPC__Process__c,
							Novidea_HPC__Renewal_Grouping_Key__c,
							Novidea_HPC__Renewal_Advanced_Grouping_Key__c
						FROM Novidea_HPC__Policy__c
						WHERE Novidea_HPC__Application__c = :applicationId
					]
				);

				for (Novidea_HPC__Policy__c policy : mapAllPolicyWithRelationToTheApplication.values()) {
					if (!mapProductDefIdToPolicyId.containsKey(policy.Novidea_HPC__Product_Definition__c))
						mapProductDefIdToPolicyId.put(policy.Novidea_HPC__Product_Definition__c, policy.Id);
				}

				set<Id> setApplicationProductsId = new Set<Id>();
				set<Id> setProdefId = new Set<Id>();

				for (Novidea_HPC__Proposal__c prop : listAllProposals) {
					if (!setAllSelectedProposals.contains(prop.id) || NOVU.ArrayUtils.isListNullOrEmpty(prop.Novidea_HPC__Products__r))
						continue;
					for (Novidea_HPC__Product__c product : prop.Novidea_HPC__Products__r) {
						if (product.Novidea_HPC__Status__c != 'Accepted' || product.Novidea_HPC__Product_Definition__c == null)
							continue;
						if (product.Novidea_HPC__Product__r.Novidea_HPC__Product__c != null)
							if (setApplicationProductsId.contains(product.Novidea_HPC__Product__r.Novidea_HPC__Product__c)) {
								hasErrors = true;
								throw new ConstructorPoliciesUtils.ApplicationException(
									Label.Novidea_HPC.Cannot_Convert_An_Application_Product_For_More_Than_One_Carrier
								);
							} else
								setApplicationProductsId.add(product.Novidea_HPC__Product__r.Novidea_HPC__Product__c);

						SalesProcessHelper.productToPolicy ptp = new SalesProcessHelper.productToPolicy();
						ptp.proposal = prop;

						ptp.showOverride = false;
						ptp.product = product;
						if (mapProductDefIdToPolicyId.get(product.Novidea_HPC__Product_Definition__c) != null) {
							ptp.policy = mapAllPolicyWithRelationToTheApplication.get(
								mapProductDefIdToPolicyId.get(product.Novidea_HPC__Product_Definition__c)
							);
							ptp.showOverride = true;
							hasDuplicateProductDefs = true;
						} else if (setProdefId.contains(product.Novidea_HPC__Product_Definition__c)) {
							ptp.showOverride = true;
							hasDuplicateProductDefs = true;
						}
						setProdefId.add(product.Novidea_HPC__Product_Definition__c);
						onlySelectedProposalAcceptedProudcsList.add(ptp);
					}
				}
			}

			if (onlySelectedProposalAcceptedProudcsList.isEmpty()) {
				if (listAllProposals.Size() == 1)
					throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.No_products_related_to_chosen_proposal);
				else
					throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.No_products_related_to_chosen_proposals);
			} else {
				if (true == shortConvertion || advancedModeVal) {
					PageReference pr = convertingProductToPolicy(); //AEF: for case when "profit center" was chosen without page running.
					return pr;
				} else {
					if (onlySelectedProposalAcceptedProudcsList.Size() == 1)
						Apexpages.addMessage(
							new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.Novidea_HPC.Would_you_like_to_approve_the_chosen_product)
						);
					else
						Apexpages.addMessage(
							new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.Novidea_HPC.Would_you_like_to_approve_the_chosen_products)
						);
				}
			}
		} catch (Exception exp) {
			Database.rollback(sp);
			ConstructorPoliciesUtils.performException(exp);
		}
		return null;
	}

	public PageReference convertingProductToPolicy() {
		//button action
		Savepoint sp = Database.setSavepoint();
		try {
			if (asyncModeVal) {
				this.asyncJobId = Database.executeBatch(
					new ConvertProposalsBatch(
						application,
						listAllProposals,
						onlySelectedProposalAcceptedProudcsList,
						brokerNumbers,
						selectedProfitCenter,
						filterId
					),
					1
				);
				pageNumber = -2;
			} else {
				PageReference pr = ConvertProposalsHelper.convertProductsToPolicies(
					application,
					listAllProposals,
					onlySelectedProposalAcceptedProudcsList,
					brokerNumbers,
					selectedProfitCenter,
					filterId
				);
				Boolean goToEditPolicy = updateAppAndSetCurrentPolicy();
				if (goToEditPolicy) {
					return pr;
				}
			}
		} catch (Exception exp) {
			if (null != sp)
				Database.rollback(sp);
			ConstructorPoliciesUtils.performException(exp);
		}
		return null;
	}

	public void turnPage() {
		pageNumber++;
		if (pageNumber - 2 >= onlySelectedProposalAcceptedProudcsList.size())
			pageNumber = -1;
		else
			currentPolicy = onlySelectedProposalAcceptedProudcsList[pageNumber - 2];
	}

	public void getConvertedPolicies() {
		Map<String, SalesProcessHelper.productToPolicy> guidKeysToPTP = new Map<String, SalesProcessHelper.productToPolicy>();
		for (SalesProcessHelper.productToPolicy ptp : onlySelectedProposalAcceptedProudcsList) {
			guidKeysToPTP.put(ptp.guidKey, ptp);
		}
		List<Novidea_HPC__Policy__c> convertedPolicies = [
			SELECT Id, Conversion_Process_GUID__c
			FROM Novidea_HPC__Policy__c
			WHERE Conversion_Process_GUID__c IN :guidKeysToPTP.keySet()
		];

		List<SalesProcessHelper.productToPolicy> onlyConvertedProposalPolicies = new List<SalesProcessHelper.productToPolicy>();
		for (Novidea_HPC__Policy__c convertedPolicy : convertedPolicies) {
			SalesProcessHelper.productToPolicy ptp = guidKeysToPTP.get(convertedPolicy.Conversion_Process_GUID__c);
			ptp.policy = convertedPolicy;
			onlyConvertedProposalPolicies.add(ptp);
		}

		if (convertedPolicies.size() != onlySelectedProposalAcceptedProudcsList.size()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Label.Conversion_Process_Finished));
			ApexPages.addmessage(
				new ApexPages.message(
					ApexPages.severity.WARNING,
					String.format(
						Label.Numb_Of_Policies_Converted_Out_Of_Total,
						new List<String>{ '' + convertedPolicies.size(), '' + onlySelectedProposalAcceptedProudcsList.size() }
					)
				)
			);
			onlySelectedProposalAcceptedProudcsList = onlyConvertedProposalPolicies;
		} else {
			onlySelectedProposalAcceptedProudcsList = onlyConvertedProposalPolicies;
			continueFromAsyncConversion();
		}
	}

	private Boolean updateAppAndSetCurrentPolicy() {
		if (advancedModeVal) {
			ProductHelper.calculateApplStatusFromProds(application.Id, true);
		}
		pageNumber = 2;
		currentPolicy = onlySelectedProposalAcceptedProudcsList[pageNumber - 2];
		// if editPolicyAfterConversion is on and management policy is off return the first policy url (for in case user want to open policy in edit mode)
		// otherwise will return null and keep the original ApprovedPropsals page
		if (editPolicyAfterConversion && getDisableManagementPolicy()) {
			return true;
		}
		return false;
	}

	public void continueFromAsyncConversion() {
		asyncModeVal = false;
		if (onlySelectedProposalAcceptedProudcsList.isEmpty()) {
			pageNumber = -1;
			return;
		}
		updateAppAndSetCurrentPolicy();
	}

	public void checkAsyncConversion() {
		AsyncApexJob job = [SELECT status FROM AsyncApexJob WHERE Id = :this.asyncJobId];
		if (job.Status == 'Aborted' || job.Status == 'Completed' || job.Status == 'Failed') {
			getConvertedPolicies();
			asyncConversionFinished = true;
		}
	}

	private Boolean editPolicyAfterConversion {
		get {
			return gs.Novidea_HPC__Edit_Policy_After_Conversion__c == null ? false : gs.Novidea_HPC__Edit_Policy_After_Conversion__c;
		}
	}

	/////// sr 18-3-14 - adding functionality for disabling the policy management pages: ///////
	public boolean getDisableManagementPolicy() {
		return gs.Novidea_HPC__Disable_Management_Policy__c == true;
	}

	public Boolean enableSameProductDef {
		get {
			return gs.Novidea_HPC__Enable_Same_Product_Def__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def__c;
		}
	}

	public Boolean enableSharingPercentage {
		get {
			return gs.Novidea_HPC__Enable_Sharing_Percentage__c == null ? false : gs.Novidea_HPC__Enable_Sharing_Percentage__c;
		}
	}

	public Boolean enableSameProductDefMsg {
		get {
			return gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c;
		}
	}

	public String duplicateProductDefMessage {
		get {
			return enableSameProductDef ? Label.Novidea_HPC.Enable_Same_ProductDef_Msg : Label.Novidea_HPC.Disable_Same_ProductDef_Msg;
		}
	}
}