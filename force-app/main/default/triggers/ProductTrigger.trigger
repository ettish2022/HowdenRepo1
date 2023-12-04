trigger ProductTrigger on Novidea_HPC__Product__c (before insert, before update) {
	if(Trigger.isInsert && Trigger.isBefore){
		//ProductTriggerHelper.updateApplication(Trigger.new);
	}
	else if(Trigger.isUpdate && Trigger.isBefore){
		//ProductTriggerHelper.updateApplication(Trigger.new);
	}
}