@isTest
public class TestBatchCreatePoliciesFromTxs {
	@isTest(SeeAllData=true)
    static void testLastSameVehicleNumberTxs(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxs(prodefs, carrier);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs(); 
        list<Policy_Transaction__c> txsToProcess = bp.getLastSameVehicleNumberTxs(txs);
        system.assertEquals(5,txsToProcess.size());
    }
    
    @isTest(SeeAllData=true)
    static void testPrepareScope1stBatch(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxs(prodefs, carrier);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs (); 
        list<Policy_Transaction__c> testlist = new list<Policy_Transaction__c>{new Policy_Transaction__c()};
        bp.prepareScope(testlist, true);
        system.assertEquals(1, testlist.size());
    }

    @isTest(SeeAllData=true)
    static void testPrepareScope(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxs(prodefs, carrier);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs (); 
        list<Policy_Transaction__c> txsToProcess = bp.getLastSameVehicleNumberTxs(txs);
        bp.txsToProcess = txsToProcess;
        list<Policy_Transaction__c> testlist = new list<Policy_Transaction__c>();
        bp.prepareScope(testlist, true);
        system.assertEquals(5, testlist.size());
    }
     
      //diana added 29/07/2013
    @isTest(SeeAllData=true)
    static void testAllProductsDwelling(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxsWithDwelling(prodefs, carrier);
        for (integer i= txs.size()-1 ; i>=3 ;i--)
        	txs.remove(i);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs(); 
        list<Policy_Transaction__c> txsToProcess = bp.getLastSameVehicleNumberTxs(txs);
        system.assertEquals(0,txsToProcess.size()); 
    }
     @isTest(SeeAllData=true)
    static void testProductsDwellingAndVehicles(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxsWithDwelling(prodefs, carrier);
        for (integer i= txs.size()-1 ; i>=6 ;i--)
    		txs.remove(i);
    	system.debug(txs);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs(); 
        list<Policy_Transaction__c> txsToProcess = bp.getLastSameVehicleNumberTxs(txs);
        system.assertEquals(3,txsToProcess.size()); 
    }
    @isTest(SeeAllData=true)
    static void testallProductsDwellingAndVariosVehicles(){
        list<Novidea_HPC__Product_Def__c> prodefs = BatchCreatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchCreatePoliciesFromTxs.createCarrier();
        list<Policy_Transaction__c> txs = BatchCreatePoliciesFromTxs.createTxsWithDwelling(prodefs, carrier);
        BatchCreatePoliciesFromTxs bp = new BatchCreatePoliciesFromTxs(); 
        list<Policy_Transaction__c> txsToProcess = bp.getLastSameVehicleNumberTxs(txs);
        system.assertEquals(2,txsToProcess.size()); 
    }//end
  
}