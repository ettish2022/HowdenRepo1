public class TestUtils {
	
	public class ApplicationException extends Exception  { }
	
	public static void performException(Exception exp) {
		system.debug(exceptionDump(exp));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, exp.getMessage()));
	}
	
	public static string exceptionDump(Exception exp) {
	   return 'stack : ' + exp.getStackTraceString() + '\n message :' + exp.getMessage() +'\n type :' + exp.getTypeName();
	}
	
	public static string addCLR(string str) {
		return '\n\n\n' + str + '\n\n\n';
	}
	
	private static sObject insertObj(sObject obj, Boolean isInsert) {
		if(isInsert) 
			Database.insert(obj);
			
		return 	obj;	
	}
	
	public static Account createAccount(String name, Boolean isInsert) {
		Account obj = new 	Account (
			Name = name
		);
		
		return (Account)insertObj(obj,isInsert);	
	} 
	
	public static Account createCarrierAccount(String name, Boolean isInsert) {
		
		RecordType recordType = [SELECT sObjectType, Id, DeveloperName,Name 
    	                           FROM RecordType 
                				  WHERE sObjectType = 'Account' 
                				    AND DeveloperName = 'Carrier' and IsActive = true];
            				    
        Account obj = new Account (Name = name, RecordTypeId = recordType.Id);
        return (Account)insertObj(obj,isInsert);
		
	}
	
	public static Novidea_HPC__Product_Def__c createProductDef(String name, Id categoryId, Boolean isInsert) {
		Novidea_HPC__Product_Def__c obj = new Novidea_HPC__Product_Def__c( 
												Name = name, 	
												Novidea_HPC__Category__c = categoryId
										   );
										   
		return (Novidea_HPC__Product_Def__c)insertObj(obj,isInsert);											   											 
	}
	
	public static Novidea_HPC__Product_Def__c createProductDef(String name, Boolean standardProdDef, Id catId, Boolean isInsert) {
		
		RecordType recordType = [SELECT sObjectType, Id, DeveloperName,Name 
    	                           FROM RecordType 
                				  WHERE sObjectType = 'Novidea_HPC__Product_Def__c' 
                				    AND DeveloperName = 'Product'];
		
		Novidea_HPC__Product_Def__c obj = new Novidea_HPC__Product_Def__c(
											 RecordTypeId = recordType.Id
											,Name = name
											,Standard_Product_Definition__c = standardProdDef
											,Novidea_HPC__Category__c = catId
										  );
		
		return (Novidea_HPC__Product_Def__c)insertObj(obj,isInsert);
	}
	
	public static Novidea_HPC__Product_Category__c createCategory(String name, String pType, Boolean isInsert) {
		Novidea_HPC__Product_Category__c obj = new Novidea_HPC__Product_Category__c(
							 						 Name = name 
											 		,Type__c = pType 
											   );
				   
		return (Novidea_HPC__Product_Category__c)insertObj(obj,isInsert);		
	}
	public static Novidea_HPC__Policy__c createPolicy(String name, Id carrierId, Id clientId, Id prodDefId, String action, Boolean isInsert) {
		Novidea_HPC__Policy__c obj = new Novidea_HPC__Policy__c(
											 Name 								= name
											,Novidea_HPC__Carrier__c 			= carrierId //AccountId
											,Novidea_HPC__Client__c 			= clientId   //AccountId
											,Novidea_HPC__Product_Definition__c =  prodDefId
											,Novidea_HPC__Action__c 			= action 
									   );
									   
		return (Novidea_HPC__Policy__c)insertObj(obj,isInsert);		
	}
	
	public static Novidea_HPC__Income__c createIncome(Id policyId, Decimal endorsementNumber, Date effectiveDate, Date expirationDate, Boolean isInsert) {
		
		Novidea_HPC__Income__c obj =	new Novidea_HPC__Income__c(
											 Novidea_HPC__Policy__c = policyId
											,Novidea_HPC__Endorsement_Number__c = endorsementNumber
											,Novidea_HPC__Effective_Date__c = effectiveDate  
											,Novidea_HPC__Expiration_Date__c = expirationDate  
										); 	
		
						
		return (Novidea_HPC__Income__c)insertObj(obj,isInsert);		
	}
	
	public static Novidea_HPC__Policy_Breakdown__c createBreakdown(Id policyId, String name, Id carrierId,  Decimal procent, Boolean isInsert) {
		Novidea_HPC__Policy_Breakdown__c obj = new Novidea_HPC__Policy_Breakdown__c(
													 Name = name
													,Novidea_HPC__Policy__c = policyId
													,Novidea_HPC__Carrier__c = carrierId
													,Novidea_HPC__Premium_Breakdown__c = procent
											   );
													 
		return (Novidea_HPC__Policy_Breakdown__c)insertObj(obj,isInsert);														 
		
	}
	
	public static Novidea_HPC__Application__c createApplication(String name, String requiredPolicyType, Id clientId ,Boolean isInsert) {
		Novidea_HPC__Application__c obj = new Novidea_HPC__Application__c(
												 Name = name
												,Novidea_HPC__Required_Policy_Type__c = requiredPolicyType
												,Novidea_HPC__Account__c = clientId
										  ); 
		
		return (Novidea_HPC__Application__c)insertObj(obj,isInsert);
	}
	
	public static Novidea_HPC__Collection_From_Carrier__c createCollectionFromCarrier(String name, Id policyId, Id carrierId, Boolean isInsert) {
		Novidea_HPC__Collection_From_Carrier__c obj = new Novidea_HPC__Collection_From_Carrier__c(
															Name = name
															,Novidea_HPC__Policy__c = policyId
															,Novidea_HPC__Carrier__c = carrierId
															
													  ); 
													  
		return (Novidea_HPC__Collection_From_Carrier__c)insertObj(obj,isInsert);
	}
	
	public static Novidea_HPC__Lead__c createCustomLead(ID insCrossSaleId, String leadName, Boolean isInsert) {
		
		Novidea_HPC__Lead__c obj = new Novidea_HPC__Lead__c(
						        			 Name = leadName 
						        			,Insurance_Cross_Sale__c = insCrossSaleId 
											,Novidea_HPC__Contact_Email__c	 = 'test@google.com'              
											,Novidea_HPC__Status__c 		 = 'In Process'
											,Novidea_HPC__Contact_Name__c 	 = 'Test Tester' 
						        	); 
		
		return (Novidea_HPC__Lead__c)insertObj(obj,isInsert);
	}
	
	public static Novidea_HPC__Product__c createProduct(String prodName, ID prodDefId, ID leadId, Boolean isInsert) {
		Novidea_HPC__Product__c obj = new Novidea_HPC__Product__c(Name = prodName
														        	,Novidea_HPC__Product_Definition__c = prodDefId
																	,Novidea_HPC__Lead__c 		 				= leadId
														        	,Novidea_HPC__Required_Policy_Type__c 	 	= 'New'
																	,Novidea_HPC__Status__c = 'Active');
		return (Novidea_HPC__Product__c)insertObj(obj,isInsert);														
	}
}