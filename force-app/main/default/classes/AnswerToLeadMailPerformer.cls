global with sharing class AnswerToLeadMailPerformer implements Messaging.InboundEmailHandler {
	
	 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
	 	try {
	 		ID leadId;
	 		Integer begIndex = email.subject.indexOf('[');
	 		Integer endIndex = email.subject.indexOf(']');
	 		if(begIndex >= 0 && endIndex >= 0) {
	 			try {
	 				leadId = ID.valueOf(email.subject.substring(begIndex+1, endIndex));
	 			} catch (Exception exp) {
	 				result.success = false;
					result.message = 'ID of lead is invalid' ; 
					return result;	
	 			}
	 			
	 			Novidea_HPC__Lead__c lead = getLeadListById(leadId); 
	 			if(null == lead) {
	 				result.success = false;
					result.message = 'Sent lead not exist, please apply to the company' ; 
					return result;
	 			}
	 			
				Task answerTask = new Task(
									Subject = Label.Customer_answered
									,WhatId = leadId
									,Description = email.plainTextBody
									,OwnerId = lead.OwnerId
									,ReminderDateTime = null);
									
	 			Database.DMLOptions dbOption = new Database.DMLOptions();
	 			dbOption.allowFieldTruncation = true; 
	 			Database.insert(answerTask, dbOption);
	 			
	 			lead.Responded__c = true;
	 			Insurance_Cross_Sale__c insurCrossSale = new Insurance_Cross_Sale__c(
	        						 						 Id = lead.Insurance_Cross_Sale__c 
	        												,Leads_Changed__c = true); 
	 			
	 			
	 			Database.update(new sObject[] {lead, insurCrossSale});
	 			
	 		}
			result.success = true;
          
	 	} catch(Exception exp) {
			system.debug(TestUtils.exceptionDump(exp));
			result.success = false;
			result.message = exp.getMessage() ; 		 		
	 	}
        return result;
      }

	public static Novidea_HPC__Lead__c getLeadListById(ID leadId) {
    	list<Novidea_HPC__Lead__c> leadList =
							    	[SELECT Id, Name
							    		   ,OwnerID
							    		   ,Responded__c
							    		   ,Insurance_Cross_Sale__c
							    	  FROM Novidea_HPC__Lead__c
							    	 WHERE Id =: leadId];
							    	 	
		return (!leadList.isEmpty() ? leadList[0] : null);
    }	
}