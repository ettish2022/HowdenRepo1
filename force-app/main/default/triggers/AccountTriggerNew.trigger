trigger AccountTriggerNew on Account (after insert, after update) {
	Novidea_HPC__Trigger__c hpcTriggerSettings = Novidea_HPC__Trigger__c.getInstance();
	NOVU__Trigger__c novuTriggerSettings = NOVU__Trigger__c.getInstance();
	if (
		(hpcTriggerSettings != null && hpcTriggerSettings.Novidea_HPC__Prevent_Running__c) ||
		(novuTriggerSettings != null && novuTriggerSettings.NOVU__Prevent_Running__c)
	) {
		return;
	}
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			AccountTriggerNewHelper.onAfterInsert((List<Account>) Trigger.new);
		}
		if (Trigger.isUpdate) {
			AccountTriggerNewHelper.onAfterUpdate((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
		}
	}
}