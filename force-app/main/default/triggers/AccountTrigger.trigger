trigger AccountTrigger on Account (before insert, before update, after delete) {
    Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance();
    static String deleted; 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return;
    if (Trigger.isBefore && Trigger.isInsert) { // Before Insert
        setNextAccountNumber((list<Account>)Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) { // Before Update
    	mergeAccountsUpdate(Trigger.new);
        if (WSYigod.UpdateObject){
            TriggerHelpper.BeforeUpdating(Trigger.oldMap, Trigger.newMap, 'Account');
        }
    } else if (Trigger.isAfter && Trigger.isDelete) { // After deletion
    	mergeAccountsDelete(Trigger.old);
    }
    
    
    private void setNextAccountNumber(list<Account> accounts){
        String userPrefixForAccounuts = [SELECT Client_Number_Prefix__c FROM User WHERE Id=:Userinfo.getUserId()].Client_Number_Prefix__c;
        list<Account> ar = [SELECT Incremental_Number__c FROM Account ORDER BY Incremental_Number__c DESC NULLS LAST LIMIT 1];
        Decimal maxActNum =0;
        if(!ar.isEmpty()) maxActNum = ar[0].Incremental_Number__c;
        if(maxActNum==null || maxActNum==0){
            maxActNum = 30000000;
        }
        else{
            maxActNum = maxActNum+1;
        }
        long actNum;
        String strMaxActNum;
        for(Account act: accounts){
            if(null!= userPrefixForAccounuts && !''.equals(userPrefixForAccounuts)){
                strMaxActNum = '' + maxActNum;
                strMaxActNum = strMaxActNum.substring(0,1) + userPrefixForAccounuts + strMaxActNum.substring(1);
                actNum = long.valueOf(strMaxActNum);
            }
            else{
                actNum = maxActNum.longValue();
            }
            act.AccountNumber = '' + actNum;
            act.Incremental_Number__c = maxActNum;
            maxActNum++;
        } 
    }
    
    private void mergeAccountsDelete(List<Account> accounts){
    	TriggerHelpper.accountRemarks = new Map<Id,String>();
    	TriggerHelpper.oldToNew = new Map<Id,Id> ();
    	
    	for (Account account:accounts) {
    		if (account.MasterRecordId != null && account.MasterRecordId != account.Id) {
    			TriggerHelpper.oldToNew.put(account.Id, account.MasterRecordId);
    			if (!TriggerHelpper.accountRemarks.containsKey(account.MasterRecordId))
    				TriggerHelpper.accountRemarks.put(account.MasterRecordId, '');
    			
    			if (account.description != '' && account.description != null)
    				TriggerHelpper.accountRemarks.put(account.MasterRecordId, TriggerHelpper.accountRemarks.get(account.MasterRecordId) + '\n' + account.description);
    		}
    	}
    }
    private void mergeAccountsUpdate(List<Account> accounts){
    	if (TriggerHelpper.accountRemarks != null) {
	    	for (Account account:accounts) {
	    		if (account.description == null || account.description == '')
	    			account.description = TriggerHelpper.accountRemarks.get(account.Id);
	    		else 
		    		account.description += '\n' + TriggerHelpper.accountRemarks.get(account.Id);
	    	}
    	}
    	if (TriggerHelpper.oldToNew != null) {
    		List<InboundDocument__c> documentsForUpdate = new List<InboundDocument__c>();
    		List<Account> oldAccounts = [Select (Select Id, EntId1__c,EntId2__c,EntId3__c,EntId4__c,EntId5__c,EntId6__c,
    					EntId7__c,EntId8__c, EntId9__c,EntId10__c,EntId11__c,EntId12__c,
    					EntId13__c,EntId14__c,EntId15__c,EntId16__c,EntId17__c,EntId18__c,
    					EntId19__c,EntId20__c From Inbound_Documents__r) 
    				From Account Where Id IN :TriggerHelpper.oldToNew.values()];
    		for (Account oldAccount:oldAccounts) {
    			for (InboundDocument__c document:oldAccount.Inbound_Documents__r) {
    				//documentsForUpdate.add(document);
    				for(integer i=1;i<=20;++i){
				           //String s = (String)document.get('EntId' + i + '__c');
				           if((String)document.get('EntId' + i + '__c')==null || !((String)document.get('EntId' + i + '__c')).startsWith('001'))continue;
				           if (TriggerHelpper.oldToNew.containsKey((Id)(String)document.get('EntId' + i + '__c'))) {
					           document.put('EntId' + i + '__c', TriggerHelpper.oldToNew.get((Id)(String)document.get('EntId' + i + '__c')));
					          break;
				           }
				     	}
				     if (documentsForUpdate.size() == 10000) {
				     	triggerSetting.Novidea_HPC__Prevent_Running__c = true;
				     	Database.update(documentsForUpdate);
				     	triggerSetting.Novidea_HPC__Prevent_Running__c = false;
				     	documentsForUpdate.clear();
				     }
    			}
    			TriggerHelpper.preventInboundRunning = true;
		     	Database.update(oldAccount.Inbound_Documents__r);
		     	TriggerHelpper.preventInboundRunning = false;
    		}
    		
    		/*
    		// It's assume account is always in the first entityId.
    		String wantedIds = '';
    		for (Id accountId:TriggerHelpper.oldToNew.keySet()) {
    			if (wantedIds != '')
    				wantedIds += ' Or ';
    			wantedIds += '"' + accountId + '*' + '"';
    		}
    		wantedIds = '{' + wantedIds + '}';
    		String searchquery='FIND ' +wantedIds + ' IN ALL FIELDS RETURNING InboundDocument__c(' +
    				'Id, EntId1__c,EntId2__c,EntId3__c,EntId4__c,EntId5__c,EntId6__c,' +
                                ' EntId7__c,EntId8__c,EntId9__c,EntId10__c,EntId11__c,EntId12__c, '+
                                ' EntId13__c,EntId14__c,EntId15__c,EntId16__c,EntId17__c,EntId18__c, ' +
                                ' EntId19__c,EntId20__c  ' + 
    			')'; 
    		List<List<SObject>>searchList=search.query(searchquery);
    		while (searchList != null && searchList.size() > 0 && searchList[0].size() > 0) {
	    		List<InboundDocument__c> documents = new List<InboundDocument__c> ();
	    		for (List<InboundDocument__c > foundDocuments:searchList)
	    			for (InboundDocument__c document:foundDocuments)
		    			for(integer i=1;i<=20;++i){
				           String s = (String)document.get('EntId' + i + '__c');
				           if(s==null || !s.startsWith('001'))continue;
				           document.put('EntId' + i + '__c', TriggerHelpper.oldToNew.get((Id)s));
				           documents.add(document);
				           break;
				     	}
	    		Database.update(documents);
	    		searchList=search.query(searchquery);
    		}
    		*/
    	}
	    System.debug(TriggerHelpper.accountRemarks);
    }

}