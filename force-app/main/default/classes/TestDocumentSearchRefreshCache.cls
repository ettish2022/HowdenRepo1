@isTest
private class TestDocumentSearchRefreshCache {
    //As there's currently nothing to test at DocumentSearchRefreshCache, coverage test is the only thing required.
    @isTest(seeAllData=true)
    static void testCoverage() {
        String CRON_EXP = '0 0 7-18 ? * SUN-THU';//Every hour on a week day between 7am and 6pm.
        Test.startTest();
        //Schedule the test job
        String jobId = System.schedule('TestRefreshDocumentCache', CRON_EXP, new DocumentSearchRefreshCache());
        //Forces running of test's async calls.
        Test.stopTest();
    }
}