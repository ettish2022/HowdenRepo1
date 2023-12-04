public with sharing class DeleteDefaultLeadClientController {
	
	public DeleteDefaultLeadClientController(ApexPages.StandardController controller){
		
	}
	public PageReference init(){
		Default_Account__c leadClient = Default_Account__c.getInstance('AccountId');
		String LeadId = Apexpages.currentPage().getParameters().get('id');
		Novidea_HPC__Lead__c lead = [select id, Novidea_HPC__Client__c from Novidea_HPC__Lead__c where id =: leadId];
		if (leadClient != null && lead.Novidea_HPC__Client__c == leadClient.ID__c )
            lead.Novidea_HPC__Client__c  = null ;
		
		database.update(lead);
		
		PageReference pageRef = Page.Novidea_HPC__ConvertLead; 
        pageRef.getParameters().put('id', lead.id);
        pageRef.setRedirect(false);
        return pageRef;
	}

}