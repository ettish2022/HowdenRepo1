trigger ContactTriggers on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    // ------------------------------------------------------------------------
    //  ---------------------------- Before EVENTS -----------------------------
    // ------------------------------------------------------------------------
    if (Trigger.isBefore && Trigger.isInsert) // Before Insert
    {
    }
    else if (Trigger.isBefore && Trigger.isUpdate) // Before Update
    {
        if (WSYigod.UpdateObject){
            TriggerHelpper.BeforeUpdating(Trigger.oldMap, Trigger.newMap, 'Contact');
        }
    }
    else if (Trigger.isBefore && Trigger.isDelete) // Before Delete
    { 
        
    }
    // ------------------------------------------------------------------------
    //  ---------------------------- AFTER EVENTS -----------------------------
    // ------------------------------------------------------------------------
    else if (Trigger.isAfter && Trigger.isInsert) // After Insert
    {
        
    }
    else if (Trigger.isAfter && Trigger.isUpdate) // After Update
    {
        
    }
    else if (Trigger.isAfter && Trigger.isDelete) // After Delete
    {

    }
    

}