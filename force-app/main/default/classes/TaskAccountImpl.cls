//TODO: if there is a case where many Ids are sent then the case might be that the soql limit will be crossed.
public with sharing class TaskAccountImpl implements AccountSObjectInterface{
	public AccountSObjectRelation[] getAccountSObjectRelations(ID[] objectIds){
		AccountSObjectRelation[] retval = new AccountSObjectRelation[]{};
		Id relatedEntId ;
		map<Id,Id> taskToWhatDocuments = new map<Id,Id>();
		for(Task t :[SELECT Subject, WhoId, WhatId FROM Task WHERE ID IN : objectIds]){
			relatedEntId = t.WhatId;
			if(relatedEntId==null) relatedEntId = t.whoId;
			if('inboundDocument__c'.equalsIgnoreCase(relatedEntId.getSobjectType().getDescribe().getName())){
				taskToWhatDocuments.put(t.Id,relatedEntId);
			}
			else {
				AccountSObjectRelation[] localres = FilingUtils.getAccountSObjectRelationsById(relatedEntId);
				system.debug(relatedEntId + ' ' + localres);
				//replace the objectId, objectName with the right *task* name and Id
				for(AccountSObjectRelation asr: localres){
					if('Account'.equalsIgnoreCase(relatedEntId.getSobjectType().getDescribe().getName())){
						asr.accountId = asr.objectId;
						asr.accountName = asr.objectName;
					}
					asr.objectId = t.Id;
					asr.objectName = t.Subject;
				}
				retval.addAll(localres);
			}
		}
		if(!taskToWhatDocuments.isempty()){
			//TODO: populate the objectId, objectName with the right *task* name and Id
			for(InboundDocument__c doc: [SELECT Subject__c, Account__r.Name, Account__c FROM InboundDocument__c WHERE Id IN: taskToWhatDocuments.values()]){
				AccountSObjectRelation asor = new AccountSObjectRelation();
        		asor.accountId = doc.Account__c;
        		asor.accountName = doc.Account__r.Name; 
        		asor.objectId = doc.Id;
        		asor.objectName = doc.Subject__c; 
				retval.add(asor);
			}
		}
		system.debug(retval);
		return retval;
	}
}