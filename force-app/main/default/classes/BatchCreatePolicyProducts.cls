global with sharing  class BatchCreatePolicyProducts implements Database.Batchable<Novidea_HPC__policy__c>, database.stateful{
	private list<Id> policyIds;
	private Id proType;
	public BatchCreatePolicyProducts(){}
	public BatchCreatePolicyProducts(list<Id> policyIds, Id proType){
		this.policyIds = policyIds;
		this.proType = proType;
	}
	
	global Iterable<Novidea_HPC__policy__c> start(Database.BatchableContext bc){
		if(policyIds!=null)
			return [SELECT Novidea_HPC__Product_Definition__c, Novidea_HPC__Effective_Date__c,
						Novidea_HPC__Expiration_Date__c ,Novidea_HPC__Product_Def_Name__c,
						 Novidea_HPC__Renewal_Date__c ,Novidea_HPC__Vehicle_Production_Year__c,
						 Novidea_HPC__Vehicle_Manufacturer__c,
						 Novidea_HPC__Vehicle_Model__c, Novidea_HPC__Car_Number__c,
						 Novidea_HPC__Premium_Amount_Currency__c,
						 Novidea_HPC__Premium_Amount__c,Novidea_HPC__Net_Premiumium__c,
						 Novidea_HPC__Carrier__c,
						(SELECT id FROM Novidea_HPC__products__r)
				FROM Novidea_HPC__Policy__c
				WHERE Id IN: policyIds];
			
		else return [SELECT Novidea_HPC__Product_Definition__c, Novidea_HPC__Effective_Date__c,
						Novidea_HPC__Expiration_Date__c ,Novidea_HPC__Product_Def_Name__c,
						 Novidea_HPC__Renewal_Date__c ,Novidea_HPC__Vehicle_Production_Year__c,
						 Novidea_HPC__Vehicle_Manufacturer__c,
						 Novidea_HPC__Vehicle_Model__c, Novidea_HPC__Car_Number__c,
						 Novidea_HPC__Premium_Amount_Currency__c,
						 Novidea_HPC__Premium_Amount__c,Novidea_HPC__Net_Premiumium__c,
						 Novidea_HPC__Carrier__c,
						(SELECT id FROM Novidea_HPC__products__r)
				FROM Novidea_HPC__Policy__c];
	}
	
	global void execute(Database.BatchableContext info, List<Novidea_HPC__policy__c> scope){
		string model;
		string msg = '';
					
					 
		list<Novidea_HPC__product__c> ls = new list<Novidea_HPC__product__c> ();
		for(novidea_hpc__policy__c pol: scope){
			
			if(!pol.Novidea_HPC__products__r.isEmpty())continue;
			
			ls.add(new Novidea_HPC__product__c(
				Name										= pol.Novidea_HPC__Product_Def_Name__c,
				Novidea_HPC__Policy__c 						= pol.Id,
				Novidea_HPC__Product_Definition__c 			= pol.Novidea_HPC__Product_Definition__c,
				Novidea_HPC__Effective_Date__c 				= pol.Novidea_HPC__Effective_Date__c ,
				Novidea_HPC__Expiration_Date__c 			= pol.Novidea_HPC__Expiration_Date__c ,
				Novidea_HPC__Expected_Renewal_Date__c 		= pol.Novidea_HPC__Renewal_Date__c ,
				Novidea_HPC__Vehicle_Year_of_manufacture__c = pol.Novidea_HPC__Vehicle_Production_Year__c,
				Novidea_HPC__Vehicle_Model__c 				= pol.Novidea_HPC__Vehicle_Manufacturer__c  ,
				Novidea_HPC__Vehicle_Model_In_Price_List__c	= pol.Novidea_HPC__Vehicle_Model__c         ,
				Novidea_HPC__Vehicle_Registration_Number__c = pol.NOvidea_HPC__Car_Number__c,
				Novidea_HPC__Premium_Currency__c 			= pol.Novidea_HPC__Premium_Amount_Currency__c,
				Novidea_HPC__Premium__c 					= pol.Novidea_HPC__Premium_Amount__c,
				Novidea_HPC__Premium_Net__c 				= pol.Novidea_HPC__Net_Premiumium__c,
				Novidea_HPC__Carrier__c 					= pol.Novidea_HPC__Carrier__c
				
			));
			if(proType!=null)ls[ls.size()-1].recordTypeId = proType; 
		}
		Database.insert(ls);
			
	}
	
	global void finish(Database.BatchableContext info){     
    }
    
    private void sendEmail(String msg, String subject){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');
        mail.setToAddresses(new String[]{'raniz@novideasoft.com'});
        mail.setSubject(dateTime.now().format() + ': Allied - BatchCreateProducts: ' + subject);
        String singleObjDetails = '';
        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }   
}