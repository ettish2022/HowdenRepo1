public with sharing class ApplicationTriggerHelperHowden {

	public static Boolean inWork = false;
	public static boolean stopTrigger = false;
	
	public static void onBeforeInsert(list<Novidea_HPC__Application__c> newApplicationList){  
		if(stopTrigger) return;
		inWork = true; 
		detectIsActiv(newApplicationList);
		inWork = false;
	}
	public static void onBeforeUpdate(list<Novidea_HPC__Application__c> newApplicationList){  
		if(stopTrigger) return;
		inWork = true; 
		detectIsActiv(newApplicationList);  	 
		inWork = false;
	}
	
	public static void detectIsActiv(list<Novidea_HPC__Application__c> newApplicationList) {
		
		for(Novidea_HPC__Application__c application : newApplicationList) {
			if('New'.equalsIgnoreCase(application.Novidea_HPC__Status__c)) {
				application.Application_Active__c = application.Novidea_HPC__Account__c;
				application.Application_Not_Active__c = null;
			}
			else if('Expired'.equalsIgnoreCase(application.Novidea_HPC__Status__c)) {
				application.Application_Active__c = null;
				application.Application_Not_Active__c = application.Novidea_HPC__Account__c;
			}
			
		}
	} 
}