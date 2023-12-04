public with sharing class ContactTriggerHelper {

	public static Boolean inWork = false;
	public static boolean stopTrigger = false;

	public static void onBeforeDelete(list<Contact> deletedContactList) {
		
		if(stopTrigger) return;
		inWork = true; 
		
		deleteAssociatedPersons(deletedContactList);
				
		inWork = false;
		
	}
	
	private static void deleteAssociatedPersons(list<Contact> deletedContactList) {
		
		Set<Id> contIdSet = new Set<Id>();
		for(Contact contact : deletedContactList)
			contIdSet.add(contact.Id);
		
		list<Novidea_HPC__Associated_Person__c> assPersonList =
													[SELECT Id 
													   FROM Novidea_HPC__Associated_Person__c 
													  WHERE Novidea_HPC__Contact__c IN : contIdSet];
													  
	  	if(!assPersonList.isEmpty())
	  		Database.delete(assPersonList);		
		
	}
	
}