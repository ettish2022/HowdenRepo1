global with sharing class BatchCreatePoliciesFromTxs implements Database.Batchable<Policy_Transaction__c>, Database.stateful{
    public Policy_Transaction__c[] txsToProcess;
    public String[] txIds;
    public BatchCreatePoliciesFromTxs (String[] txIds){
        this.txIds = txIds;
    }

	public static list<string> categoriesId = General__c.getInstance().Personal_Category__c==null?null:General__c.getInstance().Personal_Category__c.split(',');//diana
 	
    public BatchCreatePoliciesFromTxs (){}
       
    global Iterable<Policy_Transaction__c> start(Database.BatchableContext BC){
       //raniz 12/5/13 TODO: perhaps there should have been a rematch process first in case user did some matching actions but did not rematch
       system.debug('\'' + string.join(txIds,'\',\'') +'\'');
       system.debug(categoriesId);
       return [SELECT Policy__c, client_Number_From_Agent__c, endorsement_number__c, Agent_Discount_Written_In_Carrier__c,
                     Premium_Currency__c, Identification_Type__c, Effective_Date__c, Expiration_Date__c,Product_Def__c,Product_Def__r.Novidea_HPC__Category__c,//diana 29/07/13
                     Commission_Written_In_Carrier__c, customer_full_name__c, premium__c, Premium_neto__c, comments_customer_account__c,
                     is_Account_Found__c, Is_Broker_Found__c, Is_Policy_found__c, Is_carrier_Found__c, Customer_Account__r.Name,
                     Broker_Number__r.Name, Broker_Number__r.Novidea_HPC__Agency__r.Name, Carrier__r.Name, vehicle_number__c, product_from_insurance_company__c, Policy__r.Novidea_HPC__Carrier__c,
                     file_name__c, comments_for_Account__c, Status__c, Production_Date__c, Policy_number_from_Insurance_company__c, 
                     OwnerId, Name, Insured_number__c, Insured_Type__c,Policy__r.Novidea_HPC__Client__c, Policy__r.Novidea_HPC__Client__r.Name, 
                     Insurance_Type__c, Carrier_File_Code__c, Customer_Account__c, Comments_Policy__c, Client__c, Customer_Account__r.Owner.ProfileId, 
                     Comments_Insurance_Company__c, Comments_Agent_number__c, Carrier__c, Broker_Number__c, Agent_number_from_Insurance_comapny__c, 
                     Address__c,Policy_Content__c, Product_Def__r.Name, Carrier_Product__c, Is_Customer_Located_By_Head_To_Tail__c,
                     Vehicle_Manufacturer__c, Vehicle_Model__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,                      
                     Product_Def__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c, 
                     Customer_Account__r.OwnerId
                FROM Policy_Transaction__c
                WHERE Id IN : txIds
                AND Policy__c = null
                //rz change 28/7/13:
                //AND Vehicle_Number__c != null
                AND Is_Broker_Found__c = true
                AND Carrier__c != null
                AND Product_Def__c != null
                AND is_Account_Found__c = true 
                AND Endorsement_Number__c = '0'
                AND Status__c = 'not compatible'
                AND Product_Def__r.Novidea_HPC__Category__c IN: categoriesId //diana
                ORDER BY Vehicle_Number__c 
                //rz change 28/7/13:
                NULLS FIRST];
    }
    
    global void execute(Database.BatchableContext BC, list<Policy_Transaction__c> scope){
        executeLogic(scope, isLastBatch(BC.getJobId()));
    }

    global void finish(Database.BatchableContext BC){
        
    } 

    private void executeLogic(list<Policy_Transaction__c> scope, boolean isLastBatch){
        prepareScope(scope, isLastBatch);
        mergeTransactionCO.createPoliciesInDB(scope);
    }

	public void prepareScope(list<Policy_Transaction__c> scope, boolean isLastBatch){
        if(txsToProcess==null) txsToProcess = new Policy_Transaction__c[]{};
        txsToProcess.addAll(scope);
        scope.clear();
        scope.addAll(txsToProcess);
        //keeps last txs for next round and removes them from scope
        if(!isLastBatch) txsToProcess = getLastSameVehicleNumberTxs(scope);
	}

    /*
        extracts the last txs that belong to the same vehicle number in order to pass them to the next bacth
        for processing
    */
    public list<Policy_Transaction__c> getLastSameVehicleNumberTxs(list<Policy_Transaction__c> scope){
        list<Policy_Transaction__c> retlist = new list<Policy_Transaction__c>();
        Policy_Transaction__c pt;
        String vehicleNumber = scope[scope.size()-1].Vehicle_Number__c;
        for(Integer i=scope.size()-1;i>=0;--i){
            pt = scope[i];
            //rz change 28/7/13: vehicleNumber!=null && 
            if(vehicleNumber!=null && vehicleNumber.equalsIgnoreCase(pt.Vehicle_Number__c))
                retlist.add(scope.remove(i));
            else break;
        }
        return retlist;
    }
    
    public boolean isLastBatch(Id jobId){
        AsyncApexJob a = [SELECT JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id=:jobId];
        return a.TotalJobItems-a.JobItemsProcessed == 1; 
    }
    
    
    public static list<Policy_Transaction__c> createTxs(list<Novidea_HPC__Product_Def__c> prodefs, Account carrier){
        list<Policy_Transaction__c> txs = new list<Policy_Transaction__c>();
        Account acc = new Account(name='חשבון לקוח');
        insert acc;
        Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c(
                                                                            Novidea_HPC__Broker_Number_In_Carrier__c = '56561',
                                                                            Novidea_HPC__Carrier__c = carrier.Id
                                                                            );
        insert bn;
		
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        /*txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '1'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '2'
        ));*/
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        /*txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = null,
            Policy_Number_From_Insurance_Company__c = '555555555',
            Product_Def__c = prodefs[3].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));*/


        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));

        insert txs;
        return txs;
    }
    //diana 29/07/2013
    public static list<Policy_Transaction__c> createTxsWithDwelling(list<Novidea_HPC__Product_Def__c> prodefs, Account carrier){
        list<Policy_Transaction__c> txs = new list<Policy_Transaction__c>();
        Account acc = new Account(name='חשבון לקוח');
        insert acc;
        Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c(
                                                                            Novidea_HPC__Broker_Number_In_Carrier__c = '56561',
                                                                            Novidea_HPC__Carrier__c = carrier.Id
                                                                            );
        insert bn;
        
		
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = null,
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = null,
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = null,
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
         txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
         txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
         txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '1234546789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
         txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '1234546789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        insert txs;
        return txs;
    }
       
    
    
    public static list<Novidea_HPC__Product_Def__c> createProductDefs(){
        list<Novidea_HPC__Product_Def__c> prodefs = new list<Novidea_HPC__Product_Def__c>();
        
    	General__c general = [SELECT Personal_Category__c FROM General__c][0];
    	map<string, Novidea_HPC__Product_Category__c> cats = new map<string, Novidea_HPC__Product_Category__c>{
    														'car'=>new Novidea_HPC__Product_Category__c(name='car'),
    														'flat'=>new Novidea_HPC__Product_Category__c(name='flat'),
    														'stam'=>new Novidea_HPC__Product_Category__c(name='stam')
    														};
    	insert cats.Values();
    	general.Personal_Category__c='';
    	for(Novidea_HPC__Product_Category__c cat: cats.values()){
    		general.Personal_Category__c+=cat.Id +',';
    	}
    	general.Personal_Category__c = general.Personal_Category__c.substring(0,general.Personal_Category__c.length()-1);
    	update general;
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='מקיף',Novidea_HPC__Category__c = cats.get('car').Id)); //diana added categoty
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='חובה',Novidea_HPC__Category__c = cats.get('car').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='ריידר',Novidea_HPC__Category__c = cats.get('car').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='סתם לא קשור לרכב',Novidea_HPC__Category__c = cats.get('stam').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='דירה',Novidea_HPC__Category__c = cats.get('flat').Id));
        
        insert prodefs;
        return prodefs;
    }
    
    public static Account createCarrier(){
        Id RecordTypeId = [select Id from recordType where sobjecttype='account' and developername = 'carrier' and isActive = true][0].id;
        Account a  = new Account(RecordTypeId=RecordTypeId, name= 'carrier');
        insert a;
        return a;
    }
  
}