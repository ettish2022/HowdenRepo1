trigger LeadTrigger on Novidea_HPC__Lead__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
        Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (!triggerSetting.Novidea_HPC__Prevent_Running__c){   
        System.debug(Trigger.isInsert + ' ' + Trigger.isUpdate);
        if(Trigger.isInsert && Trigger.isBefore){
            LeadTriggerHelper.onBeforeInsert((List<Novidea_HPC__Lead__c>)Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            LeadTriggerHelper.onAfterInsert((List<Novidea_HPC__Lead__c>)Trigger.new);        
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            LeadTriggerHelper.onBeforeUpdate((List<Novidea_HPC__Lead__c>)Trigger.old, 
                    (Map<Id,Novidea_HPC__Lead__c>) Trigger.oldMap,
                    (List<Novidea_HPC__Lead__c>)Trigger.new,
                    (Map<Id,Novidea_HPC__Lead__c>) Trigger.newMap); 
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            LeadTriggerHelper.onAfterUpdate((List<Novidea_HPC__Lead__c>)Trigger.old,  
                    (List<Novidea_HPC__Lead__c>)Trigger.new,
                    (Map<Id,Novidea_HPC__Lead__c>)Trigger.oldMap, 
                    (Map<Id,Novidea_HPC__Lead__c>)Trigger.newMap);
        }
        else if(Trigger.isDelete && Trigger.isBefore){
            LeadTriggerHelper.onBeforeDelete((List<Novidea_HPC__Lead__c>)Trigger.old, 
                    (Map<Id,Novidea_HPC__Lead__c>)Trigger.oldMap);
        }
        else if(Trigger.isDelete && Trigger.isAfter){
            LeadTriggerHelper.onAfterDelete((List<Novidea_HPC__Lead__c>)Trigger.old, 
                    (Map<Id,Novidea_HPC__Lead__c>)Trigger.oldMap);
        }
        else if(Trigger.isUnDelete){
            LeadTriggerHelper.onUndelete((List<Novidea_HPC__Lead__c>)Trigger.new);   
        }
    }

}