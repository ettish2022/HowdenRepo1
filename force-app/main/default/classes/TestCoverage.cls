@isTest
private class TestCoverage {
   private static testmethod void testInvolvedInClaim(){
   	Novidea_HPC__Claim__c claim = new Novidea_HPC__Claim__c();
   	Database.insert(claim);
   	Novidea_HPC__Involved_In_Claim__c inc = new Novidea_HPC__Involved_In_Claim__c(Novidea_HPC__Claim__c=claim.Id);
   	Database.insert(inc); 
   }
}