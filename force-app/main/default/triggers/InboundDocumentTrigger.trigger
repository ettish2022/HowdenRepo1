trigger InboundDocumentTrigger on InboundDocument__c (before insert, before update) {
    if (InboundDocumentTriggerHelper.preventInboundRunning)return;
    
    if(Trigger.isInsert && Trigger.isBefore){
        InboundDocumentTriggerHelper.setAccountOnDocument((list<InboundDocument__c>)Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        InboundDocumentTriggerHelper.handleChangeOfAccount((list<InboundDocument__c>)Trigger.new, (Map<ID, InboundDocument__c>)Trigger.oldMap);
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