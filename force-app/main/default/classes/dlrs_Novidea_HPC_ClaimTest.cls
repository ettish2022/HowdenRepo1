/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Novidea_HPC_ClaimTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Novidea_HPC_ClaimTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Novidea_HPC__Claim__c());
    }
}