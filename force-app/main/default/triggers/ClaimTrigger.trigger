trigger ClaimTrigger on Novidea_HPC__Claim__c (before insert, before update, after update) {
    Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c)return;
    if (Trigger.isBefore && Trigger.isInsert) // Before Insert
    {
        setNextClaimNumber((list<Novidea_HPC__Claim__c>)Trigger.new);
        getPolicyData((list<Novidea_HPC__Claim__c>)Trigger.new);
       	CurrencyTriggerHelper.updateCurrency(Novidea_HPC__Claim_Currency__c.getInstance(),Novidea_HPC__Claim__c.sObjectType.getDescribe(),Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate)
    {
       	CurrencyTriggerHelper.updateCurrency(Novidea_HPC__Claim_Currency__c.getInstance(),Novidea_HPC__Claim__c.sObjectType.getDescribe(),Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate)
    {
    	list<Novidea_HPC__Claim__c> clms = new list<Novidea_HPC__Claim__c>();
    	for(Novidea_HPC__Claim__c clm: (list<Novidea_HPC__Claim__c>) Trigger.newMap.values()){
    		if(clm.Novidea_HPC__Client__c!=((Novidea_HPC__Claim__c)Trigger.oldMap.get(clm.Id)).Novidea_HPC__Client__c)
    			clms.add(clm);
    	}
    	list<Novidea_HPC__Involved_In_Claim__c> iics = [SELECT Client__c, Novidea_HPC__Claim__r.Novidea_HPC__Client__c 
    													FROM Novidea_HPC__Involved_In_Claim__c 
    													WHERE Novidea_HPC__Claim__c IN: clms];
    	for(Novidea_HPC__Involved_In_Claim__c iic: iics){
    		iic.Client__c = iic.Novidea_HPC__Claim__r.Novidea_HPC__Client__c;
    	}
    	Database.Update(iics);
    }    
    private void setNextClaimNumber(list<Novidea_HPC__Claim__c> claims){
        list<Novidea_HPC__Claim__c> ar = [SELECT Incremental_Number__c FROM Novidea_HPC__Claim__c ORDER BY Incremental_Number__c DESC NULLS LAST LIMIT 1];
        Decimal maxClaimNum = 0;
        if(!ar.isEmpty())maxClaimNum = ar[0].Incremental_Number__c;
        if(maxClaimNum==null || maxClaimNum==0)
            maxClaimNum = 3000000;
        else{
            maxClaimNum = maxClaimNum+1;
        }
        for(Novidea_HPC__Claim__c claim: claims){
            claim.Name = ''+maxClaimNum;
            claim.Novidea_HPC__Claim_Number__c = ''+maxClaimNum;
            claim.Incremental_Number__c = maxClaimNum;
            maxClaimNum++;
        } 
    }
    
    private void getPolicyData(list<Novidea_HPC__Claim__c> claims){
    	Set<Id> policyIds = new Set<Id>();
    	for(Novidea_HPC__Claim__c claim: claims){
            policyIds.add(claim.Novidea_HPC__Policy__c);
        }
        Map<Id, Novidea_HPC__Policy__c> policies = new Map<Id, Novidea_HPC__Policy__c>(
        		[Select Novidea_HPC__Client__c, Novidea_HPC__Carrier__c, Novidea_HPC__Product_Definition__c, Novidea_HPC__Effective_Date__c,
        				Novidea_HPC__Expiration_Date__c, 
        				Novidea_HPC__Car_Number__c, Novidea_HPC__Liability_Limit_Per_Case__c, Novidea_HPC__Upper_Limit_of_Liability__c 
        		From Novidea_HPC__Policy__c Where Id IN :policyIds]);
    	for(Novidea_HPC__Claim__c claim: claims){
    		if (policies.containsKey(claim.Novidea_HPC__Policy__c)) {
    			Novidea_HPC__Policy__c policy = policies.get(claim.Novidea_HPC__Policy__c);
    			if (policy.Novidea_HPC__Liability_Limit_Per_Case__c != null && claim.Novidea_HPC__Liability_Limit__c == null)
    				claim.Novidea_HPC__Liability_Limit__c = policy.Novidea_HPC__Liability_Limit_Per_Case__c;
    			else if (policy.Novidea_HPC__Upper_Limit_of_Liability__c != null && claim.Novidea_HPC__Liability_Limit__c == null)
    				claim.Novidea_HPC__Liability_Limit__c = policy.Novidea_HPC__Upper_Limit_of_Liability__c;
    			if (policy.Novidea_HPC__Carrier__c != null && claim.Novidea_HPC__Carrier__c == null)
    				claim.Novidea_HPC__Carrier__c = policy.Novidea_HPC__Carrier__c;
    			if (policy.Novidea_HPC__Client__c != null && claim.Novidea_HPC__Client__c == null)
    				claim.Novidea_HPC__Client__c = policy.Novidea_HPC__Client__c;
    			if (policy.Novidea_HPC__Car_Number__c != null && claim.Vehicle_Number__c == null)
    				claim.Vehicle_Number__c  = policy.Novidea_HPC__Car_Number__c; 
    			if (policy.Novidea_HPC__Product_Definition__c != null && claim.Novidea_HPC__Product_Definition__c == null)
    				claim.Novidea_HPC__Product_Definition__c = policy.Novidea_HPC__Product_Definition__c;
    			if (policy.Novidea_HPC__Effective_Date__c != null && claim.Novidea_HPC__Policy_Effective_Date__c == null)
    				claim.Novidea_HPC__Policy_Effective_Date__c = policy.Novidea_HPC__Effective_Date__c;
    			if (policy.Novidea_HPC__Expiration_Date__c != null && claim.Novidea_HPC__Policy_Expiration_Date__c == null)
    				claim.Novidea_HPC__Policy_Expiration_Date__c = policy.Novidea_HPC__Expiration_Date__c;
    		}
    	}
    }
}