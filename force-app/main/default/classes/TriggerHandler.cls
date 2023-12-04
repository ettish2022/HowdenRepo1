public  class TriggerHandler {
    
    
    //this function will run after insert of presale budget
    //if the first approval field in not null, submit the Approval process 
    
    public static void  submitForApproval(List<Novidea_HPC__Claim__c> listClaims)
    {
        
         for (Novidea_HPC__Claim__c claim :listClaims ) 
         {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                 req1.setComments('Submitting request for approval.');
                 req1.setObjectId(claim.Id);      
                 // Submit the approval request for the claim             
                 Approval.ProcessResult result = Approval.process(req1);
             
         }
    }
    
    
    

}