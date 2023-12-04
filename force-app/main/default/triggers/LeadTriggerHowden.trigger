trigger LeadTriggerHowden on Novidea_HPC__Lead__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	//AEF:
	Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c || TriggerHelpper.preventInboundRunning) return;
	
	if (Trigger.isBefore && Trigger.isInsert) {
		
        LeadTriggerHelperHowden.onBeforeInsert(Trigger.new); 
    } 
    else if (Trigger.isBefore && Trigger.isUpdate) {
    	
        LeadTriggerHelperHowden.onBeforeUpdate(Trigger.new);
        
    } 
    else if (Trigger.isBefore && Trigger.isDelete) { 
        
    }
    // ------------------------------------------------------------------------
    //  ---------------------------- AFTER EVENTS -----------------------------
    // ------------------------------------------------------------------------
    else  if(Trigger.isInsert && Trigger.isAfter){      
    } 
    else if (Trigger.isAfter && Trigger.isUpdate) {
    } 
    else if (Trigger.isAfter && Trigger.isDelete) {
    }

}