trigger CollectionFromCarrierTriggerHowden on Novidea_HPC__Collection_From_Carrier__c (after delete, after insert, after undelete, 
		after update, before delete, before insert, before update) {
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		SumByCarrierHelper.searchAndCreate(trigger.New, trigger.oldMap);
	}
}