public with sharing class RFPTableCo {
	map<Id, ProductWrapper> originalProToPw;
	map<string, integer> carriersMap;
	map<integer, Id> carriersId = new Map<integer, Id>();
	map<id, id> carrierToProposal = new Map<id, id>();

	public list<CarrierWrapper> carrierlist { get; set; }
	public CarrierWrapper carrier { get; set; }
	public String index { get; set; }
	public integer carrierIndex { get; set; }
	public id parentProductId { get; set; }
	public boolean mainCheckBox { get; set; }
	public list<AggregateResult> products { get; set; }
	public id applicationId { get; private set; }

	public list<ProductWrapper> productWrapperList {
		get {
			list<ProductWrapper> x = new List<ProductWrapper>(originalProToPw.values());
			x.sort();
			return x;
		}
		set;
	}

	public RFPTableCo(ApexPages.StandardController controller) {
		//need page
		applicationId = controller.getRecord().Id;
		products = new List<AggregateResult>();
		carrierlist = new List<CarrierWrapper>();
	}

	public class CarrierWrapper {
		public string carrierName { get; set; }
		public id carrierId { get; set; }

		public CarrierWrapper(string carrierName, id carrierId) {
			this.carrierName = carrierName;
			this.carrierId = carrierId;
		}
	}

	public class ProductWrapper implements Comparable {
		public Integer compareTo(Object compareTo) {
			if (appProductName > ((ProductWrapper) compareTo).appProductName)
				return 1;
			else if (appProductName < ((ProductWrapper) compareTo).appProductName)
				return -1;
			else
				return 0;
		}
		//integer index;
		public string statusCarrier0 { get; set; }
		public string statusCarrier1 { get; set; }
		public string statusCarrier2 { get; set; }
		public string statusCarrier3 { get; set; }
		public string statusCarrier4 { get; set; }
		public string statusCarrier5 { get; set; }
		public string statusCarrier6 { get; set; }
		public string statusCarrier7 { get; set; }
		public string statusCarrier8 { get; set; }
		public string statusCarrier9 { get; set; }
		public string statusCarrier10 { get; set; }
		public string statusCarrier11 { get; set; }
		public string statusCarrier12 { get; set; }
		public string statusCarrier13 { get; set; }
		public string statusCarrier14 { get; set; }
		public string statusCarrier15 { get; set; }
		public string statusCarrier16 { get; set; }
		public string statusCarrier17 { get; set; }
		public string statusCarrier18 { get; set; }
		public string statusCarrier19 { get; set; }
		public string statusCarrier20 { get; set; }
		public string statusCarrier21 { get; set; }
		public string statusCarrier22 { get; set; }
		public string statusCarrier23 { get; set; }
		public string statusCarrier24 { get; set; }
		public string statusCarrier25 { get; set; }
		public string statusCarrier26 { get; set; }
		public string statusCarrier27 { get; set; }
		public string statusCarrier28 { get; set; }
		public string statusCarrier29 { get; set; }
		public string statusCarrier30 { get; set; }

		public List<SelectOption> statuses0 { get; set; }
		public List<SelectOption> statuses1 { get; set; }
		public List<SelectOption> statuses2 { get; set; }
		public List<SelectOption> statuses3 { get; set; }
		public List<SelectOption> statuses4 { get; set; }
		public List<SelectOption> statuses5 { get; set; }
		public List<SelectOption> statuses6 { get; set; }
		public List<SelectOption> statuses7 { get; set; }
		public List<SelectOption> statuses8 { get; set; }
		public List<SelectOption> statuses9 { get; set; }
		public List<SelectOption> statuses10 { get; set; }
		public List<SelectOption> statuses11 { get; set; }
		public List<SelectOption> statuses12 { get; set; }
		public List<SelectOption> statuses13 { get; set; }
		public List<SelectOption> statuses14 { get; set; }
		public List<SelectOption> statuses15 { get; set; }
		public List<SelectOption> statuses16 { get; set; }
		public List<SelectOption> statuses17 { get; set; }
		public List<SelectOption> statuses18 { get; set; }
		public List<SelectOption> statuses19 { get; set; }
		public List<SelectOption> statuses20 { get; set; }
		public List<SelectOption> statuses21 { get; set; }
		public List<SelectOption> statuses22 { get; set; }
		public List<SelectOption> statuses23 { get; set; }
		public List<SelectOption> statuses24 { get; set; }
		public List<SelectOption> statuses25 { get; set; }
		public List<SelectOption> statuses26 { get; set; }
		public List<SelectOption> statuses27 { get; set; }
		public List<SelectOption> statuses28 { get; set; }
		public List<SelectOption> statuses29 { get; set; }
		public List<SelectOption> statuses30 { get; set; }

		public Date statusDate0 { get; private set; }
		public Date statusDate1 { get; private set; }
		public Date statusDate2 { get; private set; }
		public Date statusDate3 { get; private set; }
		public Date statusDate4 { get; private set; }
		public Date statusDate5 { get; private set; }
		public Date statusDate6 { get; private set; }
		public Date statusDate7 { get; private set; }
		public Date statusDate8 { get; private set; }
		public Date statusDate9 { get; private set; }
		public Date statusDate10 { get; private set; }
		public Date statusDate11 { get; private set; }
		public Date statusDate12 { get; private set; }
		public Date statusDate13 { get; private set; }
		public Date statusDate14 { get; private set; }
		public Date statusDate15 { get; private set; }
		public Date statusDate16 { get; private set; }
		public Date statusDate17 { get; private set; }
		public Date statusDate18 { get; private set; }
		public Date statusDate19 { get; private set; }
		public Date statusDate20 { get; private set; }
		public Date statusDate21 { get; private set; }
		public Date statusDate22 { get; private set; }
		public Date statusDate23 { get; private set; }
		public Date statusDate24 { get; private set; }
		public Date statusDate25 { get; private set; }
		public Date statusDate26 { get; private set; }
		public Date statusDate27 { get; private set; }
		public Date statusDate28 { get; private set; }
		public Date statusDate29 { get; private set; }
		public Date statusDate30 { get; private set; }

		public string[] rfps { get; set; }

		public Id appProductId { get; set; }
		public Novidea_HPC__Product__c proposalProduct { get; set; }
		public Id proposalProductIdToConvert { get; set; }
		public string appProductName { get; set; }
		public boolean isSelected { get; set; }
		public string proposalToConvert { get; set; }
		public string noAcceptedStatusCheck { get; set; }
		public boolean isConverted {
			get {
				if (isConverted == null)
					return false;
				return isConverted;
			}
			set;
		}

		public ProductWrapper(id appProductId, string appProductName) {
			this.appProductName = appProductName;
			this.appProductId = appProductId;
			isSelected = false;
			rfps = new string[31];
			statuses0 = new List<SelectOption>();
			statuses0.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses1 = new List<SelectOption>();
			statuses1.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses2 = new List<SelectOption>();
			statuses2.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses3 = new List<SelectOption>();
			statuses3.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses4 = new List<SelectOption>();
			statuses4.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses5 = new List<SelectOption>();
			statuses5.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses6 = new List<SelectOption>();
			statuses6.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses7 = new List<SelectOption>();
			statuses7.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses8 = new List<SelectOption>();
			statuses8.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses9 = new List<SelectOption>();
			statuses9.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses10 = new List<SelectOption>();
			statuses10.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses11 = new List<SelectOption>();
			statuses11.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses12 = new List<SelectOption>();
			statuses12.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses13 = new List<SelectOption>();
			statuses13.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses14 = new List<SelectOption>();
			statuses14.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses15 = new List<SelectOption>();
			statuses15.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses16 = new List<SelectOption>();
			statuses16.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses17 = new List<SelectOption>();
			statuses17.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses18 = new List<SelectOption>();
			statuses18.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses19 = new List<SelectOption>();
			statuses19.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses20 = new List<SelectOption>();
			statuses20.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses21 = new List<SelectOption>();
			statuses21.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses22 = new List<SelectOption>();
			statuses22.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses23 = new List<SelectOption>();
			statuses23.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses24 = new List<SelectOption>();
			statuses24.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses25 = new List<SelectOption>();
			statuses25.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses26 = new List<SelectOption>();
			statuses26.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses27 = new List<SelectOption>();
			statuses27.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses28 = new List<SelectOption>();
			statuses28.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses29 = new List<SelectOption>();
			statuses29.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
			statuses30 = new List<SelectOption>();
			statuses30.add(new SelectOption('0', Label.Novidea_HPC.Not_sent));
		}

		public void getPopulateWrapper(integer index, string status, string rfp) {
			if (index == 0) {
				statusCarrier0 = status;
				statusDate0 = date.Today();
				if (rfp != '')
					rfps[0] = rfp;
				statuses0 = buildSelectOptions(status);
			} else if (index == 1) {
				statusCarrier1 = status;
				statusDate1 = date.Today();
				if (rfp != '')
					rfps[1] = rfp;
				statuses1 = buildSelectOptions(status);
			} else if (index == 2) {
				statusCarrier2 = status;
				statusDate2 = date.Today();
				if (rfp != '')
					rfps[2] = rfp;
				statuses2 = buildSelectOptions(status);
			} else if (index == 3) {
				statusCarrier3 = status;
				statusDate3 = date.Today();
				if (rfp != '')
					rfps[3] = rfp;
				statuses3 = buildSelectOptions(status);
			} else if (index == 4) {
				statusCarrier4 = status;
				statusDate4 = date.Today();
				if (rfp != '')
					rfps[4] = rfp;
				statuses4 = buildSelectOptions(status);
			} else if (index == 5) {
				statusCarrier5 = status;
				statusDate5 = date.Today();
				if (rfp != '')
					rfps[5] = rfp;
				statuses5 = buildSelectOptions(status);
			} else if (index == 6) {
				statusCarrier6 = status;
				statusDate6 = date.Today();
				if (rfp != '')
					rfps[6] = rfp;
				statuses6 = buildSelectOptions(status);
			} else if (index == 7) {
				statusCarrier7 = status;
				statusDate7 = date.Today();
				if (rfp != '')
					rfps[7] = rfp;
				statuses7 = buildSelectOptions(status);
			} else if (index == 8) {
				statusCarrier8 = status;
				statusDate8 = date.Today();
				if (rfp != '')
					rfps[8] = rfp;
				statuses8 = buildSelectOptions(status);
			} else if (index == 9) {
				statusCarrier9 = status;
				statusDate9 = date.Today();
				if (rfp != '')
					rfps[9] = rfp;
				statuses9 = buildSelectOptions(status);
			} else if (index == 10) {
				statusCarrier10 = status;
				statusDate10 = date.Today();
				if (rfp != '')
					rfps[10] = rfp;
				statuses10 = buildSelectOptions(status);
			} else if (index == 11) {
				statusCarrier11 = status;
				statusDate11 = date.Today();
				if (rfp != '')
					rfps[11] = rfp;
				statuses11 = buildSelectOptions(status);
			} else if (index == 12) {
				statusCarrier12 = status;
				statusDate12 = date.Today();
				if (rfp != '')
					rfps[12] = rfp;
				statuses12 = buildSelectOptions(status);
			} else if (index == 13) {
				statusCarrier13 = status;
				statusDate13 = date.Today();
				if (rfp != '')
					rfps[13] = rfp;
				statuses13 = buildSelectOptions(status);
			} else if (index == 14) {
				statusCarrier14 = status;
				statusDate14 = date.Today();
				if (rfp != '')
					rfps[14] = rfp;
				statuses14 = buildSelectOptions(status);
			} else if (index == 15) {
				statusCarrier15 = status;
				statusDate15 = date.Today();
				if (rfp != '')
					rfps[15] = rfp;
				statuses15 = buildSelectOptions(status);
			} else if (index == 16) {
				statusCarrier16 = status;
				statusDate16 = date.Today();
				if (rfp != '')
					rfps[16] = rfp;
				statuses16 = buildSelectOptions(status);
			} else if (index == 17) {
				statusCarrier17 = status;
				statusDate17 = date.Today();
				if (rfp != '')
					rfps[17] = rfp;
				statuses17 = buildSelectOptions(status);
			} else if (index == 18) {
				statusCarrier18 = status;
				statusDate18 = date.Today();
				if (rfp != '')
					rfps[18] = rfp;
				statuses18 = buildSelectOptions(status);
			} else if (index == 19) {
				statusCarrier19 = status;
				statusDate19 = date.Today();
				if (rfp != '')
					rfps[19] = rfp;
				statuses19 = buildSelectOptions(status);
			} else if (index == 20) {
				statusCarrier20 = status;
				statusDate20 = date.Today();
				if (rfp != '')
					rfps[20] = rfp;
				statuses20 = buildSelectOptions(status);
			} else if (index == 21) {
				statusCarrier21 = status;
				statusDate21 = date.Today();
				if (rfp != '')
					rfps[21] = rfp;
				statuses21 = buildSelectOptions(status);
			} else if (index == 22) {
				statusCarrier22 = status;
				statusDate22 = date.Today();
				if (rfp != '')
					rfps[22] = rfp;
				statuses22 = buildSelectOptions(status);
			} else if (index == 23) {
				statusCarrier23 = status;
				statusDate23 = date.Today();
				if (rfp != '')
					rfps[23] = rfp;
				statuses23 = buildSelectOptions(status);
			} else if (index == 24) {
				statusCarrier24 = status;
				statusDate24 = date.Today();
				if (rfp != '')
					rfps[24] = rfp;
				statuses24 = buildSelectOptions(status);
			} else if (index == 25) {
				statusCarrier25 = status;
				statusDate25 = date.Today();
				if (rfp != '')
					rfps[25] = rfp;
				statuses25 = buildSelectOptions(status);
			} else if (index == 26) {
				statusCarrier26 = status;
				statusDate26 = date.Today();
				if (rfp != '')
					rfps[26] = rfp;
				statuses26 = buildSelectOptions(status);
			} else if (index == 27) {
				statusCarrier27 = status;
				statusDate27 = date.Today();
				if (rfp != '')
					rfps[27] = rfp;
				statuses27 = buildSelectOptions(status);
			} else if (index == 28) {
				statusCarrier28 = status;
				statusDate28 = date.Today();
				if (rfp != '')
					rfps[28] = rfp;
				statuses28 = buildSelectOptions(status);
			} else if (index == 29) {
				statusCarrier29 = status;
				statusDate29 = date.Today();
				if (rfp != '')
					rfps[29] = rfp;
				statuses29 = buildSelectOptions(status);
			} else if (index == 30) {
				statusCarrier30 = status;
				statusDate30 = date.Today();
				if (rfp != '')
					rfps[30] = rfp;
				statuses30 = buildSelectOptions(status);
			} else {
				//TO DO
			}
		}

		public void cancelOtherAcceptStatuses(integer index) {
			string[] carrierStatuses = new List<string>{
				statusCarrier0,
				statusCarrier1,
				statusCarrier2,
				statusCarrier3,
				statusCarrier4,
				statusCarrier5,
				statusCarrier6,
				statusCarrier7,
				statusCarrier8,
				statusCarrier9,
				statusCarrier10,
				statusCarrier11,
				statusCarrier12,
				statusCarrier13,
				statusCarrier14,
				statusCarrier15,
				statusCarrier16,
				statusCarrier17,
				statusCarrier18,
				statusCarrier19,
				statusCarrier20,
				statusCarrier21,
				statusCarrier22,
				statusCarrier23,
				statusCarrier24,
				statusCarrier25,
				statusCarrier26,
				statusCarrier27,
				statusCarrier28,
				statusCarrier29,
				statusCarrier30
			};
			for (integer i = 0; i < carrierStatuses.size(); i++) {
				if (i == index)
					continue;
				else if (carrierStatuses[i] == '3')
					carrierStatuses[i] = '2';
			}
			statusCarrier0 = carrierStatuses[0];
			statusCarrier1 = carrierStatuses[1];
			statusCarrier2 = carrierStatuses[2];
			statusCarrier3 = carrierStatuses[3];
			statusCarrier4 = carrierStatuses[4];
			statusCarrier5 = carrierStatuses[5];
			statusCarrier6 = carrierStatuses[6];
			statusCarrier7 = carrierStatuses[7];
			statusCarrier8 = carrierStatuses[8];
			statusCarrier9 = carrierStatuses[9];
			statusCarrier10 = carrierStatuses[10];
			statusCarrier11 = carrierStatuses[11];
			statusCarrier12 = carrierStatuses[12];
			statusCarrier13 = carrierStatuses[13];
			statusCarrier14 = carrierStatuses[14];
			statusCarrier15 = carrierStatuses[15];
			statusCarrier16 = carrierStatuses[16];
			statusCarrier17 = carrierStatuses[17];
			statusCarrier18 = carrierStatuses[18];
			statusCarrier19 = carrierStatuses[19];
			statusCarrier20 = carrierStatuses[20];
			statusCarrier21 = carrierStatuses[21];
			statusCarrier22 = carrierStatuses[22];
			statusCarrier23 = carrierStatuses[23];
			statusCarrier24 = carrierStatuses[24];
			statusCarrier25 = carrierStatuses[25];
			statusCarrier26 = carrierStatuses[26];
			statusCarrier27 = carrierStatuses[27];
			statusCarrier28 = carrierStatuses[28];
			statusCarrier29 = carrierStatuses[29];
			statusCarrier30 = carrierStatuses[30];
		}

		public list<SelectOption> buildSelectOptions(string selected) {
			list<SelectOption> statuses = new List<SelectOption>();

			if (selected == '1') {
				statuses.add(new SelectOption('1', Label.Novidea_HPC.Sent));
				statuses.add(new SelectOption('2', Label.Novidea_HPC.Accepted));
			} else if (selected == '2' || selected == '3') {
				statuses.add(new SelectOption('2', Label.Novidea_HPC.Accepted));
				statuses.add(new SelectOption('3', Label.Novidea_HPC.Approved));
			}

			return statuses;
		}
	}

	public void createRFP() {
		products = new List<AggregateResult>();
		carrierlist = new List<CarrierWrapper>();
		init();
	}

	public void convertToPolicy() {
		//system.debug(parentProductId);
		ProductWrapper wp = originalProToPw.get(parentProductId);
		wp.proposalToConvert = null;
		//wp.isConverted = true;
	}

	public void deleteColumn() {
		list<Novidea_HPC__Request_For_Proposal__c> rfps = new List<Novidea_HPC__Request_For_Proposal__c>();
		list<Novidea_HPC__Proposal__c> props = new List<Novidea_HPC__Proposal__c>();
		//system.debug(index);
		CarrierWrapper cw = carrierlist.remove(integer.valueOf(index));
		if (cw != null) {
			rfps = [
				SELECT Novidea_HPC__Application__c, Novidea_HPC__Carrier__c
				FROM Novidea_HPC__Request_For_Proposal__c
				WHERE Novidea_HPC__Application__c = :applicationId AND Novidea_HPC__Carrier__c = :cw.carrierId
			];
			props = [
				SELECT Novidea_HPC__Application__c, Novidea_HPC__Carrier__c
				FROM Novidea_HPC__Proposal__c
				WHERE Novidea_HPC__Application__c = :applicationId AND Novidea_HPC__Carrier__c = :cw.carrierId
			];
		}
		if (!rfps.isEmpty()) {
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
				NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Request_For_Proposal__c' }, NOVU.SecurityUtils.CRUD.DLT);
			}

			database.delete(rfps);
		}
		if (!props.isEmpty()) {
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
				NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Proposal__c' }, NOVU.SecurityUtils.CRUD.DLT);
			}

			database.delete(props);
		}
		products = new List<AggregateResult>();
		carrierlist = new List<CarrierWrapper>();
		init();
	}

	public void changeStatus() {
		//try{
		carrier = carrierlist.get(integer.valueOf(index));
		ProductWrapper wp = originalProToPw.get(parentProductId);
		integer inx = integer.valueOf(index);
		string[] statusCarrier = new List<string>{
			wp.statusCarrier0,
			wp.statusCarrier1,
			wp.statusCarrier2,
			wp.statusCarrier3,
			wp.statusCarrier4,
			wp.statusCarrier5,
			wp.statusCarrier6,
			wp.statusCarrier7,
			wp.statusCarrier8,
			wp.statusCarrier9,
			wp.statusCarrier10,
			wp.statusCarrier11,
			wp.statusCarrier12,
			wp.statusCarrier13,
			wp.statusCarrier14,
			wp.statusCarrier15,
			wp.statusCarrier16,
			wp.statusCarrier17,
			wp.statusCarrier18,
			wp.statusCarrier19,
			wp.statusCarrier20,
			wp.statusCarrier21,
			wp.statusCarrier22,
			wp.statusCarrier23,
			wp.statusCarrier24,
			wp.statusCarrier25,
			wp.statusCarrier26,
			wp.statusCarrier27,
			wp.statusCarrier28,
			wp.statusCarrier29,
			wp.statusCarrier30
		};

		system.debug(index + ' ' + inx + ' ' + statusCarrier + ' ' + parentProductId + ' ' + originalProToPw);
		system.debug(statusCarrier[inx]);
		if (statusCarrier[inx] == '2') {
			//revived
			List<Novidea_HPC__Product__c> proposalProducts = new List<Novidea_HPC__Product__c>();
			createProposals(wp, carrier, inx, carrierToProposal, proposalProducts);
			if (!proposalProducts.isEmpty()) {
				if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
					NOVU.SecurityUtils.checkFields(
						'Novidea_HPC__Product__c',
						new Set<String>{
							'Novidea_HPC__Policy__c',
							'Novidea_HPC__Previous_Policy__c',
							'Novidea_HPC__Product__c',
							'Novidea_HPC__Request_for_Proposal__c',
							'Novidea_HPC__Commission_Amount__c',
							'Novidea_HPC__Fee_Amount__c',
							'Novidea_HPC__Premium__c',
							'Novidea_HPC__Premium_Net__c',
							'Novidea_HPC__Carrier__c',
							'Novidea_HPC__Proposal__c'
						},
						NOVU.SecurityUtils.FLS.CREATE
					);
				}
				Database.insert(proposalProducts);
			}
		} else if (statusCarrier[inx] == '3') {
			//approved
			approveProposalsProducts(wp, carrier, inx, carrierToProposal);
		}
	}

	//AEF:
	public list<Id> massCreateProposalList(list<Id> selectedProductIds) {
		list<Id> proposalToConvertList = new List<Id>();
		List<Novidea_HPC__Product__c> clonedProducts = new List<Novidea_HPC__Product__c>();
		for (Integer inx = 0; inx < carrierlist.size(); inx++) {
			carrier = carrierlist[inx];
			for (Id parentProductId : selectedProductIds) {
				ProductWrapper wp = originalProToPw.get(parentProductId);
				string[] statusCarrier = new List<string>{
					wp.statusCarrier0,
					wp.statusCarrier1,
					wp.statusCarrier2,
					wp.statusCarrier3,
					wp.statusCarrier4,
					wp.statusCarrier5,
					wp.statusCarrier6,
					wp.statusCarrier7,
					wp.statusCarrier8,
					wp.statusCarrier9,
					wp.statusCarrier10,
					wp.statusCarrier11,
					wp.statusCarrier12,
					wp.statusCarrier13,
					wp.statusCarrier14,
					wp.statusCarrier15,
					wp.statusCarrier16,
					wp.statusCarrier17,
					wp.statusCarrier18,
					wp.statusCarrier19,
					wp.statusCarrier20,
					wp.statusCarrier21,
					wp.statusCarrier22,
					wp.statusCarrier23,
					wp.statusCarrier24,
					wp.statusCarrier25,
					wp.statusCarrier26,
					wp.statusCarrier27,
					wp.statusCarrier28,
					wp.statusCarrier29,
					wp.statusCarrier30
				};
				if (statusCarrier[inx] == '1') {
					createProposals(wp, carrier, inx, carrierToProposal, clonedProducts);
				}
				if (String.isNotBlank(wp.proposalToConvert))
					proposalToConvertList.add(wp.proposalToConvert);
			}
		}
		if (!clonedProducts.isEmpty()) {
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Product__c',
					new Set<String>{
						'Novidea_HPC__Product__c',
						'Novidea_HPC__Previous_Policy__c',
						'Novidea_HPC__Policy__c',
						'Novidea_HPC__Request_for_Proposal__c',
						'Novidea_HPC__Application__c',
						'Novidea_HPC__Expected_Premium__c',
						'Novidea_HPC__Expected_Fees__c',
						'Novidea_HPC__Expected_Premium_Net__c',
						'Novidea_HPC__Expected_Commission_Amount__c',
						'Novidea_HPC__Premium__c',
						'Novidea_HPC__Premium_Net__c',
						'Novidea_HPC__Fee_Amount__c',
						'Novidea_HPC__Commission_Amount__c'
					},
					NOVU.SecurityUtils.FLS.CREATE
				);
			}

			Database.insert(clonedProducts);
		}
		return proposalToConvertList;
	}

	public void createProposals(
		ProductWrapper wp,
		CarrierWrapper carrier,
		integer inx,
		map<Id, Id> carrierToProposal,
		List<Novidea_HPC__Product__c> clonedProducts
	) {
		Id proposal = createProposal(wp, carrier, applicationId, carrierToProposal, inx, clonedProducts);
		wp.noAcceptedStatusCheck = proposal;
		wp.getPopulateWrapper(inx, '2', '');
		wp.proposalToConvert = null;
	}

	public static Id createProposal(
		RFPTableCo.ProductWrapper wrapperProduct,
		RFPTableCo.CarrierWrapper carrier,
		Id ApplicationId,
		Map<Id, Id> carrierToProposal,
		Integer inx,
		List<Novidea_HPC__Product__c> clonedProducts
	) {
		list<Id> appProductsIds = new List<Id>();
		appProductsIds.add(wrapperProduct.appProductId);
		list<Id> rfps = new List<Id>();
		rfps.add(wrapperProduct.rfps[inx]);
		list<Novidea_HPC__Product__c> RFPProducts = cloneProducts(rfps, carrier, appProductsIds);
		Novidea_HPC__Product__c RFPproduct = RFPProducts[0];

		Novidea_HPC__Product__c cloneProduct = Novidea_HPC.ProductHelper.createProposalFromRfp(RFPproduct);
		if (!carrierToProposal.containsKey(carrier.carrierId)) {
			Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c();
			proposal.Novidea_HPC__Request_for_Proposal__c = RFPproduct.Novidea_HPC__Request_for_Proposal__c;
			proposal.Novidea_HPC__Carrier__c = carrier.carrierId;
			proposal.Novidea_HPC__Application__c = ApplicationId;
			proposal.Name = Label.Application + carrier.carrierName + ' ' + date.today().format();
			if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
				NOVU.SecurityUtils.checkFields(
					'Novidea_HPC__Proposal__c',
					new Set<String>{ 'Novidea_HPC__Request_for_Proposal__c', 'Novidea_HPC__Carrier__c', 'Novidea_HPC__Application__c', 'Name' },
					NOVU.SecurityUtils.FLS.CREATE
				);
			}
			Database.insert(proposal);
			carrierToProposal.put(carrier.carrierId, proposal.Id);
			cloneProduct.Novidea_HPC__Proposal__c = proposal.Id;
		} else
			cloneProduct.Novidea_HPC__Proposal__c = carrierToProposal.get(carrier.carrierId);

		cloneProduct.Novidea_HPC__Product__c = RFPproduct.Id;
		cloneProduct.Novidea_HPC__Carrier__c = carrier.carrierId;

		clonedProducts.add(cloneProduct);
		return carrierToProposal.get(carrier.carrierId);
	}

	public static list<Novidea_HPC__Product__c> cloneProducts(list<Id> rfps, RFPTableCo.CarrierWrapper carrier, list<Id> appProductsIds) {
		Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
		map<String, Schema.DescribeFieldResult> productFields;
		Boolean selectAllProductFields = gs != null && gs.Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c == true;
		if (selectAllProductFields) {
			productFields = NOVU.FlatModelHelper.getFieldsDescribeWithNameSpace('novidea_hpc__product__c');
		} else {
			productFields = NOVU.FlatModelHelper.getFieldsDescribeByFilter('Novidea_HPC__Product__c', null);
		}
		String fromPart = 'Novidea_HPC__Product__c';
		String whereClause = 'Novidea_HPC__Product__c IN(\'' + String.join(appProductsIds, '\',\'') + '\')\n';
		whereClause += 'AND Novidea_HPC__Request_for_Proposal__c IN(\'' + String.join(rfps, '\',\'') + '\')\n';
		if (carrier != null)
			whereClause += 'AND Novidea_HPC__Carrier__c = \'' + carrier.carrierId + '\'\n';
		//format is removing ' from string so it requires double commas
		if (selectAllProductFields) {
			NOVU.SecurityUtils.SecureDynamicQuery sdq = new NOVU.SecurityUtils.SecureDynamicQuery();
			sdq.selectFields = productFields.keySet();
			sdq.fromObject = fromPart;
			sdq.whereClause = whereClause;
			sdq.subQueries = new List<NOVU.SecurityUtils.SecureDynamicQuery>{};
			return NOVU.FieldUtils.executeQuery(sdq);
		} else {
			String query = 'SELECT ';
			query += (String.join(new List<String>(productFields.keySet()), ',') + '\n');
			query += ('FROM ' + fromPart + '\n');
			query += ('WHERE ' + whereClause);
			return Database.query(query);
		}
	}

	public void approveProposalsProducts(ProductWrapper wp, CarrierWrapper carrier, integer inx, map<Id, Id> carrierToProposal) {
		Novidea_HPC__Product__c approvedProduct = approveProducts(wp, carrier, carrierToProposal, inx, applicationId);
		wp.proposalToConvert = approvedProduct != null ? approvedProduct.Novidea_HPC__Proposal__c : '';
		wp.proposalProductIdToConvert = approvedProduct != null ? approvedProduct.Id : null;
		wp.getPopulateWrapper(inx, '3', '');
		wp.cancelOtherAcceptStatuses(inx);
	}

	public static Novidea_HPC__Product__c approveProducts(
		RFPTableCo.ProductWrapper wrapperProduct,
		RFPTableCo.CarrierWrapper carrier,
		map<Id, Id> carrierToProposal,
		integer inx,
		Id ApplicationId
	) {
		Id proposal = carrierToProposal.get(carrier.carrierId);
		list<Novidea_HPC__Product__c> propProducts = new List<Novidea_HPC__Product__c>();
		Novidea_HPC__Product__c approvedProduct = null;
		list<Novidea_HPC__Proposal__c> proposals = [
			SELECT
				Novidea_HPC__Application__c,
				(
					SELECT
						Novidea_HPC__Status__c,
						Novidea_HPC__Proposal__c,
						Novidea_HPC__Carrier__c,
						Novidea_HPC__Product__r.Novidea_HPC__Product__c
					FROM Novidea_HPC__Products__r
					WHERE Novidea_HPC__Product__r.Novidea_HPC__Product__c = :wrapperProduct.appProductId
				)
			FROM Novidea_HPC__Proposal__c
			WHERE Novidea_HPC__Application__c = :ApplicationId
		];
		for (Novidea_HPC__Proposal__c prop : proposals) {
			for (Novidea_HPC__Product__c product : prop.Novidea_HPC__Products__r) {
				if (product.Novidea_HPC__Proposal__c == proposal) {
					product.Novidea_HPC__Status__c = 'Accepted';
					approvedProduct = product;
				} else if (product.Novidea_HPC__Carrier__c != carrier.carrierId) {
					product.Novidea_HPC__Status__c = null;
				}
				propProducts.add(product);
			}
		}
		if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckFLSUpdate')) {
			NOVU.SecurityUtils.checkFields(
				'Novidea_HPC__Product__c',
				new Set<String>{ 'Novidea_HPC__Novidea_HPC__Status__c' },
				NOVU.SecurityUtils.FLS.UPDT
			);
		}
		Database.update(propProducts);
		return approvedProduct;
	}

	public void init() {
		//try{
		Pagereference appId = new Pagereference('/' + applicationId);
		originalProToPw = new Map<Id, ProductWrapper>();
		carriersMap = new Map<string, integer>();
		//TO DO press on buttom of another page which create rfp and product under
		set<Id> rfpProductsIds = new Set<Id>();
		list<AggregateResult> products = [
			SELECT
				MAX(Id) proId,
				Novidea_HPC__Request_For_proposal__c rfp,
				Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__r.name iName,
				Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__r.Id carrierId,
				Novidea_HPC__Product__c
			FROM Novidea_HPC__Product__c
			WHERE Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Application__c = :applicationId
			GROUP BY
				Name,
				Novidea_HPC__Product__c,
				Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__c,
				Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__r.name,
				Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__r.Id,
				Novidea_HPC__Request_For_proposal__c

			ORDER BY Name, Novidea_HPC__Request_For_proposal__r.Novidea_HPC__Carrier__c
		];
		system.debug(products);
		//if(products.isEmpty())return ;
		integer i = -1;
		// popoulate all carriers with its number
		for (AggregateResult product : products) {
			string carrierName = (string) product.get('iName');
			Id carrierId = (Id) product.get('carrierId');
			if (!carriersMap.containsKey(carrierName) && i < 31) {
				carriersMap.put(carrierName, ++i);
				CarrierWrapper cw = new CarrierWrapper(carrierName, carrierId);
				carrierlist.add(cw);
			}
			system.debug(carrierlist);
			rfpProductsIds.add((Id) product.get('proId'));
		}
		map<Id, list<Novidea_HPC__Product__c>> appProductToRfpProducts = new Map<Id, list<Novidea_HPC__Product__c>>();
		map<Id, list<Novidea_HPC__Product__c>> appProductToProposalProducts = new Map<Id, list<Novidea_HPC__Product__c>>();
		map<Id, string> appProIdToAppProName = new Map<Id, string>();
		list<Novidea_HPC__Product__c> rfpProducts;
		list<Novidea_HPC__Product__c> propProducts;
		//system.debug(rfpProductsIds);

		for (Novidea_HPC__Product__c appProduct : [SELECT Id FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Application__c = :applicationId]) {
			rfpProducts = new List<Novidea_HPC__Product__c>();
			propProducts = new List<Novidea_HPC__Product__c>();
			for (Novidea_HPC__Product__c product : [
				SELECT
					Name,
					Novidea_HPC__Status_Date__c,
					Novidea_HPC__Product__r.Novidea_HPC__Product__c,
					Novidea_HPC__Carrier__c,
					Novidea_HPC__Carrier__r.Name,
					Novidea_HPC__Status__c,
					Novidea_HPC__Proposal__c
				FROM Novidea_HPC__Product__c
				WHERE
					(Id IN :rfpProductsIds
					AND Novidea_HPC__Product__c = :appProduct.Id)
					OR (Novidea_HPC__Product__c IN :rfpProductsIds
					AND Novidea_HPC__Product__r.Novidea_HPC__Product__c = :appProduct.Id)
			]) {
				if (rfpProductsIds.contains(product.Id)) {
					//rfp products
					rfpProducts.add(product);
					appProIdToAppProName.put(product.Id, product.Name);
				} else {
					propProducts.add(product);
					carrierToProposal.put(product.Novidea_HPC__Carrier__c, product.Novidea_HPC__Proposal__c);
				}
			}
			//system.debug(rfpProducts);
			//system.debug(propProducts);
			if (!rfpProducts.isEmpty())
				appProductToRfpProducts.put(appProduct.Id, rfpProducts);
			if (!propProducts.isEmpty())
				appProductToProposalProducts.put(appProduct.Id, propProducts);
		}

		//system.debug(appProductToRfpProducts);
		//system.debug(appProductToProposalProducts);

		// make map of products  with its proposal carriers
		for (AggregateResult product : products) {
			Id parentProductId = (Id) product.get('Novidea_HPC__Product__c');
			Id rfpProductId = (Id) product.get('proId');
			string carrierName = (string) product.get('iName');
			Id rfpId = (string) product.get('rfp');
			if (!originalProToPw.containsKey(parentProductId)) {
				//product with first carrier
				ProductWrapper pw = new ProductWrapper(parentProductId, appProIdToAppProName.get(rfpProductId));
				pw.getPopulateWrapper(carriersMap.get(carrierName), '1', rfpId);
				originalProToPw.put(parentProductId, pw);
			} else {
				//same product diffrent carrier
				originalProToPw.get(parentProductId).getPopulateWrapper(carriersMap.get(carrierName), '1', rfpId);
			}
		}

		for (Id appProduct : appProductToProposalProducts.keySet()) {
			for (Novidea_HPC__Product__c propProduct : appProductToProposalProducts.get(appProduct)) {
				originalProToPw.get(appProduct).noAcceptedStatusCheck = propProduct.Novidea_HPC__Proposal__c; // unable checkbox after status accept
				//system.debug(originalProToPw.get(appProduct).noAcceptedStatusCheck);
				string carrierNameProposal = propProduct.Novidea_HPC__Carrier__r.Name;
				if (propProduct.Novidea_HPC__Status__c == 'Accepted' || propProduct.Novidea_HPC__Status__c == 'Converted') {
					originalProToPw.get(appProduct).getPopulateWrapper(carriersMap.get(carrierNameProposal), '3', '');
					originalProToPw.get(appProduct).proposalToConvert = propProduct.Novidea_HPC__Proposal__c;
					originalProToPw.get(appProduct).proposalProductIdToConvert = propProduct.Id;
					if (propProduct.Novidea_HPC__Status__c == 'Converted') {
						originalProToPw.get(appProduct).isConverted = true;
					}
				} else {
					originalProToPw.get(appProduct).getPopulateWrapper(carriersMap.get(carrierNameProposal), '2', '');
				}
			}
		}

		system.debug(originalProToPw);
	}

	@testVisible
	private static void testPasser() {
		List<Account> ac = new List<Account>();
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
		ac.add(new Account());
	}
}