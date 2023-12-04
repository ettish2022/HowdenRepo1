public with sharing class ProductHelper {
	private class ProductWrapper {
		public Novidea_HPC__Product__c prod;
		public Id agrId;
		public ProductWrapper(Novidea_HPC__Product__c prod) {
			this.prod = prod;
		}
	}

	private static Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
	private static List<Schema.FieldSetMember> renewalAccumulatedFields = SObjectType.Novidea_HPC__Income__c.FieldSets.Novidea_HPC__Renewal_Accumulated_Fields.getFields();
	private static List<Schema.FieldSetMember> renewalMaximumFields = SObjectType.Novidea_HPC__Income__c.FieldSets.Novidea_HPC__Renewal_Maximum_Fields.getFields();
	private static List<Schema.FieldSetMember> renewalMinimumFields = SObjectType.Novidea_HPC__Income__c.FieldSets.Novidea_HPC__Renewal_Minimum_Fields.getFields();
	private static List<Schema.FieldSetMember> renewalAverageFields = SObjectType.Novidea_HPC__Income__c.FieldSets.Novidea_HPC__Renewal_Average_Fields.getFields();

	public static void updatePoliciesFromProductAccordingToRenewalFields(Map<Id, Novidea_HPC__Policy__c> policiesByProductIds) {
		String productsIds = getIdForSOQL(policiesByProductIds.keySet());
		// If there were no products' ids were available then there is no need to continue.
		if (productsIds == '')
			return;

		String fieldsCsv = getRnewalDynamicProductFields();
		// If no fields were available in the field sets there is nothing to do.
		if (fieldsCsv == '')
			return;

		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields('Novidea_HPC__Product__c', new Set<String>{ 'Id' }, NOVU.SecurityUtils.FLS.ACCESS);
		}
		Map<Id, Novidea_HPC__Product__c> products = new Map<Id, Novidea_HPC__Product__c>(
			(List<Novidea_HPC__Product__c>) Database.query(
				'SELECT Id, ' +
				fieldsCsv +
				' FROM Novidea_HPC__Product__c ' +
				' WHERE Id IN ' +
				productsIds
			)
		);

		// If no products were queried (not supposed to happen)
		if (products.keySet().size() == 0)
			return;

		List<Novidea_HPC__Policy__c> policies = new List<Novidea_HPC__Policy__c>();
		for (Id productId : policiesByProductIds.keySet()) {
			Novidea_HPC__Product__c product = products.get(productId);
			Novidea_HPC__Policy__c policy = policiesByProductIds.get(productId);
			policies.add(policy);
			for (
				List<Schema.FieldSetMember> fieldSet : new Set<List<Schema.FieldSetMember>>{
					renewalAccumulatedFields,
					renewalMaximumFields,
					renewalMinimumFields,
					renewalAverageFields
				}
			) {
				for (Schema.FieldSetMember fieldSetMember : fieldSet) {
					String fieldName = fieldSetMember.getFieldPath();
					policy.put(fieldName, product.get(fieldName));
				}
			}
		}
	}

	public static String getRnewalDynamicProductFields() {
		String productFieldsCsv = '';
		productFieldsCsv = ConstructorPoliciesUtils.getFieldSetCsvString(productFieldsCsv, renewalAccumulatedFields);
		productFieldsCsv = ConstructorPoliciesUtils.getFieldSetCsvString(productFieldsCsv, renewalMaximumFields);
		productFieldsCsv = ConstructorPoliciesUtils.getFieldSetCsvString(productFieldsCsv, renewalMinimumFields);
		productFieldsCsv = ConstructorPoliciesUtils.getFieldSetCsvString(productFieldsCsv, renewalAverageFields);

		return productFieldsCsv;
	}

	public static String calculateApplStatusFromProds(ID applicationId, Boolean toSave) {
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Application__c',
				new Set<String>{ 'Novidea_HPC__Status__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Product__c',
				new Set<String>{ 'Novidea_HPC__Status__c', 'Novidea_HPC__Is_Lost__c' },
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		Novidea_HPC__Application__c app = [
			SELECT Novidea_HPC__Status__c, (SELECT Novidea_HPC__Status__c, Novidea_HPC__Is_Lost__c FROM Novidea_HPC__Products__r)
			FROM Novidea_HPC__Application__c
			WHERE Id = :applicationId AND Novidea_HPC__Status__c != :'Cancelled'
			LIMIT 1
		];

		if (NOVU.ArrayUtils.isListNullOrEmpty(app.Novidea_HPC__Products__r))
			return app.Novidea_HPC__Status__c;

		String newAppStatus = calculateApplStatusFromProds(app.Novidea_HPC__Status__c, app.Novidea_HPC__Products__r);
		if (toSave && !newAppStatus.equalsIgnoreCase(app.Novidea_HPC__Status__c)) {
			app.Novidea_HPC__Status__c = newAppStatus;
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Application__c',
					new Set<String>{ 'Novidea_HPC__Status__c' },
					NOVU.SecurityUtils.FLS.UPDT
				);
			}
			Database.update(app);
		}
		return newAppStatus;
	}

	public static String calculateApplStatusFromProds(String oldApplStatus, list<Novidea_HPC__Product__c> productList) {
		Integer countActive = 0;
		Integer countSend = 0;
		Integer countReceived = 0;
		Integer countCancelled = 0;
		Integer countAccepted = 0;
		Integer countConverted = 0;
		Integer productNum = productList.size();
		String newStatus = String.isNotBlank(oldApplStatus) ? oldApplStatus : '';
		Boolean lossCauseReportingBehaviour = gs.Novidea_HPC__Loss_Cause_Reporting_Behaviour__c == null
			? false
			: gs.Novidea_HPC__Loss_Cause_Reporting_Behaviour__c;

		for (Novidea_HPC__Product__c prod : productList) {
			if ('Active'.equalsIgnoreCase(prod.Novidea_HPC__Status__c))
				++countActive;
			else if ('Send'.equalsIgnoreCase(prod.Novidea_HPC__Status__c))
				++countSend;
			else if ('Received'.equalsIgnoreCase(prod.Novidea_HPC__Status__c))
				++countReceived;
			else if (ApplProductBuilderExtendCo.isStatusCancelled(prod.Novidea_HPC__Status__c)) {
				// see LossCauseReportingCO documentation for details
				if (!lossCauseReportingBehaviour || (lossCauseReportingBehaviour && prod.Novidea_HPC__Is_Lost__c == true))
					++countCancelled;
			} else if ('Accepted'.equalsIgnoreCase(prod.Novidea_HPC__Status__c))
				++countAccepted;
			else if ('Converted'.equalsIgnoreCase(prod.Novidea_HPC__Status__c))
				++countConverted;
		}

		if (countActive == productNum) {
			if ('Renewal'.equalsIgnoreCase(oldApplStatus))
				newStatus = 'Renewal';
			else
				newStatus = 'New'; //default
		} else if ((countActive > 0 || countSend > 0 || countReceived > 0) && 0 == countConverted)
			newStatus = 'Proposals evaluation';
		else if (0 < countAccepted && (productNum == countAccepted + countCancelled))
			newStatus = 'Partial Coverage - followup';
		else if (countConverted == productNum)
			newStatus = 'Coverage Approval'; //Full Coverage
		else if (0 < countConverted && 0 < countCancelled && (countConverted + countCancelled == productNum))
			newStatus = 'Partial Coverage – closed';
		else if (0 < countCancelled && productNum == countCancelled) {
			newStatus = 'Non Renewable - no report';
		}
		return newStatus;
	}

	public static Novidea_HPC__Product__c updateProductActualByExpected(
		Novidea_HPC__Product__c fromProduct,
		Novidea_HPC__Product__c toProduct,
		boolean updateZeroOrNull,
		boolean clone
	) {
		Novidea_HPC__Product__c localFromProduct = true == clone ? fromProduct.clone(true, true, true, true) : fromProduct;

		if (localFromProduct.Novidea_HPC__Expected_Premium__c != 0 && localFromProduct.Novidea_HPC__Expected_Premium__c != null) {
			toProduct.Novidea_HPC__Premium__c = localFromProduct.Novidea_HPC__Expected_Premium__c;
		} else {
			toProduct.Novidea_HPC__Premium__c =
				(localFromProduct.Novidea_HPC__Expected_Fees__c == null ? 0 : localFromProduct.Novidea_HPC__Expected_Fees__c) +
				(localFromProduct.Novidea_HPC__Expected_Premium_Net__c == null ? 0 : localFromProduct.Novidea_HPC__Expected_Premium_Net__c);
		}

		if (localFromProduct.Novidea_HPC__Expected_Premium_Net__c != 0 && localFromProduct.Novidea_HPC__Expected_Premium_Net__c != null) {
			toProduct.Novidea_HPC__Premium_Net__c = localFromProduct.Novidea_HPC__Expected_Premium_Net__c;
		} else {
			toProduct.Novidea_HPC__Premium_Net__c =
				(toProduct.Novidea_HPC__Premium__c == null ? 0 : toProduct.Novidea_HPC__Premium__c) -
				(localFromProduct.Novidea_HPC__Expected_Fees__c == null ? 0 : localFromProduct.Novidea_HPC__Expected_Fees__c);
		}

		if (localFromProduct.Novidea_HPC__Expected_Fees__c != 0 && localFromProduct.Novidea_HPC__Expected_Fees__c != null) {
			toProduct.Novidea_HPC__Fee_Amount__c = localFromProduct.Novidea_HPC__Expected_Fees__c;
		} else {
			toProduct.Novidea_HPC__Fee_Amount__c =
				(toProduct.Novidea_HPC__Premium__c == null ? 0 : toProduct.Novidea_HPC__Premium__c) -
				(toProduct.Novidea_HPC__Premium_Net__c == null ? 0 : toProduct.Novidea_HPC__Premium_Net__c);
		}

		System.debug(
			'Novidea_HPC__Fee_Amount__c: ' +
			toProduct.Novidea_HPC__Fee_Amount__c +
			'Novidea_HPC__Expected_Premium__c' +
			localFromProduct.Novidea_HPC__Expected_Premium__c +
			'Novidea_HPC__Expected_Premium_Net__c' +
			localFromProduct.Novidea_HPC__Expected_Premium_Net__c
		);

		toProduct.Novidea_HPC__Commission_Amount__c = null;
		if (
			localFromProduct.Novidea_HPC__Expected_Commission_Amount__c != 0 &&
			localFromProduct.Novidea_HPC__Expected_Commission_Amount__c != null || true == updateZeroOrNull
		) {
			toProduct.Novidea_HPC__Commission_Amount__c = localFromProduct.Novidea_HPC__Expected_Commission_Amount__c;
		}

		return toProduct;
	}

	private static void populateCommissionRates(
		map<Id, map<Id, list<Novidea_HPC__Commission_Rate__c>>> comRatesByProdDefByAgr,
		list<Novidea_HPC__Commission_Rate__c> comrates
	) {
		list<Novidea_HPC__Commission_Rate__c> tempComRateList;
		for (Novidea_HPC__Commission_Rate__c comrate : comrates) {
			if (
				(tempComRateList = comRatesByProdDefByAgr.get(comrate.Novidea_HPC__Agreement__c)
					.get(comrate.Novidea_HPC__Product_Definition__c)) == null
			)
				tempComRateList = new List<Novidea_HPC__Commission_Rate__c>();
			tempComRateList.add(comrate);
			comRatesByProdDefByAgr.get(comrate.Novidea_HPC__Agreement__c).put(comrate.Novidea_HPC__Product_Definition__c, tempComRateList);
		}
	}

	private static void calcExpectedFees(
		map<Id, map<Id, list<Novidea_HPC__Commission_Rate__c>>> comRatesByProdDefByAgr,
		list<ProductWrapper> pws
	) {
		Decimal maxVal = 0, tempVal, expectedFees = 0, tempExpectedFees;
		list<Novidea_HPC__Commission_Rate__c> tempComRateList;
		//assuming only one calculation type per product
		//assuming that if calc is based by pct from brut premium then we have the net premium
		//assuming that if calc is based by pct from net premium then we have the brut premium
		for (ProductWrapper pw : pws) {
			if (comRatesByProdDefByAgr.get(pw.agrId) == null)
				continue;
			tempComRateList = comRatesByProdDefByAgr.get(pw.agrId).get(pw.prod.Novidea_HPC__Product_Definition__c);
			if (tempComRateList == null)
				continue;
			for (Novidea_HPC__Commission_Rate__c comrate : tempComRateList) {
				tempExpectedFees = pw.prod.Novidea_HPC__Premium_Net__c * comrate.Novidea_HPC__Maximum_Percentage__c / 100;
				if ('Percentage from Premium by fees range'.equals(comrate.Novidea_HPC__Calculation_Type__c)) {
					tempVal = (pw.prod.Novidea_HPC__Premium_Net__c + tempExpectedFees) * comrate.Novidea_HPC__Percentage__c / 100;
				} else {
					// if('Percentage from Net Premium by fees range'.equals(comrate.Novidea_HPC__Calculation_Type__c)){
					tempVal = pw.prod.Novidea_HPC__Premium_Net__c * comrate.Novidea_HPC__Percentage__c / 100;
				}
				if (tempVal > maxVal) {
					maxVal = tempVal;
					expectedFees = tempExpectedFees;
				}
			}
			pw.prod.Novidea_HPC__Expected_Fees__c = expectedFees;
			expectedFees = 0;
			maxVal = 0;
		}
	}

	private static list<Novidea_HPC__Commission_Rate__c> getCommisionRates(list<ProductWrapper> pws) {
		String query = generateCommisionRateQuery(pws);
		return Database.query(query);
	}

	private static String generateCommisionRateQuery(list<ProductWrapper> pws) {
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Commission_Rate__c',
				new Set<String>{
					'Novidea_HPC__Calculation_Type__c',
					'Novidea_HPC__Product_Definition__c',
					'Novidea_HPC__Maximum_Percentage__c',
					'Novidea_HPC__Minimum_Percentage__c',
					'Novidea_HPC__Percentage__c',
					'Novidea_HPC__Product_Cost_Price__c',
					'Novidea_HPC__Agreement__c',
					'Novidea_HPC__Product_Cost_Price_Currency__c',
					'Novidea_HPC__Product_Maximum_Price__c'
				},
				NOVU.SecurityUtils.FLS.ACCESS
			);
		}
		String query =
			'SELECT Novidea_HPC__Calculation_Type__c, Novidea_HPC__Product_Definition__c,\n' +
			'		Novidea_HPC__Maximum_Percentage__c, Novidea_HPC__Minimum_Percentage__c,\n' +
			'		Novidea_HPC__Percentage__c, Novidea_HPC__Product_Cost_Price__c, Novidea_HPC__Agreement__c,\n' +
			'		Novidea_HPC__Product_Cost_Price_Currency__c, Novidea_HPC__Product_Maximum_Price__c\n' +
			'FROM Novidea_HPC__Commission_Rate__c\n' +
			'WHERE Novidea_HPC__Calculation_Type__c IN (\'Percentage from Premium by fees range\',\'Percentage from Net Premium by fees range\')\n AND (\n';
		String whereClause = '';
		for (ProductWrapper pw : pws) {
			String agreementId = 'null';
			String productDefinitionId = 'null';
			if (pw.agrId != null)
				agreementId = '\'' + pw.agrId + '\'';
			if (pw.prod.Novidea_HPC__Product_Definition__c != null)
				productDefinitionId = '\'' + pw.prod.Novidea_HPC__Product_Definition__c + '\'';

			whereClause +=
				'(Novidea_HPC__Agreement__c=' +
				agreementId +
				' AND Novidea_HPC__Product_Definition__c=' +
				productDefinitionId +
				')\nOR ';
		}
		whereClause = whereClause.substring(0, whereClause.length() - 'OR '.length()) + ')';
		query += whereClause;
		return query;
	}

	public static void calcExpectedFees(list<Novidea_HPC__Product__c> products) {
		map<Id, list<Id>> prodDefIdsByPropId = new Map<Id, list<Id>>();
		list<ProductWrapper> pws = new List<ProductWrapper>();
		list<Id> tempList;
		for (Novidea_HPC__Product__c prod : products) {
			if (prod.Novidea_HPC__Proposal__c == null)
				continue;
			pws.add(new ProductWrapper(prod));
			if ((tempList = prodDefIdsByPropId.get(prod.Novidea_HPC__Proposal__c)) == null)
				tempList = new List<Id>();
			tempList.add(prod.Novidea_HPC__Product_Definition__c);
			prodDefIdsByPropId.put(prod.Novidea_HPC__Proposal__c, tempList);
		}
		if (pws.isempty())
			return;
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
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
			NOVU.SecurityUtils.checkFields('Novidea_HPC__Agreement__c', new Set<String>{ 'Name' }, NOVU.SecurityUtils.FLS.ACCESS);
		}
		list<Novidea_HPC__Proposal__c> props = [
			SELECT Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Broker_Number__r.Novidea_HPC__Agreement__c
			FROM Novidea_HPC__Proposal__c
			WHERE Id IN :prodDefIdsByPropId.keyset()
		];

		//create the initial map
		//agrId=>prodDefId=>comissionRateList
		map<Id, map<Id, list<Novidea_HPC__Commission_Rate__c>>> comRatesByProdDefByAgr = new Map<Id, map<Id, list<Novidea_HPC__Commission_Rate__c>>>();
		map<Id, list<Novidea_HPC__Commission_Rate__c>> tempMap;
		Id agrId;
		Integer ind = 0;
		for (Novidea_HPC__Proposal__c prop : props) {
			agrId = prop.Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Broker_Number__r.Novidea_HPC__Agreement__c;
			for (ProductWrapper pw : pws) {
				if (pw.prod.Novidea_HPC__Proposal__c == prop.Id) {
					if (agrId == null) {
						system.debug(LoggingLevel.ERROR, 'No Agreement found for product: ' + pw.prod.Id + ' : ' + pw.prod.Name);
						pws.remove(ind);
						break;
					}
					pw.agrId = agrId;
					break;
				}
				ind++;
			}
			ind = 0;
			if (agrId == null)
				continue;
			if ((tempMap = comRatesByProdDefByAgr.get(agrId)) == null)
				tempMap = new Map<Id, list<Novidea_HPC__Commission_Rate__c>>();
			for (Id prodDefId : prodDefIdsByPropId.get(prop.Id))
				tempMap.put(prodDefId, null);
			comRatesByProdDefByAgr.put(agrId, tempMap);
		}

		if (pws.isEmpty())
			return;

		//get the commission rates
		list<Novidea_HPC__Commission_Rate__c> comrates = getCommisionRates(pws);

		//populate the map with the commission rates
		populateCommissionRates(comRatesByProdDefByAgr, comrates);
		calcExpectedFees(comRatesByProdDefByAgr, pws);
	}

	private static String getIdForSOQL(Set<Id> ids) {
		if (NOVU.ArrayUtils.isSetNullOrEmpty(ids))
			return '()';
		return '(\'' + String.join(new List<Id>(ids), '\',\'') + '\')';
	}
}