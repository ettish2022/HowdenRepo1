/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Novidea_HPC_PolicyTrigger on Novidea_HPC__Policy__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Novidea_HPC__Policy__c.SObjectType);
}