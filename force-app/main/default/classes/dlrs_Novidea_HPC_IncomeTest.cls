/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Novidea_HPC_IncomeTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Novidea_HPC_IncomeTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Novidea_HPC__Income__c());
    }
}