public with sharing class ProductTriggerHelper {
/*	public static void updateApplication(List<Novidea_HPC__Product__c> products){
		
		map<Id,list<Novidea_HPC__Product__c>> prodsByAppId = new map<Id,list<Novidea_HPC__Product__c>>();
		list<Novidea_HPC__Product__c> tmpprods;
		for (Novidea_HPC__Product__c product:products) {
			if (product.Novidea_HPC__Application__c != null){
				if((tmpprods=prodsByAppId.get(product.Novidea_HPC__Application__c))==null)
					tmpprods = new list<Novidea_HPC__Product__c>();
				tmpprods.add(product);
				prodsByAppId.put(product.Novidea_HPC__Application__c,tmpprods);
			}
		}
		map<Id,Novidea_HPC__Application__c> applications = 
					new map<Id,Novidea_HPC__Application__c>([SELECT Novidea_HPC__Application_Date__c,
																	(SELECT Novidea_HPC__Effective_Date__c FROM  Novidea_HPC__Products__r) 
															FROM Novidea_HPC__Application__c
															WHERE Id IN :prodsByAppId.keyset()]);
		list<Novidea_HPC__Application__c> applicationsList = new list<Novidea_HPC__Application__c>();
		for(Id key: prodsByAppId.keyset()){
			Date d = calcMinProdsEffDate(prodsByAppId.get(key), applications.get(Key).Novidea_HPC__Products__r);
			system.debug(d);
			applications.get(Key).Novidea_HPC__Application_Date__c = d;
			applicationsList.add(applications.get(Key));
		}
		if (!applicationsList.isempty()){
			Database.update(applicationsList);
		}
	}
*/	
	/*
		raniz 27/12/2012: decides which date is the minimal date for the application:
		1. create a list of dates that simulates the state of the products within the app after the update of insert
		2. once the list is ready tghe minimal effective date of the products is the date taht should be used.
	*/
/*	private static Date calcMinProdsEffDate(list<Novidea_HPC__Product__c> currents, list<Novidea_HPC__Product__c> persistents){
		map<String,Date> dateByProdId = new map<String,Date>();
		Date tmpDate;
		boolean found = false;
		system.debug(currents + '\n' + persistents);
		set<Id> foundCurrents = new set<Id>();
		if(persistents!=null && !persistents.isempty()){
			for(Novidea_HPC__Product__c persistent: persistents){
				for(Novidea_HPC__Product__c current: currents){
					if(current.id==persistent.Id){
						if(current.Novidea_HPC__Effective_Date__c!=null)
							dateByProdId.put(current.id,current.Novidea_HPC__Effective_Date__c);
						system.debug(dateByProdId);
						foundCurrents.add(current.id);
						found = true;
						break;
					}
				}
				if(!found) {
					if(persistent.Novidea_HPC__Effective_Date__c!=null)
						dateByProdId.put(persistent.id,persistent.Novidea_HPC__Effective_Date__c);
						system.debug(dateByProdId);
				}
				else found = false;
			}
			//add new products
			for(integer i=0;i< currents.size();i++){
				Novidea_HPC__Product__c current = currents.get(i);
				if(!foundCurrents.contains(current.Id)){
					dateByProdId.put(i+'',current.Novidea_HPC__Effective_Date__c);
					system.debug(dateByProdId);
				}
			}
		}
		//all given products are new 
		else{
			for(Novidea_HPC__Product__c current: currents){
				if(current.Novidea_HPC__Effective_Date__c!=null)
					dateByProdId.put(current.id,current.Novidea_HPC__Effective_Date__c);
			}
		}
		if(!dateByProdId.isempty()){
			list<date> sorted = new list<date>(dateByProdId.values());
			sorted.sort();
			system.debug(sorted);
			return sorted[0];
		}
		else return null;
	}

	
	static testMethod void testUpdateApplication() {
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Database.insert(application);
		Novidea_HPC__Product__c product1 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today(), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product2 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today()-1, Novidea_HPC__Application__c = application.Id);
		Database.insert(new List<Novidea_HPC__Product__c>{product1,product2});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today()-1, application.Novidea_HPC__Application_Date__c);
	}
	
	static testMethod void testNewProdsAndUpdate() {
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Database.insert(application);
		Novidea_HPC__Product__c product1 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today(), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product2 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today().adddays(7), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product3 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today().adddays(-7), Novidea_HPC__Application__c = application.Id);
		Database.insert(new List<Novidea_HPC__Product__c>{product1,product2,product3});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(-7), application.Novidea_HPC__Application_Date__c);
		product3.Novidea_HPC__Effective_Date__c = Date.today().adddays(1);
		database.update(product3);
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today(), application.Novidea_HPC__Application_Date__c);
		product1.Novidea_HPC__Effective_Date__c = Date.today().adddays(2);
		database.update(product1);
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(1), application.Novidea_HPC__Application_Date__c);
	}
	
	static testMethod void testAddNewProds() {
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Database.insert(application);
		Novidea_HPC__Product__c product1 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today(), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product2 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today().adddays(7), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product3 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today().adddays(-7), Novidea_HPC__Application__c = application.Id);
		Database.insert(new List<Novidea_HPC__Product__c>{product1,product2,product3});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(-7), application.Novidea_HPC__Application_Date__c);
		
		product3.Novidea_HPC__Effective_Date__c = Date.today().adddays(1);
		database.update(product3);
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today(), application.Novidea_HPC__Application_Date__c);
		
		Novidea_HPC__Product__c product4 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c = Date.today().adddays(2), Novidea_HPC__Application__c = application.Id);
		database.insert(product4);
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today(), application.Novidea_HPC__Application_Date__c);
		
		Novidea_HPC__Product__c product5 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c = Date.today().adddays(-1), Novidea_HPC__Application__c = application.Id);
		database.insert(product5);
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(-1), application.Novidea_HPC__Application_Date__c);
	}
	
	static testMethod void testUpdateProds() {
		Novidea_HPC__Application__c application = new Novidea_HPC__Application__c();
		Database.insert(application);
		Novidea_HPC__Product__c product1 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today(), Novidea_HPC__Application__c = application.Id);
		Novidea_HPC__Product__c product2 = new Novidea_HPC__Product__c(Novidea_HPC__Effective_Date__c=Date.today(), Novidea_HPC__Application__c = application.Id);
		Database.insert(new List<Novidea_HPC__Product__c>{product1,product2});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today(), application.Novidea_HPC__Application_Date__c);
		product1.Novidea_HPC__Effective_Date__c = Date.today().adddays(1);
		product2.Novidea_HPC__Effective_Date__c = Date.today().adddays(1);
		database.update(new list<Novidea_HPC__Product__c>{product1, product2});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(1), application.Novidea_HPC__Application_Date__c);
		
		product1.Novidea_HPC__Effective_Date__c = Date.today().adddays(2);
		product2.Novidea_HPC__Effective_Date__c = null;
		database.update(new list<Novidea_HPC__Product__c>{product1, product2});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(2), application.Novidea_HPC__Application_Date__c);
		
		product1.Novidea_HPC__Effective_Date__c = Date.today().adddays(3);
		database.update(new list<Novidea_HPC__Product__c>{product1});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(3), application.Novidea_HPC__Application_Date__c);
		
		product1.Novidea_HPC__Effective_Date__c = Date.today().adddays(1);
		product2.Novidea_HPC__Effective_Date__c = Date.today().adddays(2);
		database.update(new list<Novidea_HPC__Product__c>{product1, product2});
		application = [Select Novidea_HPC__Application_Date__c From Novidea_HPC__Application__c Where Id = :application.Id];
		system.assertEquals(Date.today().adddays(1), application.Novidea_HPC__Application_Date__c);
	}
	*/
}