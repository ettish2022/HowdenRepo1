public class ContactAccountImpl implements AccountSObjectInterface {
	public AccountSObjectRelation[] getAccountSObjectRelations(ID[] objectIds){
		List<AccountSObjectRelation> res = new List<AccountSObjectRelation>();
		try {
            List<Novidea_HPC__Associated_Person__c> aps = [SELECT  Novidea_HPC__Account__r.Id, Novidea_HPC__Account__r.Name, 
				                                                    Novidea_HPC__Contact__r.Id, Novidea_HPC__Contact__c, 
				                                                    Novidea_HPC__Contact__r.Name, Novidea_HPC__Contact__r.Email
				                                           FROM Novidea_HPC__Associated_Person__c
				                                           WHERE Novidea_HPC__Contact__c IN:objectIds];
            
			for (Novidea_HPC__Associated_Person__c ap:aps)
				res.add(new AccountSObjectRelation(ap.Novidea_HPC__Contact__c, ap.Novidea_HPC__Contact__r.Name, ap.Novidea_HPC__Contact__r.Email, ap.Novidea_HPC__Account__r.Id, ap.Novidea_HPC__Account__r.Name));

		} catch (Exception e){
			// TODO: Rolan - add error handling
			system.debug('getAccountSObjectRelations(ID[]):Failed querying the custom account connector:' + e.getMessage());
		}

		return res;
	}
}