public with sharing class AcceptProductInListViewController {
	// product statuses
	private static final String APPROVED_FOR_TRANSACTION = 'Approved For Transaction';
	private static Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
	private final static map<String, Schema.DescribeFieldResult> FIELDSPATH_NO_NS = gs != null &&
		gs.Novidea_HPC__Copy_Application_Product_To_RFP_Product__c == true &&
		gs.Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c == true
		? null
		: NOVU.FlatModelHelper.getFieldsDescribeByFilter('Novidea_HPC__Product__c', null);
	private static final List<String> INVALID_STATUSES = new List<String>{
		ApplProductBuilderExtendCo.CANCELLED,
		ApplProductBuilderExtendCo.CONVERTED,
		APPROVED_FOR_TRANSACTION
	};
	private static final List<String> VALID_STATUSES = new List<String>{
		ApplProductBuilderExtendCo.ACTIVE,
		ApplProductBuilderExtendCo.PRODUCT_SENT_TO_CLIENT,
		ApplProductBuilderExtendCo.RECEIVED
	};

	@testVisible
	private List<Novidea_HPC__Product__c> selectedProducts;

	private String filterId;

	public AcceptProductInListViewController(ApexPages.StandardsetController pageController) {
		selectedProducts = (List<Novidea_HPC__Product__c>) pageController.getSelected();
		filterId = pageController.getFilterId();
	}

	public Pagereference initRecent() {
		filterId = 'Recent';
		return init();
	}

	public Pagereference init() {
		if (NOVU.ArrayUtils.isListNullOrEmpty(selectedProducts)) {
			// add exception
			ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.Error, Label.Novidea_HPC.No_products_were_chosen);
			ApexPages.addMessage(errMsg);
			return null;
		}

		List<Novidea_HPC__Product__c> products = getProducts(selectedProducts);
		String generalProductRecordType = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('General_Product', 'Novidea_HPC__Product__c');
		Map<String, List<Novidea_HPC__Product__c>> applicationIdTOProductsToConvert = new Map<String, List<Novidea_HPC__Product__c>>();
		List<Novidea_HPC__Product__c> productsWithoutRFPAndProposal = new List<Novidea_HPC__Product__c>();
		Map<String, String> productNotToCreateToError = new Map<String, String>();

		for (Novidea_HPC__Product__c product : products) {
			if (product.Novidea_HPC__Application__c == null) {
				productNotToCreateToError.put(product.Name, Label.Missing_Application);
				continue;
			}
			if (product.RecordTypeId != generalProductRecordType) {
				productNotToCreateToError.put(product.Novidea_HPC__Application__r.Name, Label.Wrong_RecordType);
				continue;
			}
			if (INVALID_STATUSES.contains(product.Novidea_HPC__Status__c) && !VALID_STATUSES.contains(product.Novidea_HPC__Status__c)) {
				productNotToCreateToError.put(product.Novidea_HPC__Application__r.Name, Label.Wrong_Product_Status);
				continue;
			}
			if (product.Novidea_HPC__Carrier__c == null) {
				productNotToCreateToError.put(product.Name, Label.Missing_Carrier);
				continue;
			}
			if (!applicationIdTOProductsToConvert.containsKey(product.Novidea_HPC__Application__c)) {
				applicationIdTOProductsToConvert.put(product.Novidea_HPC__Application__c, new List<Novidea_HPC__Product__c>());
			}
			applicationIdTOProductsToConvert.get(product.Novidea_HPC__Application__c).add(product);
		}
		List<Novidea_HPC__Product__c> productsToUpdate = new List<Novidea_HPC__Product__c>();
		SavePoint sp = Database.setSavepoint();
		try {
			for (String key : applicationIdTOProductsToConvert.keySet()) {
				{
					try {
						List<Novidea_HPC__Product__c> productToConvert = applicationIdTOProductsToConvert.get(key);
						Novidea_HPC__Application__c application = new Novidea_HPC__Application__c(
							id = productToConvert[0].Novidea_HPC__Application__c
						);
						ApplProductBuilderExtendCo applPage = new ApplProductBuilderExtendCo(new ApexPages.StandardController(application));
						applPage.createRfp(productToConvert, APPROVED_FOR_TRANSACTION, ApplProductBuilderExtendCo.ACCEPTED);
						applPage.createProposal(productToConvert, ApplProductBuilderExtendCo.RECEIVED, ApplProductBuilderExtendCo.ACCEPTED);
						productsToUpdate.addAll(productToConvert);
					} catch (Exception ex) {
						addExceptionToPage(ex.getMessage());
					}
				}
			}
			if (productNotToCreateToError.keySet().size() > 0) {
				for (String name : productNotToCreateToError.keySet()) {
					{
						String error = productNotToCreateToError.get(name);
						addExceptionToPage(String.format(Label.AcceptProductInListView_Error_Format, new List<String>{ name, error }));
					}
				}
			}
		} catch (Exception ex) {
			if (sp != null)
				Database.rollback(sp);
			addExceptionToPage(ex.getMessage());
		}
		if (ApexPages.hasMessages())
			return null;

		for (Novidea_HPC__Product__c product : productsToUpdate) {
			product.Novidea_HPC__Status__c = ApplProductBuilderExtendCo.ACCEPTED;
		}
		Database.update(productsToUpdate);
		Schema.DescribeSObjectResult result = Novidea_HPC__Product__c.SObjectType.getDescribe();
		PageReference pageRef = new PageReference('/lightning/o/Novidea_HPC__Product__c/list?filterName=' + filterId);
		pageRef.setRedirect(true);
		return pageRef;
	}

	private List<Novidea_HPC__Product__c> getProducts(List<Novidea_HPC__Product__c> selectedProducts) {
		String[] dynamicFieldsNames = new List<String>(FIELDSPATH_NO_NS.keySet());
		String query =
			'SELECT Novidea_HPC__Product_Definition__r.Name, Novidea_HPC__Carrier__r.Name,\n' +
			'Novidea_HPC__Application__r.Name,\n' +
			'Novidea_HPC__Broker_In_Carrier__r.Name, Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Broker_Number_In_Carrier__c,\n' +
			'Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Profit_Center__r.Name, Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agency__r.Name,\n';

		query += String.join(dynamicFieldsNames, ',') + '\n';
		query += 'FROM Novidea_HPC__Product__c WHERE id =:selectedProducts \n';

		return Database.query(query);
	}
	private void addExceptionToPage(String exceptionMessage) {
		ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.Error, exceptionMessage);
		ApexPages.addMessage(errMsg);
	}
}