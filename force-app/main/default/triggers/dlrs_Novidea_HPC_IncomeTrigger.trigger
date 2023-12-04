/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Novidea_HPC_IncomeTrigger on Novidea_HPC__Income__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Novidea_HPC__Income__c.SObjectType);
}