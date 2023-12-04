trigger PolicyTrigger on Novidea_HPC__Policy__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return;
    if(Trigger.isInsert && Trigger.isBefore){
		PolicyTriggerHelper.onBeforeInsert((Novidea_HPC__Policy__c[])Trigger.New);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
	      	
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
    	PolicyTriggerHelper.onBeforeUpdate((Novidea_HPC__Policy__c[])Trigger.old, 
    										(map<Id,Novidea_HPC__Policy__c>)Trigger.oldMap, 
    										(Novidea_HPC__Policy__c[])Trigger.new, 
    										(map<Id,Novidea_HPC__Policy__c>)Trigger.newMap);
   }
    else if(Trigger.isUpdate && Trigger.isAfter){
    }
    else if(Trigger.isDelete && Trigger.isBefore){
    }
    else if(Trigger.isDelete && Trigger.isAfter){
    }
    else if(Trigger.isUnDelete){
    }
    
    
    
}