trigger PolicyBreakdownTrigger on Novidea_HPC__Policy_Breakdown__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
        //PolicyBreakdownHelper.summaryBreakdowns(trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter) {
        //PolicyBreakdownHelper.summaryBreakdowns(trigger.new);
    }
    

}