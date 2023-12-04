trigger InvolvedInClaimTrigger on Novidea_HPC__Involved_In_Claim__c (before insert) {
	if(Trigger.isbefore && Trigger.isInsert){
		set<Id> claimIds = new set<Id>();
		for(Novidea_HPC__Involved_In_Claim__c iic :(list<Novidea_HPC__Involved_In_Claim__c>)Trigger.New)
			claimIds.add(iic.Novidea_HPC__Claim__c);
		map<Id,Novidea_HPC__Claim__c> clms = new map<Id,Novidea_HPC__Claim__c>(
														[SELECT Novidea_HPC__Client__c 
														FROM Novidea_HPC__Claim__c 
														WHERE Id IN: claimIds]);
		
		for(Novidea_HPC__Involved_In_Claim__c iic :(list<Novidea_HPC__Involved_In_Claim__c>)Trigger.New){
			iic.Client__c = clms.get(iic.Novidea_HPC__Claim__c).Novidea_HPC__Client__c;
		}
	}
}