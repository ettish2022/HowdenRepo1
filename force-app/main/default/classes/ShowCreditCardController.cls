public with sharing class ShowCreditCardController {

	public static Id currentUserId;
	public static Id currentProfileId;
	
    public string creditCard{get;set;}
    public string CreditCardsType {get;set;}
    public string CreditExpirationDate {get;set;}
    public string NumberOfPayments {get;set;}
    public string CreditCardOwnerName {get;set;}
    public string CreditCardOwnerSSN {get;set;}
    public boolean noCreditCard {get;set;}
    
    Novidea_HPC__Lead__c lead ;
    Novidea_HPC__Policy__c policy ;
    
	public ShowCreditCardController(ApexPages.StandardController controller ){
         
         if (controller != null){
            if (controller.getRecord() instanceof Novidea_HPC__Lead__c)  
    			lead = (Novidea_HPC__Lead__c)controller.getRecord();
    		else if(controller.getRecord() instanceof Novidea_HPC__Policy__c)
    			policy = (Novidea_HPC__Policy__c)controller.getRecord();    	    		
         }
    }
     
    public void init(){
		try{ 
			Id leadPolicy ; 
			Id leadId;
			if(policy != null){
				 list<Novidea_HPC__Policy__c> policyLeadId = [select Novidea_HPC__Lead__c from Novidea_HPC__Policy__c where Id =:policy.Id]	;
				 	 								
				 if (policyLeadId.size()>0)	 																
				 	leadPolicy = policyLeadId.get(0).Novidea_HPC__Lead__c;
				 //system.debug(leadPolicy);
			}
			else if(lead != null)	
				leadId = lead.Id; 
			
			list<Id> PermitedUserId = new list<Id>();
			currentUserId = Userinfo.getUserId();
			currentProfileId = Userinfo.getProfileId();
			list<User> PermitedUser = [select Id,Show_Credit_Card_Number__c,ProfileId from User where Show_Credit_Card_Number__c =true
					 and (Id =:currentUserId or ProfileId =:currentProfileId)];
			for(User user : PermitedUser){
				PermitedUserId.add(user.Id);
			}
			system.debug(PermitedUser);
			
			String queryText = 'select Credit_Card_Owner_Name__c,Credit_Card_Owner_SSN__c,Credit_Card_Code__c,Credit_Cards_Type__c,Month__c,Year__c,Payments__c,OwnerId from Novidea_HPC__Lead__c ' + 
			 	'where (id =: leadId or id=:leadPolicy)';
			if (PermitedUserId.size() != 0)
			 	queryText += ' AND OwnerId In (\'' +  String.join (PermitedUserId, '\',\'')  + '\')' ;
			system.debug(queryText);   
			list<Novidea_HPC__Lead__c> creditCardList = Database.query(queryText);
														
	    	if(creditCardList.get(0).Credit_Card_Code__c != null){
	    		noCreditCard = false;
	    		creditCard = creditCardList.get(0).Credit_Card_Code__c;
	    		// Added for Howden, too many formulas for policy obj 
	    		CreditCardsType = creditCardList.get(0).Credit_Cards_Type__c;
	    		if(creditCardList.get(0).Year__c != null) 
	    			CreditExpirationDate = creditCardList.get(0).Year__c.right(2) +' / '+ creditCardList.get(0).Month__c;
	    		NumberOfPayments = creditCardList.get(0).Payments__c;
	    		CreditCardOwnerName = creditCardList.get(0).Credit_Card_Owner_Name__c; 
	    		CreditCardOwnerSSN = creditCardList.get(0).Credit_Card_Owner_SSN__c;
	    	}	
	    	//else{
	    		
	    	//}
	    	
	    }catch(Exception e){
			creditCard =  ' אין מספיק הרשאות צפייה בפרטי אשראי או שפרטי האשראי אינם קיימים בפוטנציאל';//'No Permission for credit Card Details or Lead Credit Card not Exist'; 
	    	noCreditCard = true;
		}                 
    }
}