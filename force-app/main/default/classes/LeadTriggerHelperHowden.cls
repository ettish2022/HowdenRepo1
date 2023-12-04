public with sharing class LeadTriggerHelperHowden {

	public static Boolean inWork = false;
	public static boolean stopTrigger = false;
	
	public static void onBeforeInsert(list<Novidea_HPC__Lead__c> newLeadList){  
		if(stopTrigger) return;
		inWork = true; 
		detectIsActiv(newLeadList);
		inWork = false;
	}
	public static void onBeforeUpdate(list<Novidea_HPC__Lead__c> newLeadList){  
		if(stopTrigger) return;
		inWork = true; 
		detectIsActiv(newLeadList);  	 
		inWork = false;
	}
	
	public static void detectIsActiv(list<Novidea_HPC__Lead__c> newLeadList) {
		
		for(Novidea_HPC__Lead__c lead : newLeadList) {
			if('Closed'.equalsIgnoreCase(lead.Novidea_HPC__Status__c)) {
				lead.Lead_Active__c = null;
				lead.Lead_Not_Active__c = lead.Novidea_HPC__Client__c;
			}
			else {
				lead.Lead_Not_Active__c = null;
				lead.Lead_Active__c = lead.Novidea_HPC__Client__c ;
			}
			
		}
	}
	
	 
}