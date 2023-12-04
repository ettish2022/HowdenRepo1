global with sharing class mergeTransactionCO{
		private static final Integer MAX_NAME_LENGTH = 80;        
        private final static map<String,String> apexJobStatusTranslation = new map<String,String>();
       
        //diana
        public static string categoriesName 
        {
        	get{
        		if (categoriesName == null)
        			return '';
    			return categoriesName;
        	} 
        	private set;
        }
        
        
        static{
        	map<String, Schema.SObjectField> fieldsMap = AsyncApexJob.getsobjecttype().getDescribe().fields.getMap();
	    	Schema.DescribeFieldResult fieldDesc = fieldsMap.get('status').getDescribe();
	    	for(Schema.PicklistEntry pe : fieldDesc.getPicklistValues()){
	    		apexJobStatusTranslation.put(pe.getValue(), pe.getLabel());
	    	}
	    	list<string> categoriesId = General__c.getInstance().Personal_Category__c==null?null:General__c.getInstance().Personal_Category__c.split(',');
	    	list<Novidea_HPC__Product_Category__c> categories;
	    	if(categoriesId!=null){
	    		categories = [SELECT Name,Default_Team_Member_Role__c FROM Novidea_HPC__Product_Category__c WHERE Id IN: categoriesId];
	    	}
	    	if(categories!=null){
		    	for(Novidea_HPC__Product_Category__c cat : categories)
	        		categoriesName += (cat.Name + ', ');
		    	categoriesName = categoriesName.substring(0,categoriesName.length()-2);
	    	}
        }
        // variables for the autoComplete
        
        public string todayYear {get;set;}
        
        public string todayMonth {get;set;}
        
        public string fromYear {get;set;}
        
        public string fromMonth {get;set;}
         
        public string sFHost {get;set;} 
        
        //public string allInsuranceType {get;set;}
        
        public static string brokerNumberPrefix {get{return Novidea_HPC__Broker_Number__c.sObjectType.getDescribe().getKeyPrefix();}}
       
        public static string policyPrefix {get{return Novidea_HPC__Policy__c.sObjectType.getDescribe().getKeyPrefix();}}
        
        public string transactionName {get;set;}
        
             
        //constractor
        public mergeTransactionCO(){
            todayYear = '';
            todayMonth = '';
            fromYear = '';
            fromMonth = '';
                
            if ( ApexPages.currentPage().getParameters().get('name') != null ){
                transactionName = Encodingutil.urlDecode( ApexPages.currentPage().getParameters().get('name'),'UTF-8');
            }
            else{
               transactionName = '' ;
            }

            sFHost = string.valueOf(url.getSalesforceBaseUrl().toExternalForm());
            //allInsuranceType = '';
            
            /*List<Novidea_HPC__Product_Def__c> lsProductDef = [select Name from Novidea_HPC__Product_Def__c where show_in_merge_screen__c =true];
            if (lsProductDef.size()>0){
                for (Novidea_HPC__Product_Def__c pd :lsProductDef){
                	allInsuranceType = allInsuranceType + pd.Name+',';
                }
            } */
//            system.debug('sFHost: ' + sFHost);
         }    
                
                
               
          
        
         
        //function for search
        public static list<Policy_Transaction__c> doSearch(String clientId, String accountId, String carrierId, String policyTransactionId,
                               String startDate, String endDate, String InsurancedTypeStr, String TransStatusStr, String profitCenter){
                                            
/*                                                
            system.debug('Account: ' + accountId);
            system.debug('carrier: '+ carrierId );
            system.debug('policyTransactionId: '+ policyTransactionId );
            system.debug('startDate: '+ startDate );
            system.debug('endDate: '+ endDate );
            system.debug('TransStatusStr: '+ TransStatusStr );
            system.debug('InsurancedTypeStr: '+ InsurancedTypeStr );
            system.debug('profitCenter: '+ profitCenter );
*/          

			set<id> groupMembers = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser();    
                		
            string query = 
            'SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c, Agent_Discount_Written_In_Carrier__c,\n'+
                     'Commission_Written_In_Carrier__c, customer_full_name__c, premium__c,Premium_neto__c,\n'+
                     'Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c,\n' +
                     'comments_customer_account__c, is_Account_Found__c, Is_Broker_Found__c,Is_Policy_found__c,\n'+
                     'Is_carrier_Found__c, Customer_Account__r.Name, Broker_Number__r.Name, Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name,\n'+
                     'Policy__r.Novidea_HPC__Policy_Number__c, vehicle_number__c, product_from_insurance_company__c, file_name__c,\n'+ 
                     'comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c,\n'+ 
                     'OwnerId, Name, Policy__r.Novidea_HPC__Client__r.Name, Policy__r.Novidea_HPC__Client__c,\n'+
                     'Insured_number__c, Insured_Type__c, Insurance_Type__c, Carrier_File_Code__c, Id,\n'+ 
                     'Customer_Account__c, Comments_Policy__c, Comments_Insurance_Company__c,\n'+ 
                     'Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, Address__c\n'+
           'FROM Policy_Transaction__c\n';
            
            
            // bulding the where
            boolean firstIf = true;
            
            if (String.isNotBlank(clientId) || String.isNotBlank(accountId) || 
                String.isNotBlank(policyTransactionId)|| String.isNotBlank(carrierId) || 
                String.isNotBlank(startDate) || String.isNotBlank(endDate) || 
                String.isNotBlank(InsurancedTypeStr) || String.isNotBlank(TransStatusStr) || 
                String.isNotBlank(profitCenter) ||
                !ArrayUtils.isSetNullOrEmpty(groupMembers)){ 
                    query += ' WHERE ';
                    
                    //bulding the where acording to user group
                    if(!ArrayUtils.isSetNullOrEmpty(groupMembers)){                                               
                        string groupConditon = ' OwnerId IN: groupMembers\n' ; 
                        if(firstIf){
	                        query += groupConditon ;
	                        firstIf = false;
                        }
                        else{
                        	query +=' AND ' +groupConditon ;
                        }                                                       
                    }
                    
                    // bulding the where acording to the selected status
                    if(String.isNotBlank(TransStatusStr)){  
                        string TransStatusCondtion = ' Status__c IN (';
                        TransStatusCondtion +='\'';
                        TransStatusCondtion += TransStatusStr.replace(',','\',\'');
                        TransStatusCondtion += '\')';

                        if(firstIf){
	                        query += TransStatusCondtion ;
	                        firstIf = false;
                        }
                        else{
                        	query +=' AND ' + TransStatusCondtion ;
                        }                                                       
                    }
                    // bulding the where acording to the selected  insurance Type
                    if(String.isNotBlank(InsurancedTypeStr)){                                               
                        string InsurancedTypeArrCondtion = ' Insurance_Type__c IN (';
                        InsurancedTypeArrCondtion +='\'';
                        InsurancedTypeArrCondtion += InsurancedTypeStr.replace(',','\',\'');
                        InsurancedTypeArrCondtion += '\')';
                        if(firstIf){
                            query += InsurancedTypeArrCondtion ;
                            firstIf = false;
                        }
                        else{
	                        query +=' AND ' +InsurancedTypeArrCondtion ;
                        }
                    }
                    //bulding the where acording to Account
                    if(String.isNotBlank(accountId)){                                               
                        string accountConditon = ' Customer_Account__c = \'' + accountId + '\'' ; 
                        if(firstIf){
	                        query += accountConditon ;
	                        firstIf = false;
                        }
                        else{
                        	query +=' AND ' +accountConditon ;
                        }                                                       
                    }
                    
                    //bulding the where acording to carrier
                    if(String.isNotBlank(carrierId)){                                               
	                    string carrierConditon = ' Carrier__c = \'' + carrierId + '\'' ; 
	                    if(firstIf){
	                        query += carrierConditon ;
	                        firstIf = false;
	                    }
	                    else{
	                    	query +=' AND ' +carrierConditon ;
	                    }                                                       
                    }
                    
                    // bulding the where acording to agent 
                    if(String.isNotBlank(clientId)){                                               
                        string clientConditon = ' Broker_Number__c= \'' + clientId + '\'' ; 
                        if(firstIf){
                            query += clientConditon ;
                            firstIf = false;
                        }
                        else{
                        	query +=' AND ' +clientConditon ;
                        }                                                       
                    }
                    
                    // bulding the where acording to policyTransaction 
                    if(String.isNotBlank(policyTransactionId)){                                               
	                    string policyTransactioConditon = ' Name = \''+ policyTransactionId+ '\'' ; 
	                    if(firstIf){
                            query += policyTransactioConditon ;
                            firstIf = false;
	                    }
	                    else{
	                    	query +=' AND ' + policyTransactioConditon ;
	                    }                                                       
                    }
                    // bulding the where acording to startDate  2005-10-08T01:02:03Z
                    if(String.isNotBlank(startDate)){       
                        string[] dateArr = startDate.split('/');
                        startDate = dateArr[2] +'-' + dateArr[1] +'-' + dateArr[0];
                        string startDateConditon = ' Production_Date__c >= ' + startDate ; 
                        if(firstIf){
                            query += startDateConditon ;
                            firstIf = false;
                        }
                        else{
                        	query +=' AND ' + startDateConditon ;
                        }                                                       
                    }
                    
                    if(String.isNotBlank(endDate)){       
	                    string[] dateArr = endDate.split('/');
	                    endDate = dateArr[2] +'-' + dateArr[1] +'-' + dateArr[0];
	                    string enDateConditon = ' Production_Date__c <= ' + endDate ; 
	                    if(firstIf){
                            query += enDateConditon ;
                            firstIf = false;
	                    }
	                    else{
	                    	query +=' AND ' + enDateConditon ;
	                    }                                                       
                    }
                    
                    if(String.isNotBlank(profitCenter)){
	                    string policyTransactioConditon;
	                    if('null'.equals(profitCenter)) policyTransactioConditon = ' Broker_Number__c= null';
	                    else policyTransactioConditon = ' Broker_Number__r.Novidea_HPC__Profit_Center__c = \'' + profitCenter + '\'' ; 
	                    if(firstIf){
                            query += policyTransactioConditon ;
                            firstIf = false;
	                    }
	                    else{
	                    	query +=' AND ' + policyTransactioConditon ;
	                    }                                                       
                    	
                    }
                     
                }  
                query += ' ORDER BY Policy_number_from_Insurance_company__c, product_from_insurance_company__c, endorsement_number__c';
                query += ' LIMIT 5000'; 
                list<Policy_Transaction__c> lsPolicyTransaction = database.query(query);
                return lsPolicyTransaction;        
        }
        
        
      global class WrappedPolicyTransaction{
            string  actions = '';
            string  fullName ='';
            string  checkBoxField = '' ;
            string  Id = '';            
            string  Address = ''; 
            string  Agent_number_from_Insurance_comapny = ''; 
            string  CarrierID = ''; 
            string  CarrierName = '';               
            string  Carrier_BrokerId = ''; 
            string  Carrier_BrokerName = ''; 
            string  Comments_Agent_number = ''; 
            string  comments_for_Account = ''; 
            string  Comments_Insurance_Company = ''; 
            string  Comments_PolicyId = ''; 
            string  PolicyName = '';
            string  PolicyAccountName = '';  
            string  Customer_AccountId = ''; 
            string  AccountName = '';                                                 
            string  Insurance_Type = ''; 
            string  Insured_number = ''; 
            string  Insured_Type = '';      
            string  Policy_number_from_Insurance_company = ''; 
            string  product_from_insurance_company = ''; 
            string  Production_Date = ''; 
            string  Status = ''; 
            string  vehicle_number = ''; 
            string  PolicyId = ''; 
            decimal  premium = 0;
            string  policyNumber ='';
            Boolean isAccountFound =false;
            Boolean IsBrokerFound = false;
            Boolean IsPolicyfound =false;
            Boolean IscarrierFound = false;
            string commentsCustomerAccount = '';
            string endorsment ='';
            string premiumView ='';
            string identificationType = '';
            string agency ='';
            
                        
            public WrappedPolicyTransaction(Policy_Transaction__c obj){
                
                if(obj.endorsement_number__c != null){
                	endorsment = obj.endorsement_number__c;
                }
                if(obj.Comments_Policy__c != null){
                	Comments_PolicyId = obj.Comments_Policy__c;
                }
                if(obj.customer_full_name__c != null){
                	fullName = obj.customer_full_name__c ;
                }
                if(obj.Premium_neto__c != null){
                	premium = obj.Premium_neto__c;
                }
                if(obj.Premium_neto__c != null){
                	premiumView = string.valueOf(obj.Premium_neto__c);
                }
                if(obj.Identification_Type__c != null){
                	identificationType = string.valueOf(obj.Identification_Type__c);
                }
                if(obj.Id != null){ 
                    id = obj.Id ;
                }
                if(obj.comments_customer_account__c != null){
                        commentsCustomerAccount = obj.comments_customer_account__c;
                }
                if(obj.Is_carrier_Found__c != null){
                	IscarrierFound = obj.Is_carrier_Found__c;   
                }
                if(obj.Address__c != null ){
                    Address = obj.Address__c;
                }
                if(obj.Agent_number_from_Insurance_comapny__c != null ){
                	Agent_number_from_Insurance_comapny = obj.Agent_number_from_Insurance_comapny__c;
                }
                if(obj.Carrier__c != null ){
                	CarrierId =obj.Carrier__c;
                }
                if(obj.Broker_Number__c != null ){
                	Carrier_BrokerId = obj.Broker_Number__c;
                }
                if(obj.Comments_Agent_number__c != null ){
                	Comments_Agent_number = obj.Comments_Agent_number__c;
                }
                if(obj.comments_for_Account__c != null ){
                	comments_for_Account = obj.comments_for_Account__c;
                }
                if(obj.Comments_Insurance_Company__c != null ){
                	Comments_Insurance_Company = obj.Comments_Insurance_Company__c;
                }                               
                if(obj.Customer_Account__c != null ){
                	Customer_AccountId =obj.Customer_Account__c;
                }
                if(obj.is_Account_Found__c != null){   
                	isAccountFound = obj.is_Account_Found__c;
                }
                if(obj.Is_Broker_Found__c != null){
                	IsBrokerFound = obj.Is_Broker_Found__c;
                }
                if(obj.Is_Policy_found__c != null){
                	IsPolicyfound = obj.Is_Policy_found__c;
                }
                
                if(obj.Insurance_Type__c != null ){
                	Insurance_Type = obj.Insurance_Type__c;
                }
                if(obj.Insured_number__c != null ){
                	Insured_number = obj.Insured_number__c;
                }
                if(obj.Insured_Type__c != null ){
                	Insured_Type = obj.Insured_Type__c;
                }               
                if(obj.Policy_number_from_Insurance_company__c != null ){
                	Policy_number_from_Insurance_company =obj.Policy_number_from_Insurance_company__c;
                }
                if(obj.product_from_insurance_company__c != null ){
                	product_from_insurance_company =obj.product_from_insurance_company__c;
                }
                if(obj.Production_Date__c != null ){
                	Production_Date = obj.Production_Date__c.month() +'-' + obj.Production_Date__c.year() ;//string.valueOf(obj.Production_Date__c);
                }
                if(obj.Status__c != null ){
                	Status =obj.Status__c;
                }
                if(obj.vehicle_number__c != null ){
                	vehicle_number = obj.vehicle_number__c;
                }
                if(obj.Policy__c != null ){
                	PolicyId = obj.Policy__c;
                	if (obj.Policy__r.Novidea_HPC__client__c != null)
                		PolicyAccountName = obj.Policy__r.Novidea_HPC__Client__r.Name;
                }
                if(obj.Policy__r != null && obj.Policy__r.Novidea_HPC__Policy_Number__c != null){
                	policyNumber = obj.Policy__r.Novidea_HPC__Policy_Number__c;
                }
                if(obj.Carrier__r != null && obj.Carrier__r.Name != null){
                	CarrierName = obj.Carrier__r.Name;
                }
                if(obj.Broker_Number__r != null){
                	if (obj.Broker_Number__r.Name != null)
						Carrier_BrokerName = obj.Broker_Number__r.Name;
					if (obj.Broker_Number__r.Novidea_HPC__Agency__r != null && obj.Broker_Number__r.Novidea_HPC__Agency__r.Name != null)
						agency = obj.Broker_Number__r.Novidea_HPC__Agency__r.Name;
                }
                if(obj.Customer_Account__r != null && obj.Customer_Account__r.Name != null ){
	            	AccountName = obj.Customer_Account__r.Name;
	            }
            }                       
      }  
      
      
 
      global class TransactioRow{           
           WrappedPolicyTransaction wrappedPT;
           string rowNumber;          
           public TransactioRow(WrappedPolicyTransaction wPolicyTransaction,string rowN  ){
                  wrappedPT = wPolicyTransaction;
                  rowNumber = rowN ; 
           }                              
      }
      
      global class CreatePoliciesResult{
      	public TransactioRow[] txRows;
      	public String jobId;
      	public String[] txIds;
      	public Integer JobItemsProcessed, TotalJobItems, NumberOfErrors;
      	public String ExtendedStatus;
      	public String Status;
      	public String transStatus; 
      	public CreatePoliciesResult(String jobId, String[] txIds){
      		this.jobId = jobId;
      		this.txIds = txIds;
      	}
      }
      
      @RemoteAction    
      global static TransactioRow deletePolicyTransaction(string rowNumber ,string transactionId){
         Database.delete(transactionId);          
         TransactioRow newRow = new TransactioRow(null, transactionId) ;
         return  newRow;
      }
      
      @RemoteAction    
      global static string[] deleteRowsPolicyTransactions(RowIdentifier[] txs){
        if (txs == null || txs.isEmpty()) return null;
     	Id[] txids = new list<Id>();
     	String[] rownums = new list<String>();
        for(RowIdentifier tx: txs) { txids.add(tx.sfid); rownums.add(tx.sfid);}
        if(txids.isEmpty())return null;
//        system.debug('txids: ' + txids); 
        if (txids.isEmpty())return null;
        Database.delete(txids);
        return rownums;
      }

      @RemoteAction    
      global static Boolean deletePolicyTransactions(string fileName){
         Set<id> nestedGroupId;
         Set<id> nestedGroupIdOuter;
         if (fileName != null){
         	
         	Set<Id> groupMembers = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser();              
            list<Policy_Transaction__c> listPolicyTransaction = [select id from Policy_Transaction__c where Name = : fileName and OwnerId  IN: groupMembers];
            if (listPolicyTransaction.size()>0){
                Database.delete(listPolicyTransaction);
                return true;
            }               
         }
         return false;
      }
      
      
      private static WSYigod.PolicyGenerationResult generatePolicy(Policy_Transaction__c pt,map<Id,Account> mapDetermineOwnerActs){
		    string heshbonOPolisaJson = Encodingutil.urlDecode(pt.Policy_Content__c, 'UTF-8')+'}';    
		    WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize( heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
		    
		    // Diana set policy owner only on insert 21/04/2015
	            Account acc;
	            if(pt.Customer_Account__c!=null)
	                acc = pt.Customer_Account__r;
	            Novidea_HPC__Product_Category__c category;
                if(pt.Product_Def__c!=null && pt.Product_Def__r.Novidea_HPC__Category__r!=null){
                    category =  pt.Product_Def__r.Novidea_HPC__Category__r;
                }    
			    Novidea_HPC__Policy__c pol = new Novidea_HPC__Policy__c(Managed_By_Production__c=true);
			    Boolean bOwnerSet = false;
				if(!ArrayUtils.isMapNullOrEmpty(mapDetermineOwnerActs) && mapDetermineOwnerActs.containsKey(acc.Id))
					bOwnerSet = WSYigod.setPolicyOwnerByTeamMemberRole(pol, mapDetermineOwnerActs.get(acc.Id), category);
				if(!bOwnerSet)
					bOwnerSet = WSYigod.setPolicyOwnerFromAccount(pol, acc);
				if(!bOwnerSet){
					WSYigod.setPolicyOwnerFromCategory(pol, category);
			 	}
		 	//endRegion

		    pol.Novidea_HPC__Policy_Source__c = 'From Carrier File';
		   
		    if (pt.Customer_Account__c != null){
//		    	system.debug('pt.Customer_Account__c != null. Updating Policy.Novidea_HPC__Client__c to: ' + pt.Customer_Account__c); //Diana 21/04/2015
		        pol.Novidea_HPC__Client__c =  pt.Customer_Account__c;
		        //bOwnerSet = WSYigod.setPolicyOwnerFromAccount(pol, pt.Customer_Account__r); //Diana 21/04/2015
		    }
		    else system.debug('did not update Policy.Novidea_HPC__Client__c'); 
		    
		    
		    if(pt.Client__c!=null) pol.Novidea_HPC__Insured_Person__c = pt.Client__c;
		        
		    if (pt.Carrier__c != null) pol.Novidea_HPC__Carrier__c =  pt.Carrier__c;  
		    
		    if (pt.Broker_Number__c != null) pol.Novidea_HPC__Broker_In_Carrier__c =  pt.Broker_Number__c;
		    
		    if (pt.Policy_number_from_Insurance_company__c != null)      
		         pol.Novidea_HPC__Policy_Number__c =  pt.Policy_number_from_Insurance_company__c;    
		    
		    if (pt.endorsement_number__c != null) pol.Novidea_HPC__Endorsement_Number__c = decimal.valueOf(pt.endorsement_number__c);  
		        
		    if(pt.Product_Def__c!=null){
		       pol.Novidea_HPC__Product_Definition__c = pt.Product_Def__c;
			   //if(!bOwnerSet) WSYigod.setPolicyOwnerFromCategory(pol, pt.Product_Def__r.Novidea_HPC__Category__r); //Diana 21/04/2015
		    }
		    /*else if(!bOwnerSet){
		    	WSYigod.setDefaultPolicyOwner(pol);
		    }*/
		   
		    if(pt.Carrier_Product__c!=null){
		    	pol.Novidea_HPC__Carrier_Product_Number__c = pt.Carrier_Product__c;
			} 

    		pol.Novidea_HPC__Vehicle_Model__c = pt.Vehicle_Model__c;
    		pol.Novidea_HPC__Vehicle_Manufacturer__c = pt.Vehicle_Manufacturer__c;

		    pol.Insured_Name__c = pt.Customer_Full_Name__c;
		                        
		    heshbonOPolisaObj.updatePolicyField(pol, true, null);                                       
		    
		    if (heshbonOPolisaObj.NetuneiGvia != null){
		        heshbonOPolisaObj.NetuneiGvia.updatePolicyField(pol);
		    }
		    pol.Name = getPolicyName(pol, pt);
		    return new WSYigod.PolicyGenerationResult(pol, heshbonOPolisaObj, pt);
      }


     @RemoteAction    
      global static TransactioRow createPolicyInDB(string rowNumber ,string transactionId){
            	
            list<Policy_Transaction__c> listPolicyTransaction = [SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c,
					 Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c, Agent_Discount_Written_In_Carrier__c,
                     Commission_Written_In_Carrier__c, customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,
                     is_Account_Found__c,Is_Broker_Found__c, Broker_Number__r.Novidea_HPC__Agency__r.Name, Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name,
                     Broker_Number__r.Name,Carrier__r.Name, vehicle_number__c, product_from_insurance_company__c,
                     file_name__c, comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c,
                     OwnerId, Name, Insured_number__c, Insured_Type__c,Policy__r.Novidea_HPC__Client__r.Name, Customer_Account__r.OwnerId,
                     Insurance_Type__c, Carrier_File_Code__c, Customer_Account__c, Comments_Policy__c, Client__c, Customer_Account__r.Owner.ProfileId, 
                     Comments_Insurance_Company__c, Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, 
                     Address__c,Policy_Content__c, Product_Def__r.Name, Carrier_Product__c, Is_Customer_Located_By_Head_To_Tail__c,
                     Vehicle_Manufacturer__c, Vehicle_Model__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,Product_Def__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c
            	FROM Policy_Transaction__c 
            	WHERE Id=:transactionId];
            	
//            system.debug(LoggingLevel.ERROR, 'listPolicyTransaction: ' + listPolicyTransaction);
            
			TransactioRow[] trs = createPoliciesInDB(listPolicyTransaction);
			
			return trs[0];
      } 



      @RemoteAction    
	  global static CreatePoliciesResult createPoliciesInDB(String[] txIds){
	  		if(txIds==null || txIds.isEmpty()) return null;
	    	BatchCreatePoliciesFromTxs bc = new BatchCreatePoliciesFromTxs(txIds);
	    	Id jobId = Database.executeBatch(bc, General__c.getInstance().Num_Job_Process_Tx_Policy_Create__c.intValue());
	    	return new CreatePoliciesResult(jobId, txIds);
	  } 

	 
	  public static list<TransactioRow> createPoliciesInDB(list<Policy_Transaction__c> listPolicyTransaction){
        	WSYigod.keepManagedByProductionOn = true;
        	
        	// Diana set policy owner only on insert 21/04/2015
			set<Id> setAccountIds = new set<Id>();
			for(Policy_Transaction__c pt : listPolicyTransaction){
				if(pt.Policy__c != null && pt.Policy__r.Novidea_HPC__Client__c!=null)
					setAccountIds.add(pt.Policy__r.Novidea_HPC__Client__c);
				if(pt.Customer_Account__r!=null)
					setAccountIds.add(pt.Customer_Account__c);
			}
			map<Id,Account> mapDetermineOwnerActs; 
			if(Schema.getGlobalDescribe().containsKey('AccountTeamMember') && !setAccountIds.isEmpty()){
				mapDetermineOwnerActs = new map<Id, Account>([SELECT (SELECT TeamMemberRole, UserId FROM AccountTeamMembers) FROM Account WHERE Id IN:setAccountIds]);
			}
        	//endRegion
            if(!listPolicyTransaction.isEmpty()){
				WSYigod.PolicyGenerationResultList pgrList = new WSYigod.PolicyGenerationResultList();
				for(Policy_Transaction__c pt: listPolicyTransaction){
					 pgrList.add(generatePolicy(pt,mapDetermineOwnerActs));
				}
			    System.Savepoint sp = Database.setSavepoint();
			    try{
			        //doing the policy insert through the list object in order to be able to update the newly created policy Ids
			        pgrList.dbInsertPolicies();
			        //raniz add 9/7/2012: in order to be able to update the trigger created income later in actual receiving
			        updateTriggerCreatedIncome(pgrList);
			        //raniz add 14/4/13: here there won't be more more than 1 product so only need to update car details on it instead of in policy
			        //TODO: unify with other product handling + handle the update to the lead. it succeeds only in the recieving of the production and not here
			        WSYigod.updatePolicyProduct(pgrList);
			    }
			    catch(Exception ex){
					Database.rollback(sp);
					throw ex;                    	
			    }          	
            }
            
            list<Policy_Transaction__c> newLstPolicyTransaction = PolicyTransactionHandler.reMatch(listPolicyTransaction);
            //TODO: for unknown reason need to get the data from the db after update. Need to check this
           //TODO: uncomment if there are problems -  newLstPolicyTransaction = database.query(query); //IMPORTATNT!!!
            TransactioRow[] txrows = new TransactioRow[]{};
            WrappedPolicyTransaction wpt;
            for(Policy_Transaction__c pt : newLstPolicyTransaction){
	            wpt = new WrappedPolicyTransaction(pt);
	            txrows.add(new TransactioRow(wpt, pt.Id));
            }
            return txrows;
	  	
	  }
      

      /*
      	raniz 9/7/2012:
      	this method is used to update an income just created by policy trigger so the actual receiving of 
      	the production will be able to correctly update all the relevant fields 
      */
      private static void updateTriggerCreatedIncome(WSYigod.PolicyGenerationResultList pgrList){
      	list<Novidea_HPC__Income__c> incomes = [SELECT Novidea_HPC__Endorsement_Number__c, Created_By_policy_Trigger__c, Novidea_HPC__Policy__c
      											FROM Novidea_HPC__Income__c
      											WHERE Novidea_HPC__Policy__c IN : pgrList.policies
      											AND Novidea_HPC__Endorsement_Number__c = 0
      											ORDER BY CreatedDate DESC
      											LIMIT 1];
      	if(incomes.isEmpty()) return;
      	for(Novidea_HPC__Income__c income: incomes){
//      		system.debug('Policy: ' + income.Novidea_HPC__Policy__c + ' pgrList.getTxData(income.Novidea_HPC__Policy__c): ' + pgrList.getTxData(income.Novidea_HPC__Policy__c));
	  		income.Novidea_HPC__Endorsement_Number__c = Decimal.valueOf(pgrList.getTxData(income.Novidea_HPC__Policy__c).pt.endorsement_number__c);
	  		income.Created_By_policy_Trigger__c = true;
      	}
  		Database.update(incomes);
      }
      
	  private static String getPolicyName(Novidea_HPC__Policy__c policy, Policy_Transaction__c pt){
	  	String retval = policy.Novidea_HPC__Policy_Number__c;
	  	retval = getNameInLimit(retval, ' - ' + pt.Carrier__r.Name, MAX_NAME_LENGTH);
	  	retval= getNameInLimit(retval, pt.Product_Def__r.Name!=null && pt.Product_Def__r.Name!=''?' - ' + pt.Product_Def__r.Name:'', MAX_NAME_LENGTH);
	  	return retval;
	  }
      
	private static String getNameInLimit(String prefix, String postfix, Integer limitSize) {
		if (prefix == null)
			prefix = '';
		if (postfix == null)
			postfix = '';
		if (prefix.length() + postfix.length() <= limitSize)
			return prefix + postfix;
		return prefix;
	}
      
      @RemoteAction    
      global static TransactioRow syncRowTransaction(string rowNumber ,string transactionId){
            
            String query = 
            'SELECT Policy__c, client_Number_From_Agent__c,endorsement_number__c,Agent_Discount_Written_In_Carrier__c,Commission_Written_In_Carrier__c,\n'+ 
                     'customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,is_Account_Found__c,Is_Broker_Found__c,\n'+
                     'Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c,Policy__r.Novidea_HPC__Client__c,\n' +
                     'Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name, Broker_Number__r.Name,Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name,\n'+
                     'vehicle_number__c, product_from_insurance_company__c, file_name__c, comments_for_Account__c, Status__c,\n'+ 
                     'Production_Date__c, Policy_number_from_Insurance_company__c, OwnerId, Name, Policy__r.Novidea_HPC__Client__r.Name,\n'+
                     'Insured_number__c, Insured_Type__c, Insurance_Type__c, Carrier_File_Code__c, Policy__r.Novidea_HPC__Policy_Number__c,\n'+ 
                     'Customer_Account__c, Comments_Policy__c, Comments_Insurance_Company__c, Comments_Agent_number__c,Product_Def__c,\n'+ 
                     'Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, Address__c, Is_Customer_Located_By_Head_To_Tail__c\n' +
            'FROM Policy_Transaction__c\n' +  
            'WHERE Id=\'' + transactionId + '\'\n  LIMIT 5000 ';
            
            
            system.debug(query);
//            system.debug('syncRowTransaction query: ' +query);
            list<Policy_Transaction__c> listPolicyTransaction = database.query(query);
//            system.debug('listPolicyTransaction: ' + listPolicyTransaction);
            list<Policy_Transaction__c> newLstPolicyTransaction = PolicyTransactionHandler.reMatch(listPolicyTransaction);
            //from unknown reson i need to get the data from the db  after i do update need to check this  
           
            newLstPolicyTransaction = database.query(query);
            WrappedPolicyTransaction wpt = new WrappedPolicyTransaction(newLstPolicyTransaction[0]);
//            system.debug('newLstPolicyTransaction: ' + newLstPolicyTransaction);
            TransactioRow newRow = new TransactioRow(wpt, transactionId) ;
            return  newRow;
      } 
      
      
      @RemoteAction    
      global static list<TransactioRow> updateRowTransactions(string rowArr){
      	return updateRowTransactions(rowArr,true);
      }
      
      
      public static list<TransactioRow> updateRowTransactions(string rowArr, boolean processNonMatchingAccounts){
         	WSYigod.keepManagedByProductionOn = true;
           
            list<RowIdentifier> deserializedRowIdentifier = (list<RowIdentifier>)JSON.deserialize(rowArr, list<RowIdentifier>.class);
//            system.debug('deserializedRowIdentifier: ' + deserializedRowIdentifier );
//            system.debug('rowArr: '+ rowArr );
            map<string,string> mapSFIdToRowNumber = new map<string,string>();
            string concatenateSFID = '';
            for (RowIdentifier row  : deserializedRowIdentifier){
                mapSFIdToRowNumber.put(row.sfid,row.rownum);
                if (concatenateSFID == ''){
                	concatenateSFID += '\''+ row.sfid + '\'' ;
                }
                else{
                	concatenateSFID += ',' + '\''+ row.sfid + '\'' ;
                }
            }
            //raniz change 14/7/13: dispatch syncronous or async according to number of records
            if(mapSFIdToRowNumber.size()>5){
            	dispatchUpdateRowTransactionsJob(mapSFIdToRowNumber.keyset());
            	return null;
            }
            String query = 
            	'SELECT Policy__c, Carrier__c, client_Number_From_Agent__c, Policy_number_from_Insurance_company__c, Broker_Number__c,\n'+
                '	Other_Commissions__c, premium__c, Premium_neto__c, endorsement_number__c, Agent_Discount_Written_In_Carrier__c, Commission_Written_In_Carrier__c,\n'+
                '	Premium_Currency__c, Identification_Type__c, customer_full_name__c, Product_Def__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,\n' +
                '	Errors_while_updating_Sobject__c,Status__c,Client__c, Policy_Content__c, Insured_number__c, Insured_Type__c, Credit_Fee__c, Fee__c,\n'+ 
                '	Customer_Account__c,Customer_Account__r.OwnerId, Customer_Account__r.Owner.ProfileId, Carrier_Product__c, File_Name__c, Vehicle_Manufacturer__c,\n'+
                '	Vehicle_Model__c, Production_Date__c, Endorsement_Expiration_Date__c,Endorsement_Effective_Date__c,Expiration_Date__c,Effective_Date__c, Birthdate__c,\n' +
                '	Policy__r.Novidea_HPC__Client__c,Product_Def__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c  \n' +
            	'FROM Policy_Transaction__c\n'+
				'WHERE Id IN (' + concatenateSFID + ')\n'+
				'ORDER BY Policy__c, endorsement_number__c\n'+
				'LIMIT 5000';

//            system.debug('updateRowTransactions query: ' + query );

            list<Policy_Transaction__c> listPolicyTransaction = database.query(query);
            
            list<Id> updatedPolicyTransaction =  WSYigod.processAndUpdateSobjFromPolicyTransaction(listPolicyTransaction, processNonMatchingAccounts);
            list<TransactioRow> listTransactioRow = new list<TransactioRow>();
            if(!updatedPolicyTransaction.isempty()){
                for(Id ptId : updatedPolicyTransaction) {
                    TransactioRow tr = new TransactioRow(null,ptId);
                    listTransactioRow.add(tr);
                }
            }
            
            if (!updatedPolicyTransaction.isempty()){
                database.delete(updatedPolicyTransaction);
            }
            
                
            return listTransactioRow;
      	
      }
      
      
      private static void dispatchUpdateRowTransactionsJob(set<String> txIds){
	    	BatchUpdatePoliciesFromTxs bc = new BatchUpdatePoliciesFromTxs(txIds);
	    	Id jobId = Database.executeBatch(bc,5);
      }
      
      @RemoteAction    
      global static list<TransactioRow> syncRowTransactions( string rowArr ){
           
            list<RowIdentifier> deserializedRowIdentifier = (list<RowIdentifier>)JSON.deserialize(rowArr, list<RowIdentifier>.class);
//            system.debug('deserializedRowIdentifier: ' + deserializedRowIdentifier );
//            system.debug('rowArr: '+ rowArr );
            map<string,string> mapSFIdToRowNumber = new map<string,string>();
            string concatenateSFID = '';
            for (RowIdentifier row  : deserializedRowIdentifier){
                mapSFIdToRowNumber.put(row.sfid,row.rownum);
                if ( concatenateSFID == '' ){
                        concatenateSFID +=  '\''+ row.sfid + '\'' ;
                }else
                {
                        concatenateSFID += ',' + '\''+ row.sfid + '\'' ;
                }
            }
            
            String query = 
            	'SELECT  Policy__c, client_Number_From_Agent__c,endorsement_number__c,Agent_Discount_Written_In_Carrier__c,Commission_Written_In_Carrier__c,\n'+
                     'customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,is_Account_Found__c,Is_Broker_Found__c,\n'+
                     'Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c,Policy__r.Novidea_HPC__Client__c,\n' +
                     'Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name,Broker_Number__r.Name,Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name,Policy__r.Novidea_HPC__Policy_Number__c,\n'+
                     'vehicle_number__c, product_from_insurance_company__c, file_name__c, comments_for_Account__c, Status__c,\n'+ 
                     'Production_Date__c, Policy_number_from_Insurance_company__c, OwnerId, Name, Policy__r.Novidea_HPC__Client__r.Name,\n'+ 
                     'Insured_number__c, Insured_Type__c, Insurance_Type__c, Carrier_File_Code__c,Product_Def__c,\n'+
                     'Customer_Account__c, Comments_Policy__c, Comments_Insurance_Company__c, Comments_Agent_number__c,\n'+ 
                     'Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, Address__c, Is_Customer_Located_By_Head_To_Tail__c\n' +
            	'FROM Policy_Transaction__c\n' +
            	'WHERE Id IN (' + concatenateSFID + ') LIMIT 5000 ' ;
            	 
            
            list<TransactioRow>  listTransactioRow = new list<TransactioRow>();
            list<Policy_Transaction__c> listPolicyTransaction = database.query(query);
//            system.debug('listPolicyTransaction: ' +listPolicyTransaction);
            list<Policy_Transaction__c> newLstPolicyTransaction = PolicyTransactionHandler.reMatch(listPolicyTransaction);
             //from unknown reson i need to get the data from the db  after i do update need to check this 
            newLstPolicyTransaction = database.query(query);
            for (Policy_Transaction__c polT : newLstPolicyTransaction ){
                WrappedPolicyTransaction wpt = new WrappedPolicyTransaction(polT);
                TransactioRow newRow = new TransactioRow(wpt,polT.Id) ;
                listTransactioRow.add(newRow);
            }         
            
            return  listTransactioRow;
      } 
      
      
      @RemoteAction    
      global static CreatePoliciesResult checkPolicyCreationJobStatus(CreatePoliciesResult cpr) {
	      	AsyncApexJob a = [SELECT Status, JobItemsProcessed, ExtendedStatus, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id=:cpr.jobId];
	      	if(!'Completed'.equalsIgnoreCase(a.status) && !'Aborted'.equalsIgnoreCase(a.status) && !'Failed'.equalsIgnoreCase(a.status)){
	      		cpr.txRows = null;
	      		cpr.ExtendedStatus = a.ExtendedStatus;
	      		cpr.JobItemsProcessed = a.JobItemsProcessed;
	      		cpr.NumberOfErrors = a.NumberOfErrors;
	      		cpr.TotalJobItems = a.TotalJobItems;
	      		cpr.Status = a.Status;
	      		cpr.transStatus = apexJobStatusTranslation.get(a.Status);
	      		return cpr;
	      	}
//	      	system.debug('cpr.txIds: \'' + string.join(cpr.txIds,'\',\'') + '\'');
	      	//happens only upon completion, abortion or failure
            list<Policy_Transaction__c> listPolicyTransaction = [SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c,
					 Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c, Agent_Discount_Written_In_Carrier__c,
                     Commission_Written_In_Carrier__c, customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,
                     is_Account_Found__c,Is_Broker_Found__c,Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name,
                     Broker_Number__r.Name, Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name, vehicle_number__c, product_from_insurance_company__c,Policy__r.Novidea_HPC__Policy_Number__c,
                     file_name__c, comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c,
                     OwnerId, Name, Insured_number__c, Insured_Type__c,Policy__r.Novidea_HPC__Client__r.Name, Customer_Account__r.OwnerId,
                     Insurance_Type__c, Carrier_File_Code__c, Customer_Account__c, Comments_Policy__c, Client__c, Customer_Account__r.Owner.ProfileId, 
                     Comments_Insurance_Company__c, Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, 
                     Address__c,Policy_Content__c, Product_Def__r.Name, Carrier_Product__c, Is_Customer_Located_By_Head_To_Tail__c,
                     Vehicle_Manufacturer__c, Vehicle_Model__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,Product_Def__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c
            	FROM Policy_Transaction__c 
            	WHERE Id IN :cpr.txIds
            	AND Policy__c!=null];
             	
         	list<TransactioRow>  listTransactioRow = new list<TransactioRow>();
            for (Policy_Transaction__c pt : listPolicyTransaction ){
                WrappedPolicyTransaction wpt = new WrappedPolicyTransaction(pt);
                TransactioRow newRow = new TransactioRow(wpt,pt.Id) ;
                listTransactioRow.add(newRow);
            }

      		cpr.ExtendedStatus = a.ExtendedStatus;
      		cpr.JobItemsProcessed = a.JobItemsProcessed;
      		cpr.NumberOfErrors = a.NumberOfErrors;
      		cpr.TotalJobItems = a.TotalJobItems;
			cpr.txRows = listTransactioRow;
	      	cpr.Status = a.Status;
	      	cpr.transStatus = apexJobStatusTranslation.get(a.Status);
	      	return cpr;
      }
      
      
      @RemoteAction    
      global static TransactioRow createContact(string rowNumber ,string transactionId) {
  	    Policy_Transaction__c pt = [SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c,
										 Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c, Agent_Discount_Written_In_Carrier__c,
						                 Commission_Written_In_Carrier__c, customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,
						                 is_Account_Found__c,Is_Broker_Found__c,Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name,
						                 Broker_Number__r.Name,Carrier__r.Name, vehicle_number__c, product_from_insurance_company__c,Policy__r.Novidea_HPC__Policy_Number__c,
						                 file_name__c, comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c,
						                 OwnerId, Name, Insured_number__c, Insured_Type__c,Policy__r.Novidea_HPC__Client__r.Name, Customer_Account__r.OwnerId,
						                 Insurance_Type__c, Carrier_File_Code__c, Customer_Account__c, Comments_Policy__c, Client__c, Customer_Account__r.Owner.ProfileId, 
						                 Comments_Insurance_Company__c, Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, 
						                 Address__c,Policy_Content__c, Product_Def__r.Name, Carrier_Product__c, Is_Customer_Located_By_Head_To_Tail__c,
						                 Vehicle_Manufacturer__c, Vehicle_Model__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,
						                 Policy__r.Novidea_HPC__Client__c,Product_Def__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c
						        	FROM Policy_Transaction__c 
						        	WHERE Id =: transactionId];
	    string heshbonOPolisaJson = Encodingutil.urlDecode(pt.Policy_Content__c, 'UTF-8')+'}';    
	    WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize(heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
		Contact con = new Contact();
		heshbonOPolisaObj.YeshutLakoach.updateNewContact(con);
//		system.debug(pt.Customer_Account__c);
		con.AccountId = pt.Policy__r.Novidea_HPC__Client__c;
		database.insert(con);			  
		list<Policy_Transaction__c> newLstPolicyTransaction = PolicyTransactionHandler.reMatch(new list<Policy_Transaction__c>{pt});
		pt = [SELECT Policy__c, client_Number_From_Agent__c,endorsement_number__c,Agent_Discount_Written_In_Carrier__c,Commission_Written_In_Carrier__c, 
                     customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,is_Account_Found__c,Is_Broker_Found__c,
                     Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c,Policy__r.Novidea_HPC__Client__c,
                     Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name, Broker_Number__r.Name, Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name,
                     vehicle_number__c, product_from_insurance_company__c, file_name__c, comments_for_Account__c, Status__c, 
                     Production_Date__c, Policy_number_from_Insurance_company__c, OwnerId, Name, Policy__r.Novidea_HPC__Client__r.Name,
                     Insured_number__c, Insured_Type__c, Insurance_Type__c, Carrier_File_Code__c, Policy__r.Novidea_HPC__Policy_Number__c, 
                     Customer_Account__c,Comments_Policy__c, Comments_Insurance_Company__c, Comments_Agent_number__c,Product_Def__c, 
                     Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, Address__c, Is_Customer_Located_By_Head_To_Tail__c
             FROM Policy_Transaction__c 
			 WHERE Id =: transactionId];
	  //  system.debug(pt.Customer_Account__r.Name + 'diana' + pt.Customer_Account__c);      
      //  WrappedPolicyTransaction wpt = new WrappedPolicyTransaction(newLstPolicyTransaction[0]);
       WrappedPolicyTransaction wpt = new WrappedPolicyTransaction(pt);
      //  system.debug(wpt.AccountName);
        TransactioRow newRow = new TransactioRow(wpt,newLstPolicyTransaction[0].Id);
     //   system.debug(newRow.wrappedPT.AccountName);
        return newRow;
      }      
      
      global class RowIdentifier{
         public string rownum ;
         public string sfid;
         public RowIdentifier(string sfid, string rownum){
         	this.sfid = sfid;
         	this.rownum = rownum;
         }
      } 
      
        
      global class searchResult{        
         public List<WrappedPolicyTransaction> listWrappedPolicyTransaction;
         public string premiumNeto;
         public string preNeto;
         public string records;
      } 
        
      @RemoteAction    
      global static searchResult doRemoteSearch(string client, string account, string carrier, string policyTransaction,
                                      string endD, string StartD, string selectedInsdType, string selectedTransStat, string profitCenterId){
/*            system.debug('contact: ' + client);
            system.debug('Account: ' + account);
            system.debug('carrier: ' + carrier );
            system.debug('policyTransaction: ' + policyTransaction);
            system.debug('StartD: ' + StartD );
            system.debug('endD: ' + endD );
            system.debug('selectedInsdType: ' + selectedInsdType);
            system.debug('selectedTransStat: ' + selectedTransStat);
            system.debug('profitCenterId: ' + profitCenterId);
*/            
            decimal premiumNeto = 0;
            
            
            list<Policy_Transaction__c> listPolicyTransaction = doSearch(client, account, carrier, policyTransaction,
                                       endD, StartD, selectedInsdType, selectedTransStat, profitCenterId);
                                       
            list<WrappedPolicyTransaction> listWrapedPolicyTrans = new list<WrappedPolicyTransaction>();
            for(Policy_Transaction__c  p : listPolicyTransaction){
                 WrappedPolicyTransaction wPolicyTrans = new WrappedPolicyTransaction(p);
                 listWrapedPolicyTrans.add(wPolicyTrans);
                 if (p.Premium_neto__c != null) {
                    premiumNeto += p.Premium_neto__c;
                 }
            }
            searchResult result = new searchResult();
            result.listWrappedPolicyTransaction = listWrapedPolicyTrans;
            result.records = string.valueOf(listPolicyTransaction.size());
            result.preNeto = string.valueOf(premiumNeto);
            return result;
         
         }
         
         private static String profitCentersOpts;
         public static String getProfitCentersOpts(){
         	if(profitCentersOpts==null){
         		populateProfitCenters();
         	}
         	return profitCentersOpts;
         }
         
         public static void populateProfitCenters(){
         	list<AggregateResult> ls = [SELECT Novidea_HPC__Profit_Center__r.Id theid, Novidea_HPC__Profit_Center__r.Name name
							         	FROM Novidea_HPC__Broker_Number__c
							         	WHERE Novidea_HPC__Profit_Center__r.Id!=null
							         	GROUP BY Novidea_HPC__Profit_Center__r.Id,  Novidea_HPC__Profit_Center__r.Name];
//							         	system.debug(ls);
			Jsongenerator gen = Json.createGenerator(false);
			gen.writeStartArray();
			gen.writeStartObject();
			gen.writeStringField('id', '');	
			gen.writeStringField('name', '--ללא--');	
			gen.writeEndObject();
			gen.writeStartObject();
			gen.writeStringField('id', 'null');	
			gen.writeStringField('name', 'לא מזוהה');	
			gen.writeEndObject();
			for(AggregateResult ar: ls){
				gen.writeStartObject();
				gen.writeStringField('id', (Id)ar.get('theid'));	
				gen.writeStringField('name', (String)ar.get('name'));	
				gen.writeEndObject();
			}
			gen.writeEndArray();
			profitCentersOpts=gen.getAsString();
         }
         
         public static Policy_Transaction__c createRealTx(){
         	Policy_Transaction__c pt = new Policy_Transaction__c();
            pt.file_name__c ='test';                                
            string s ='%7b%22action%22%3a%22Renew%22%2c%22additional%22%3a%220000%22%2c%22Bordero_Month%22%3a%222012-06-01%22%2c%22Calculation_Code%22%3a%2201%22%2c'+
            '%22controlDigit%22%3a%222%22%2c%22CurrencyCode%22%3a%22USD%22%2c%22Endorsment_No%22%3a%2200%22%2c%22endorsmentEffectiveDate%22%3a%222012-06-01%22%2c%22'+
            'endorsmentExpirationDate%22%3a%222013-05-31%22%2c%22Expiration_Date%22%3a%222013-05-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22'+
            'Indexing_Type%22%3a%2202%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22320000011512%22'+
            '%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000001250%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2c%22Commission%22'+
            '%3a%5b%7b%22commissionAmountAgentA%22%3a%220000595.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2201%22%2c%22discountAmount%22'+
            '%3a%220000000.00%22%2c%22discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000040000.00%22%2c%22netPremium%22'+
            '%3a%2200000003500.00%22%2c%22percentCommissionAgentA%22%3a%2217.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%22'+
            '0%22%2c%22signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%2c%7b%22commissionAmountAgentA%22'+
            '%3a%220000000.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2200%22%2c%22discountAmount%22%3a%220000000.00%22%2c%22'+
            'discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000000000.00%22%2c%22netPremium%22%3a%2200000000000.00%22'+
            '%2c%22percentCommissionAgentA%22%3a%2200.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%220%22%2c%22'+
            'signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%5d%2c%22DetailedPremiumAndFees%22'+
            '%3a%5b%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22'+
            '%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22'+
            '%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%22'+
            '06%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22'+
            '%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%2c%22'+
            'recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%22'+
            '30%22%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2201%22%2c%22PandCCoverages%22'+
            '%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2201%22%2c%22YOM_GVIYA_BECHODESH%22%3anull%7d%2c%22'+
            'PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3a%2200%22%2c%22policyYear%22%3a%2232%22%2c%22product%22%3a%22032%22%2c%22runningNumber%22%3a%22'+
            '01151%22%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22subProduct%22%3a%22032%22'+
            '%2c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22'+
            'TAARICH_HITZTARFUT_MUTZAR%22%3a%222012-06-01%22%2c%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22'+
            'YeshutLakoach%22%3a%7b%22clientNumberFromAgent%22%3a%22001216965%22%2c%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c%22fullAddress%22%3anull%2c%22'+
            'fullName%22%3a%22LTD+TRUSTEER%22%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3anull%2c%22MIKUD%22%3a%2267442%22%2c%22MIN%22%3a%22%22'+
            '%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22'+
            '%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3anull%2c%22MISPAR_YELADIM%22%3anull%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22'+
            '513851816%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22LTD%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22'+
            'SHEM_PRATI%22%3a%22TRUSTEER%22%2c%22SHEM_RECHOV%22%3a%22MOZES+NOACH+13%22%2c%22SHEM_YISHUV%22%3a%22AVIV+TEL%22%2c%22SpouseBirthDate%22%3anull%2c%22'+
            'SpouseFirstName%22%3anull%2c%22SpouseSSN%22%3anull%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%7d+';
             pt.Policy_Content__c = s; 
             pt.Carrier_File_Code__c = '333';
             pt.Name = String.format('{0}-{1}-{2}', new String[]{pt.file_name__c,pt.Carrier_File_Code__c,date.today().month()+''+date.today().year()});
             string heshbonOPolisaJson = Encodingutil.urlDecode(s, 'UTF-8')+'}';  
             WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize( heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
             pt.External_Id__c = String.Format('{0}-{1}-{2}-{3}-{4}-{5}', new String[]{HeshbonOPolisaObj.MISPAR_POLISA_O_HESHBON, HeshbonOPolisaObj.Endorsment_No, pt.Carrier_File_Code__c, HeshbonOPolisaObj.product, HeshbonOPolisaObj.subProduct, HeshbonOPolisaObj.additional});            
             list<Policy_Transaction__c> ls = [select id from Policy_Transaction__c where External_Id__c =: pt.External_Id__c];
             if(!ls.isEmpty()) delete ls[0];
         	 insert pt;
         	 new WrappedPolicyTransaction([SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c,
					 Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c, Agent_Discount_Written_In_Carrier__c,
                     Commission_Written_In_Carrier__c, customer_full_name__c,premium__c,Premium_neto__c,comments_customer_account__c,
                     is_Account_Found__c,Is_Broker_Found__c,Is_Policy_found__c,Is_carrier_Found__c, Customer_Account__r.Name,
                     Broker_Number__r.Name, Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name, vehicle_number__c, product_from_insurance_company__c,
                     file_name__c, comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c,
                     OwnerId, Name, Insured_number__c, Insured_Type__c,Policy__r.Novidea_HPC__Client__r.Name, Customer_Account__r.OwnerId,
                     Insurance_Type__c, Carrier_File_Code__c, Customer_Account__c, Comments_Policy__c, Client__c, Customer_Account__r.Owner.ProfileId, 
                     Comments_Insurance_Company__c, Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, 
                     Address__c,Policy_Content__c, Product_Def__r.Name, Carrier_Product__c, Is_Customer_Located_By_Head_To_Tail__c,
                     Vehicle_Manufacturer__c, Vehicle_Model__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c
            	FROM Policy_Transaction__c 
            	WHERE Id=:pt.Id]);
         	 return pt;
         }
         
        
         
         
}