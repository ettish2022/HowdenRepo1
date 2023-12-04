@isTest
public class TestMergeTransactionCO {
	@istest(seealldata=true)
    static void myUnitTest(){
		mergeTransactionCO.doRemoteSearch('a0Nf00000006DNR', 'a0Nf00000006DNR', 'a0Nf00000006DNR', 'a0Nf00000006DNR', Date.Today().format(), Date.Today().format(), '', '', 'a0Nf00000006DNR' );
		mergeTransactionCO.createPoliciesInDB(new String[]{mergeTransactionCO.createRealTx().Id});
        //mergeTransactionCO.createPoliciesInDB(new Policy_Transaction__c[]{mergeTransactionCO.createRealTx()});
        //mergeTransactionCO.syncRowTransaction('1', mergeTransactionCO.createRealTx().Id);
        mergeTransactionCO.getProfitCentersOpts();
        mergeTransactionCO.populateProfitCenters();
        mergeTransactionCO.deletePolicyTransactions(null);
    }
}