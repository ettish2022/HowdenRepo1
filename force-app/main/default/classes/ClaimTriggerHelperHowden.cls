public without sharing class ClaimTriggerHelperHowden {

	public static Boolean inWork = false;
	public static boolean stopTrigger = false;
	//public class customException extends Exception {} 
	public static void onAfterInsert(  
			list<Novidea_HPC__Claim__c> newClaims){  
		if(stopTrigger) 
		inWork = true; 
		shareClaims(newClaims);    	 
		inWork = false;
	}
	
	public static void onAfterUpdate(  
			list<Novidea_HPC__Claim__c>oldClaims,
			map<Id,Novidea_HPC__Claim__c> newClaims){  
		if(stopTrigger) 
		inWork = true; 
		changeExistClaimsType(oldClaims,newClaims);    	 
		inWork = false;
	}

	/////////////////////////////////////////////////////////action////////////////////////////////////////////////////////////////////////////////////////
	
	/*
		method which share users when change exist claim to personal and cancel sharing when change exist claim 
		to not personal
		oldClaims:trigger old
		newClaims: trigger new map
	*/
	
	
	public static void changeExistClaimsType (list<Novidea_HPC__Claim__c>oldClaims,
			map<Id,Novidea_HPC__Claim__c> newClaims){
		list<Novidea_HPC__Claim__c> newPersonalClaims = new list<Novidea_HPC__Claim__c>(); 
		list<Novidea_HPC__Claim__c> newNonPersonalClaims = new list<Novidea_HPC__Claim__c>(); 
		for (Novidea_HPC__Claim__c claim : oldClaims){
			if (newClaims.get(claim.Id).Record_Type__c != claim.Record_Type__c //change claim to personal
					&& newClaims.get(claim.Id).Record_Type__c == 'Personal'){
				newPersonalClaims.add(newClaims.get(claim.Id));			
			}
			else if (newClaims.get(claim.Id).Record_Type__c != claim.Record_Type__c //change claim to unpersonal
					&& claim.Record_Type__c == 'Personal'){
				newNonPersonalClaims.add(newClaims.get(claim.Id));		
			}
					
		}
		if (newPersonalClaims != null && newPersonalClaims.size()!= 0)
			shareClaims(newPersonalClaims);			
		if (newNonPersonalClaims != null && newNonPersonalClaims.size()!= 0)
			cancelShareClaim(newNonPersonalClaims);		
	}
	
	/*
		method which cancel share claim when it is changed to not personal
		newClaims: trigger new 
	*/
	
	public static void cancelShareClaim(list <Novidea_HPC__Claim__c> newClaims){
		list <Novidea_HPC__Claim__Share> claimShareDeleteList=[SELECT ParentId,UserOrGroupId 
				FROM Novidea_HPC__Claim__Share WHERE ParentId IN : newClaims 
				AND UserOrGroupId=:System.label.External_Claim_Department_Group_Id];
		
		database.delete(claimShareDeleteList);	
	}
	
	/*
		method which find all users which have personal claim
		newClaims:trigger new
		newClaimsMap: trigger new map
	*/
	
	public static void shareClaims(list <Novidea_HPC__Claim__c> newClaims){
		list<Novidea_HPC__Claim__c> claims = new list<Novidea_HPC__Claim__c>();
		for (Novidea_HPC__Claim__c claim : newClaims)
			if (claim.Record_Type__c == 'Personal')
				claims.add(claim);
		
		list<Novidea_HPC__Claim__Share> claimsShare = new list<Novidea_HPC__Claim__Share>();		
		for (Novidea_HPC__Claim__c Claim:Claims){
				Novidea_HPC__Claim__Share claimShare = new Novidea_HPC__Claim__Share();
				claimShare.ParentId = Claim.Id; // The account that we are trying to grant access to.
				claimShare.UserOrGroupId = System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
				claimShare.AccessLevel = 'Edit';
				//claimShare.OpportunityAccessLevel = 'Read';
				//claimShare.CaseAccessLevel = 'Read';
				//claimShare.AccountAccessLevel = 'Read';
				claimsShare.add(claimShare);
			
		}		
		Database.upsert(claimsShare);	
	}
	
}