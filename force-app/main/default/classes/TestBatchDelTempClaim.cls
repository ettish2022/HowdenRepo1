@isTest
public class TestBatchDelTempClaim {
	static testMethod void testBatch() 
     {  
        
        Novidea_HPC__Claim__c claim = new  Novidea_HPC__Claim__c(Is_Temp__c = true);
        insert claim;   
        test.startTest();       
        BatchDelTempClaim testBatch = new BatchDelTempClaim();
        ID batchprocessid = Database.executeBatch( testBatch,200);          
        Test.stopTest(); 
    }       
            
    
       
}