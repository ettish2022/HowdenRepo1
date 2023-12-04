public with sharing class ConvertProposalsBatch implements Database.Batchable<Novidea_HPC__Proposal__c> {
	private Novidea_HPC__Application__c application;
	private List<Novidea_HPC__Proposal__c> listAllProposals;
	private Map<Id, List<SalesProcessHelper.productToPolicy>> selectedProposalToProdToPols;
	private Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers;
	private String selectedProfitCenter;
	private String filterId;

	public ConvertProposalsBatch(
		Novidea_HPC__Application__c application,
		List<Novidea_HPC__Proposal__c> listAllProposals,
		List<SalesProcessHelper.productToPolicy> selectedProposalAcceptedProudcsList,
		Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers,
		String selectedProfitCenter
	) {
		this(application, listAllProposals, selectedProposalAcceptedProudcsList, brokerNumbers, selectedProfitCenter, null);
	}

	public ConvertProposalsBatch(
		Novidea_HPC__Application__c application,
		List<Novidea_HPC__Proposal__c> listAllProposals,
		List<SalesProcessHelper.productToPolicy> selectedProposalAcceptedProudcsList,
		Map<Id, ApprovedProposalsController.BrokerNumberWrapper> brokerNumbers,
		String selectedProfitCenter,
		String filterId
	) {
		this.filterId = filterId;
		this.application = application;
		this.listAllProposals = listAllProposals;
		this.brokerNumbers = brokerNumbers;
		this.selectedProfitCenter = selectedProfitCenter;
		this.selectedProposalToProdToPols = new Map<Id, List<SalesProcessHelper.productToPolicy>>();

		for (SalesProcessHelper.productToPolicy ptp : selectedProposalAcceptedProudcsList) {
			if (!this.selectedProposalToProdToPols.containsKey(ptp.proposal.Id)) {
				this.selectedProposalToProdToPols.put(ptp.proposal.Id, new List<SalesProcessHelper.productToPolicy>());
			}
			this.selectedProposalToProdToPols.get(ptp.proposal.Id).add(ptp);
		}
	}	

	public List<Novidea_HPC__Proposal__c> start(Database.BatchableContext BC) {
		Set<Id> allProposalsIds = (new Map<Id, Novidea_HPC__Proposal__c>(this.listAllProposals)).keySet();
		String baseQuery = ConvertProposalsHelper.getProposalQueryBase(false);
		return Database.query(baseQuery + 'WHERE Id in :allProposalsIds');
	}

	public void execute(Database.BatchableContext BC, List<Novidea_HPC__Proposal__c> scope) {
		List<SalesProcessHelper.productToPolicy> onlySelectedProposalPTPsInScope = new List<SalesProcessHelper.productToPolicy>();
		for (Novidea_HPC__Proposal__c proposal : scope) {
			if (this.selectedProposalToProdToPols.containsKey(proposal.Id)) {
				onlySelectedProposalPTPsInScope.addAll(this.selectedProposalToProdToPols.get(proposal.Id));
			}
		}
		Savepoint sp = Database.setSavepoint();
		try {
			ConvertProposalsHelper.convertProductsToPolicies(
				this.application,
				scope,
				onlySelectedProposalPTPsInScope,
				this.brokerNumbers,
				this.selectedProfitCenter,
				filterId
			);
		} catch (Exception exp) {
			Database.rollback(sp);
			System.debug('ConvertProposalsBatch Error: ' + exp.getMessage() + '\n' + exp.getStackTraceString());
		}
	}

	public void finish(Database.BatchableContext BC) {
	}
}