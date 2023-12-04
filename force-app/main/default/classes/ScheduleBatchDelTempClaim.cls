@ISTEST 
global class ScheduleBatchDelTempClaim implements Schedulable
{ 
     global void execute(SchedulableContext ctx)
     {
        ID batchprocessid = Database.executeBatch(new BatchDelTempClaim(),100);
     }
     
     static testMethod void testCall() 
    {
        string d1='0 0 0 3 9 ?';
        Test.startTest();      
        String jobId = System.schedule('testBasicScheduledApex',
        d1, 
        new ScheduleBatchDelTempClaim());        
        Test.stopTest();

    }
}