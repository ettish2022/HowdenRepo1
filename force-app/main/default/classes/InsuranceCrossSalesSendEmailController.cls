public with sharing class InsuranceCrossSalesSendEmailController { 

	//private static ID templateId;
	private static EmailTemplate EMAIL_TEMPLATE;
	private static String[] TEMPLATE_FIELDS;
	private static String REPLY_TO_EMAIL;
	private static General__c generalSetting;  
	
	
	static {
		generalSetting = General__c.getInstance();
		REPLY_TO_EMAIL   = generalSetting.Email_to_reply_Insurance_Cross_Sales__c;
		//exstract field list from conten of meta tag in email template		
		try {	
			EMAIL_TEMPLATE = getTemplateByDevName(generalSetting.Email_Template_Insurance_Cross_Sales__c);
			//todo: change to regular exspresion
			TEMPLATE_FIELDS = EMAIL_TEMPLATE.HtmlValue.substring(EMAIL_TEMPLATE.HtmlValue.indexOf('content=')+9,
																 EMAIL_TEMPLATE.HtmlValue.indexOf('>')-1).split(',');
			
		} catch(Exception exp) {
			system.debug(TestUtils.exceptionDump(exp));
			throw new TestUtils.ApplicationException('Developer name of email template not set or missing meta tag in template body');
		} 	
	}
	 
    public ID insCrossSaleId {get; private set;}

    public InsuranceCrossSalesSendEmailController(ApexPages.StandardController controller) {
        insCrossSaleId = controller.getId();
    }

    /*  send emails
        go over the leads email, and send them email messages 
        email templateId should be defined in custom settings
    */
    public PageReference sendemails(){
        
        try {
        	list<Novidea_HPC__Lead__c> toUpdateLeadList = new list<Novidea_HPC__Lead__c>();
	        list<Novidea_HPC__Lead__c> leadList = getLeadListByInsCrossSaleId(insCrossSaleId, TEMPLATE_FIELDS);
	        list<Messaging.SingleEmailMessage> mailList = new list<Messaging.SingleEmailMessage>();
	        for(Novidea_HPC__Lead__c lead : leadList) {
	        	
	        	if(String.isBlank(lead.Novidea_HPC__Contact_Email__c) || ArrayUtils.isListNullOrEmpty(lead.Novidea_HPC__Products__r))
	        		continue;
	        	
	        	String[] templFieldValueList = new list<String>();
	        	for(Integer x = 0; x < TEMPLATE_FIELDS.size(); x++) {
	        		String fieldName = TEMPLATE_FIELDS[x];
	        		templFieldValueList.add(String.valueOf(lead.get(fieldName)));
	        	}
	        		
	        	String emalHtmlBody = '<ol>';
	        	for(Novidea_HPC__Product__c prod : lead.Novidea_HPC__Products__r)
	        		emalHtmlBody += '<li>' + prod.Name + '</li>';
	        		
	        	emalHtmlBody = emalHtmlBody + '</ol>';	
	        	emalHtmlBody = EMAIL_TEMPLATE.HtmlValue.replace('{Dinamy:0}', emalHtmlBody);
	        	emalHtmlBody = String.format(emalHtmlBody, templFieldValueList);
	        	 
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        mail.setReplyTo(REPLY_TO_EMAIL);
		        mail.setHtmlBody(emalHtmlBody);
		        mail.setSubject(String.format(EMAIL_TEMPLATE.Subject , new String[] {lead.Id} ));
		        mail.setToAddresses(new list<String>{ lead.Novidea_HPC__Contact_Email__c });
		        
		        mailList.add(mail);
		        
		        lead.Sent__c = true;
		        toUpdateLeadList.add(lead);
	        }
	        Integer sentEmailCounter = 0;
	        if(!mailList.isEmpty()) {
	        	list<Messaging.SendEmailResult> sendResultList = Messaging.sendEmail(mailList);
	        	for(Messaging.SendEmailResult result : sendResultList) {
	        		 if(result.isSuccess()) ++sentEmailCounter;
	        	}
	        }
	        
	        if(!toUpdateLeadList.isEmpty()) {
	        	Database.update(toUpdateLeadList);
	        	Database.update(new Insurance_Cross_Sale__c(
	        						 Id = toUpdateLeadList[0].Insurance_Cross_Sale__c 
	        						,Leads_Changed__c = true)); 
	        }
	        	
	        if(mailList.size() != leadList.size() || 0 == mailList.size()) {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.Not_All_email_send));
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 
	        											   String.format(Label.Email_counter, 
	        											   				 new String[] { sentEmailCounter.format() })));
	        											   				 
	        	return null;
	        }
	        
	        return updateParent();
	        
        } catch(Exception exp) {
        	TestUtils.performException(exp);
	        return null;
        }
    }
    
    public PageReference updateParent() {
    	PageReference pageReloader = Page.PageReloader;
    	pageReloader.getParameters().put('url','/' + ApexPages.currentPage().getParameters().get('id'));
    	return  pageReloader;
    }
    
    private static list<Novidea_HPC__Lead__c> getLeadListByInsCrossSaleId(ID insCrossSaleId, String[] fieldNames) {
    	
    	String query = 'SELECT Id, Name';
    	
    	Set<String> fieldNameSet = new Set<String>();
    	fieldNameSet.addAll(fieldNames);
    	fieldNameSet.add('Novidea_HPC__Contact_Email__c');
    	fieldNameSet.add('Sent__c');
    	fieldNameSet.add('Insurance_Cross_Sale__c');
    	
   		for(String fieldName : fieldNameSet) 
   			query += ',' + fieldName;
    		
   		/*query += ',' + String.join(fieldNames,',');
    	if(!query.contains('Novidea_HPC__Contact_Email__c'))
    		query += ',Novidea_HPC__Contact_Email__c';*/
    		
    		  
    	query += ',(SELECT Id, Name FROM Novidea_HPC__Products__r)';
    	query += ' FROM Novidea_HPC__Lead__c';
    	query += ' WHERE Insurance_Cross_Sale__c = ' + '\'' + insCrossSaleId + '\'';
	    query += ' limit 10000';

		system.debug('query >>>' + query);
		    
	    return (list<Novidea_HPC__Lead__c>)Database.query(query);
   }
   
   private static EmailTemplate getTemplateByDevName(String devName) {
   		list<EmailTemplate> templList = 
						   		[SELECT Id, Body, 
						   				Subject, IsActive, 
						   				HtmlValue, DeveloperName 
						   		   FROM EmailTemplate
						   		  WHERE DeveloperName =: devName];

		return !templList.isEmpty() ? templList[0] : null; 						   		  
   		
   }
}