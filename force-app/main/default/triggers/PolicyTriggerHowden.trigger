trigger PolicyTriggerHowden on Novidea_HPC__Policy__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

     Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c || TriggerHelpper.preventInboundRunning)return;
    if (Trigger.isBefore && Trigger.isInsert) {
        PolicyTriggerHelperHowden.onBeforeInsert(Trigger.new); 
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        PolicyTriggerHelperHowden.onBeforeUpdate(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isDelete) { 
        PolicyTriggerHelperHowden.onBeforeDelete(Trigger.old); 
    }
    // ------------------------------------------------------------------------
    //  ---------------------------- AFTER EVENTS -----------------------------
    // ------------------------------------------------------------------------
    else  if(Trigger.isInsert && Trigger.isAfter){      
        PolicyTriggerHelperHowden.onAfterInsert((list<Novidea_HPC__Policy__c>)Trigger.new);             
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        PolicyTriggerHelperHowden.onAfterUpdate((list<Novidea_HPC__Policy__c>)Trigger.old,
                (map<Id,Novidea_HPC__Policy__c>)Trigger.newMap);        
        system.debug('Trigger.new: ' + Trigger.new); 
    } else if (Trigger.isAfter && Trigger.isDelete) {
        PolicyTriggerHelperHowden.onAfterDelete((list<Novidea_HPC__Policy__c>)Trigger.old);     
    }
}