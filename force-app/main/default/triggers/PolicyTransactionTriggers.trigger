trigger PolicyTransactionTriggers on Policy_Transaction__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) { 
    Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    system.debug('before check trigger setting');
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return;
            // ------------------------------------------------------------------------
    //  ---------------------------- Before EVENTS -----------------------------
    // ------------------------------------------------------------------------
    if (Trigger.isBefore && Trigger.isInsert) // Before Insert
    {
        PolicyTransactionHandler.readPolicyContent(Trigger.new);
    }
    else if (Trigger.isBefore && Trigger.isUpdate) // Before Update
    {
        
    }
    else if (Trigger.isBefore && Trigger.isDelete) // Before Delete
    { 
        
    }
    // ------------------------------------------------------------------------
    //  ---------------------------- AFTER EVENTS -----------------------------
    // ------------------------------------------------------------------------
    else if (Trigger.isAfter && Trigger.isInsert) // After Insert
    {
    	PolicyTransactionHandler.automaticMatching(Trigger.new);
    }
    else if (Trigger.isAfter && Trigger.isUpdate) // After Update
    {
        
    }
    else if (Trigger.isAfter && Trigger.isDelete) // After Delete
    {

    }
}