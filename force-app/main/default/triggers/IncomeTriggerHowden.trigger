trigger IncomeTriggerHowden on Novidea_HPC__Income__c (after delete, after insert, after undelete, 
		after update, before delete, before insert, before update) {
	
	if(Trigger.isInsert && Trigger.isBefore){
		SumByCarrierHelper.searchAndCreate(trigger.New, trigger.oldMap);
	} else if(Trigger.isInsert && Trigger.isAfter){
		
	} else if(Trigger.isUpdate && Trigger.isBefore){
		SumByCarrierHelper.searchAndCreate(trigger.New, trigger.oldMap);
	} else if(Trigger.isUpdate && Trigger.isAfter){
		
	} else if(Trigger.isDelete && Trigger.isBefore){
		
	} else if(Trigger.isDelete && Trigger.isAfter){
		
	} else if(Trigger.isUnDelete){
		
	}
}