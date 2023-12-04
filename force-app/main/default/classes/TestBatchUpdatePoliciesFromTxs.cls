@isTest
public class TestBatchUpdatePoliciesFromTxs {

        
    	//raniz 11/09/13 - this is not a real meaningful test. Still need to creteae relevant policies to merege with transactions
    @isTest(SeeAllData=true)
    static void myUnitTest(){
   	     list<Novidea_HPC__Product_Def__c> prodefs = BatchUpdatePoliciesFromTxs.createProductDefs();
        Account carrier = BatchUpdatePoliciesFromTxs.createCarrier();
        Policy_Transaction__c[] txs = BatchUpdatePoliciesFromTxs.createTxs(prodefs, carrier);
        set<String> txIds = new set<String>();
        for(Policy_Transaction__c tx: txs){
        	txIds.add(tx.Id);
        }
        BatchUpdatePoliciesFromTxs bp = new BatchUpdatePoliciesFromTxs(txIds); 
        bp.executeLogic(new Policy_Transaction__c[]{txs[0],txs[1],txs[2],txs[3]});
        database.executeBatch(bp);
        system.assertEquals(11,txs.size());
    }
}