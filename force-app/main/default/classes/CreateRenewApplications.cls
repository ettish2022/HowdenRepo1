global with sharing class CreateRenewApplications implements Schedulable, Database.Batchable<sObject>{
	public class CreateRenewApplicationsException extends Exception {}
	
    private Integer numOfRecsInBatch = 200;
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new CreateRenewApplications(), numOfRecsInBatch);
    }
   public CreateRenewApplications(){}
   public CreateRenewApplications(Integer numOfRecsInBatch){this.numOfRecsInBatch = numOfRecsInBatch;}
   global Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator('Select Novidea_HPC__Expiration_Date__c, Novidea_HPC__Client__c, Novidea_HPC__Premium_Amount__c ' +
      			' , Novidea_HPC__Fees__c, Novidea_HPC__Agency_Fee__c, Novidea_HPC__Commission_Amount__c, Novidea_HPC__Agent_Discount__c ' + 
      			' , Novidea_HPC__Other_Commission__c, Novidea_HPC__Liability_Limit_Per_Case__c, Novidea_HPC__Lower_Limit_of_Liability__c '+ 
      			' , Novidea_HPC__Upper_Limit_of_Liability__c, Novidea_HPC__Product_Definition__c, Novidea_HPC__Agency_Fees_Currency__c ' +
      			' , Novidea_HPC__Product_Definition__r.Name, OwnerId ' + 
      			' , Novidea_HPC__Liability_Limit_Currency__c, Novidea_HPC__Premium_Amount_Currency__c ' +  
      			' ,(Select Id From Novidea_HPC__Renewal_Applications__r) ' +
      			' ,(Select Id From Novidea_HPC__Renewal_Products__r) ' +
      			' From Novidea_HPC__Policy__c ' + 
      			' Where RecordType.DeveloperName = \'Policy\'' + ' And ' +
      			' (CALENDAR_YEAR(Novidea_HPC__Expiration_Date__c) > '  + Date.today().year() + ' Or ' +
      			' (CALENDAR_YEAR(Novidea_HPC__Expiration_Date__c) = '  + Date.today().year() + ' And ' + 
      			' (CALENDAR_MONTH(Novidea_HPC__Expiration_Date__c) > '  + Date.today().month() + ' Or ' + 
      			' (DAY_IN_MONTH(Novidea_HPC__Expiration_Date__c) >= '  + Date.today().day() +' And ' + 
      					' CALENDAR_MONTH(Novidea_HPC__Expiration_Date__c) = '  + Date.today().month() + 
      				'))))' +
      			' Order By Novidea_HPC__Expiration_Date__c, Novidea_HPC__Client__c');
   }

	global void execute(Database.BatchableContext BC, list<sObject> scope){
		if(scope.isEmpty())return;
		Set<Id> inactiveUsers = new Set<Id>();
		for (User user:[Select Id From User u Where u.IsActive = false])
			inactiveUsers.add(user.id);
		Map<Date, Map<Id, List<Novidea_HPC__Product__c>>> products = new Map<Date, Map<Id, List<Novidea_HPC__Product__c>>> ();
		Map<Date, Map<Id, Novidea_HPC__Application__c>> applications = new Map<Date, Map<Id, Novidea_HPC__Application__c>> ();
		Map<Id,String> productName = new Map<Id,String>();
		for (Novidea_HPC__Policy__c policy: (List<Novidea_HPC__Policy__c>)scope) {
			if (inactiveUsers.contains(policy.OwnerId))
				continue;
			if (policy.Novidea_HPC__Renewal_Applications__r != null && policy.Novidea_HPC__Renewal_Applications__r.size() > 0)
				continue;
			if (policy.Novidea_HPC__Renewal_Products__r != null && policy.Novidea_HPC__Renewal_Products__r.size() > 0)
				continue;
			if (policy.Novidea_HPC__Product_Definition__c == null) {
				System.debug(policy.Id);
				continue;
			}
			if (policy.Novidea_HPC__Product_Definition__r.Name.contains('רכב') || policy.Novidea_HPC__Product_Definition__r.Name.contains('דירה'))
				continue;
			if (!products.containsKey(policy.Novidea_HPC__Expiration_Date__c)) 
				products.put(policy.Novidea_HPC__Expiration_Date__c, new Map<Id, List<Novidea_HPC__Product__c>>());
			if (!products.get(policy.Novidea_HPC__Expiration_Date__c).containsKey(policy.Novidea_HPC__Client__c)) 
				products.get(policy.Novidea_HPC__Expiration_Date__c).put(policy.Novidea_HPC__Client__c, new List<Novidea_HPC__Product__c>());
			
			Novidea_HPC__Product__c newProduct = new Novidea_HPC__Product__c();
			newProduct.OwnerId = policy.OwnerId;
			newProduct.Novidea_HPC__Expected_Renewal_Date__c = newProduct.Novidea_HPC__Effective_Date__c  = policy.Novidea_HPC__Expiration_Date__c;
			if (policy.Novidea_HPC__Expiration_Date__c != null)
				newProduct.Novidea_HPC__Expiration_Date__c = policy.Novidea_HPC__Expiration_Date__c.addYears(1);
			newProduct.Novidea_HPC__Premium_Target__c = newProduct.Novidea_HPC__Expected_Premium__c = newProduct.Novidea_HPC__Premium__c = policy.Novidea_HPC__Premium_Amount__c;
			newProduct.Novidea_HPC__Expected_Fees__c = newProduct.Novidea_HPC__Fee_Amount__c = policy.Novidea_HPC__Fees__c;
			newProduct.Novidea_HPC__Target_Agency_Fee__c = newProduct.Novidea_HPC__Current_Agency_Fees__c = policy.Novidea_HPC__Agency_Fee__c;
			newProduct.Novidea_HPC__Expected_Commission_Amount__c = newProduct.Novidea_HPC__Commission_Amount__c = policy.Novidea_HPC__Commission_Amount__c;
			newProduct.Novidea_HPC__Discount__c = policy.Novidea_HPC__Agent_Discount__c;
			newProduct.Novidea_HPC__Other_Commission__c = policy.Novidea_HPC__Other_Commission__c;
			
			newProduct.Novidea_HPC__Liability_Limit_Per_Case__c = policy.Novidea_HPC__Liability_Limit_Per_Case__c;
			newProduct.Novidea_HPC__Lower_Limit_of_Liability__c = policy.Novidea_HPC__Lower_Limit_of_Liability__c;
			newProduct.Novidea_HPC__Liability_Limit__c = policy.Novidea_HPC__Upper_Limit_of_Liability__c;
			newProduct.Name = policy.Novidea_HPC__Product_Definition__r.Name;
			newProduct.Novidea_HPC__Product_Definition__c = policy.Novidea_HPC__Product_Definition__c;
			productName.put(newProduct.Novidea_HPC__Product_Definition__c, policy.Novidea_HPC__Product_Definition__r.Name);
			
			
			newProduct.Novidea_HPC__Agency_Fee_Currency__c = policy.Novidea_HPC__Agency_Fees_Currency__c;
			newProduct.Novidea_HPC__Liability_Limit_Currency__c = policy.Novidea_HPC__Liability_Limit_Currency__c;
			newProduct.Novidea_HPC__Premium_Currency__c = policy.Novidea_HPC__Premium_Amount_Currency__c;
			
			newProduct.Novidea_HPC__Product_Type__c = 'Existing product';
			
			newProduct.Novidea_HPC__Previous_Policy__c = policy.Id;
			 
			products.get(policy.Novidea_HPC__Expiration_Date__c).get(policy.Novidea_HPC__Client__c).add(newProduct);
		}
		
		List<Novidea_HPC__Application__c> applicationList = new List<Novidea_HPC__Application__c>();
		for (Date renewDate:products.keySet()) {
			if (!applications.containsKey(renewDate)) 
				applications.put(renewDate, new Map<Id, Novidea_HPC__Application__c>());
			for (Id clientId:products.get(renewDate).keySet()) {
				Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
				application.OwnerId = products.get(renewDate).get(clientId)[0].OwnerId;
				if (products.get(renewDate).get(clientId).Size() == 1)
					application.Novidea_HPC__Previous_Policy__c = products.get(renewDate).get(clientId)[0].Novidea_HPC__Previous_Policy__c;
				application.Novidea_HPC__Account__c = clientId;
				application.Novidea_HPC__Required_Policy_Type__c = 'Renew';
		    	application.Novidea_HPC__Status__c = 'Renewal';
		    	application.Name = 'הצעת חידוש - ';
		    	Set<String> branchNames = new Set<String>();
		    	for (Novidea_HPC__Product__c product:products.get(renewDate).get(clientId)) {
		    		if (!branchNames.contains(product.Novidea_HPC__Product_Definition__c))
		    			application.Name += productName.get(product.Novidea_HPC__Product_Definition__c) +' ';
		    		branchNames.add(product.Novidea_HPC__Product_Definition__c);
		    	}
		    	if (branchNames.size() > 3)
		    		application.Name = 'הצעת חידוש של כל הביטוחים המתחדשים ב-' + products.get(renewDate).get(clientId)[0].Novidea_HPC__Effective_Date__c;
		    	applications.get(renewDate).put(clientId, application);
		    	applicationList.add(application);
			}
		}
		Database.insert(applicationList);
		
		List<Novidea_HPC__Product__c> productList = new List<Novidea_HPC__Product__c>();
		for (Date renewDate:products.keySet()) {
			for (Id clientId:products.get(renewDate).keySet()) {
				Novidea_HPC__Request_for_Proposal__c rfp = new Novidea_HPC__Request_for_Proposal__c();
				rfp.Novidea_HPC__Application__c = applications.get(renewDate).get(clientId).Id;
				
				for (Novidea_HPC__Product__c product:products.get(renewDate).get(clientId)) {
					product.Novidea_HPC__Application__c = applications.get(renewDate).get(clientId).Id;
					productList.add(product);
				}
			}
		}
		Database.insert(productList);
	}

   global void finish(Database.BatchableContext BC){
   }
   /* Script for running the method:
   	 Datetime dt = Datetime.now().addMinutes(1); //change minutes here
        String min = dt.minute()+'';
        String hour = dt.hour()+'';
        String day = dt.day()+'';
        String month = dt.month()+'';
        String year = dt.year()+'';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        final String CRON_EXP = '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        system.debug(CRON_EXP);
        system.schedule('Create Renew Applications ' + '(' + CRON_EXP + ')', CRON_EXP, new CreateRenewApplications(200));
   */
}