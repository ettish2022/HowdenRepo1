trigger ContactTriggerHowden on Contact (before delete) {

	Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return;
    
    //else if(Trigger.isDelete && Trigger.isBefore)
    ContactTriggerHelper.onBeforeDelete(Trigger.old);
    

}