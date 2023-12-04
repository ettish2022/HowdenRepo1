/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Novidea_HPC_PolicyTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Novidea_HPC_PolicyTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Novidea_HPC__Policy__c());
    }
}