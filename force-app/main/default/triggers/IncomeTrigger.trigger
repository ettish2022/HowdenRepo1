trigger IncomeTrigger on Novidea_HPC__Income__c (after delete, after insert, after undelete, 
        after update, before delete, before insert, before update) {
    Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    system.debug('before check trigger setting');
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return; 
    system.debug('after check trigger setting');
    
    if(Trigger.isInsert && Trigger.isBefore){  
        System.debug(Trigger.new);
        IncomeTriggerHelper.updateCommissions((list<Novidea_HPC__Income__c>)Trigger.new);
        CurrencyTriggerHelper.updateCurrency(Income_Currency__c.getInstance(),Novidea_HPC__Income__c.sObjectType.getDescribe(),Trigger.new);
        Set<Id> policiesIds = new Set<Id>();
        List<Novidea_HPC__Income__c> newIncomeList = (List<Novidea_HPC__Income__c>)Trigger.new;
        for (Novidea_HPC__Income__c income: newIncomeList){
            if (income.Novidea_HPC__Income_Recognition_Date__c == null)
                income.Novidea_HPC__Income_Recognition_Date__c = income.Novidea_HPC__Bordero_Date__c;
            policiesIds.add(income.Novidea_HPC__Policy__c);
        }
        //AEF:
        IncomeTriggerHelper.updateEndorsemetEffectiveDateInPolicy(policiesIds, newIncomeList);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        List<Novidea_HPC__Income__c> newIncomeList = (List<Novidea_HPC__Income__c>)Trigger.new;
        Set<Id> policiesIds = new Set<Id>();
        for (Novidea_HPC__Income__c income: newIncomeList)
            policiesIds.add(income.Novidea_HPC__Policy__c);
        
        TriggerHelpper.updatePolicyManagedByProduction(policiesIds);
        //TriggerHelpper.approvalProcess(policiesIds);
        IncomeTriggerHelper.splitIncome(newIncomeList, trigger.newMap); 
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        List<Novidea_HPC__Income__c> updatedIncomeList = (List<Novidea_HPC__Income__c>)Trigger.new;
        IncomeTriggerHelper.checkRight2IncomeChanging(updatedIncomeList,trigger.oldMap, Approval_Process__c.getInstance().Allow_Income_Edit__c);
        IncomeTriggerHelper.updateCommissions((list<Novidea_HPC__Income__c>)Trigger.new);
        CurrencyTriggerHelper.updateCurrency(Income_Currency__c.getInstance(),Novidea_HPC__Income__c.sObjectType.getDescribe(),Trigger.new);
        
        Set<Id> policiesIds = new Set<Id>();
        for (Novidea_HPC__Income__c income: updatedIncomeList){
            if (income.Novidea_HPC__Income_Recognition_Date__c == null)
                income.Novidea_HPC__Income_Recognition_Date__c = income.Novidea_HPC__Bordero_Date__c;
            policiesIds.add(income.Novidea_HPC__Policy__c);
        }
        TriggerHelpper.updatePolicyManagedByProduction(policiesIds); 
        //AEF: function updates Endorsemet Effective Date of policy depends on the last entered Income
        IncomeTriggerHelper.updateEndorsemetEffectiveDateInPolicy(policiesIds, updatedIncomeList);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        //AEF:
         IncomeTriggerHelper.splitIncome(trigger.new, trigger.oldMap);  
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        Set<Id> policiesIds = new Set<Id>();
        List<Novidea_HPC__Income__c> oldIncomeList = (List<Novidea_HPC__Income__c>)Trigger.old;
        for (Novidea_HPC__Income__c income: oldIncomeList){
            policiesIds.add(income.Novidea_HPC__Policy__c);
        }
        TriggerHelpper.updatePolicyManagedByProduction(policiesIds);
        //AEF:
        IncomeTriggerHelper.splitIncome(oldIncomeList, trigger.oldMap);                   
    }
    else if(Trigger.isUnDelete){
    }
    CurrencyHelper.currencyFieldNamesByTargetField = null;
    
}