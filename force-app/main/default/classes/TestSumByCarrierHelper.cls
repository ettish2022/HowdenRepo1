@isTest
public class TestSumByCarrierHelper {

    /*
        Test for type 'Income'
    */
     /*@isTest(SeeAllData=true)
    static void test0001() {
        Test.startTest();
        try{
            final String ACTIVE = 'Active';
            final String NUM_ID = '0411';
            Account accCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID , true);
            Account incomeCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID + 1, true);
            Account accClient =  TestUtils.createAccount('client:' + NUM_ID, true);
            Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('cat:' + NUM_ID, '', true);
            Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('proddef:' + NUM_ID, cat.Id, true);
            Novidea_HPC__Policy__c policy = TestUtils.createPolicy('policy:' + NUM_ID, accCarrier.Id, accClient.Id, prodDef.Id, ACTIVE, true);
            
            list<Novidea_HPC__Income__c> pList = new Novidea_HPC__Income__c[] {
                                                     TestUtils.createIncome(policy.Id, 0, null, null, false)
                                                    //,TestUtils.createIncome(policy.Id, 1, null, null, false)
                                                    //,TestUtils.createIncome(policy.Id, 2, null, null, false)
                                                 };
            for( Integer t = 0; t<pList.size(); t++ ) {
                Novidea_HPC__Income__c ic = pList[t];
                if(t == 0)
                    ic.Novidea_HPC__Carrier__c = incomeCarrier.Id;
                else
                    ic.Novidea_HPC__Carrier__c = null;
            }
            Database.insert(pList);
            Test.stopTest();
            String sql = 'SELECT count() FROM Sums_By_Carrier__c WHERE Policy__c = \'{0}\' AND Carrier__c = \'{1}\'';
            String sql2 = sql.replace('{0}', policy.Id).replace('{1}', incomeCarrier.Id);
            system.debug('\n\n\n SQL 2 = ' + sql2 + '\n\n\n');
            system.assertEquals(1, Database.countQuery(sql2));
        }
        catch(exception ex){}
        
    }*/
    /*
     * Test for type 'Collection From Carrier'
    */
    @isTest(SeeAllData=true)
    static void test0002() {
        Test.startTest();
        final String ACTIVE = 'Active';
        final String NUM_ID = '0511';
        Account accCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID , true);
        Account incomeCarrier = TestUtils.createCarrierAccount('carrier:' + NUM_ID + 1, true);
        Account accClient =  TestUtils.createAccount('client:' + NUM_ID, true);
        Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('cat:' + NUM_ID, '', true);
        Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('proddef:' + NUM_ID, cat.Id, true);
        Novidea_HPC__Policy__c policy = TestUtils.createPolicy('policy:' + NUM_ID, accCarrier.Id, accClient.Id, prodDef.Id, ACTIVE, true);
        
        String sql = 'SELECT count() FROM Sums_By_Carrier__c WHERE Policy__c = \'{0}\' AND Carrier__c = \'{1}\'';
        String sql2 = sql.replace('{0}', policy.Id).replace('{1}', incomeCarrier.Id);
        system.assertEquals(0, Database.countQuery(sql2));
        
        list<Novidea_HPC__Collection_From_Carrier__c> pList = new Novidea_HPC__Collection_From_Carrier__c[] {
                                                 TestUtils.createCollectionFromCarrier('Collection:001', policy.Id, incomeCarrier.Id , false)
                                                ,TestUtils.createCollectionFromCarrier('Collection:002', policy.Id, incomeCarrier.Id , false)
                                                ,TestUtils.createCollectionFromCarrier('Collection:003', policy.Id, incomeCarrier.Id , false)
                                             };
        for( Integer t = 0; t<pList.size(); t++ ) {
            Novidea_HPC__Collection_From_Carrier__c cc = pList[t];
            if(t == 0)
                cc.Novidea_HPC__Carrier__c = null;
            else
                cc.Novidea_HPC__Carrier__c = incomeCarrier.Id;
        }
        Database.insert(pList);
        Test.stopTest();
        sql = 'SELECT count() FROM Sums_By_Carrier__c WHERE Policy__c = \'{0}\' AND Carrier__c = \'{1}\'';
        sql2 = sql.replace('{0}', policy.Id).replace('{1}', incomeCarrier.Id);
        system.assertEquals(1, Database.countQuery(sql2));
    }
}