public with sharing class ProdKitController {
	
	public class ApplicationNotExistException extends Exception {
		public ApplicationNotExistException(Boolean dummy) {
			this.setMessage(Label.application_object_not_exist);
		}
	}
	
	Novidea_HPC__Application__c currentApplication = null;
	
	public ProdKitController(ApexPages.StandardController standardCont ) {
		if(null != standardCont)
			currentApplication = (Novidea_HPC__Application__c)standardCont.getRecord();
	}
	/*	
	 *	a function adds the products with standard product definitions in application.
	 */																		
	public PageReference addStandardProductsKit() {
		
		if(null == currentApplication) {
			throw new ApplicationNotExistException(true);
		}
		
		list<Novidea_HPC__Product_Def__c> standardProdDefList = [SELECT Id, Name, 
		                                                                Standard_Product_Definition__c 
		                                                           FROM Novidea_HPC__Product_Def__c 
		                                                          WHERE Standard_Product_Definition__c = true];
		
		list<Novidea_HPC__Product__c> products = new list<Novidea_HPC__Product__c>();
		
		for(Novidea_HPC__Product_Def__c proDef : standardProdDefList )
			products.add(new Novidea_HPC__Product__c( Name = proDef.Name 
			                                         ,Novidea_HPC__Product_Definition__c = proDef.Id
			                                         ,Novidea_HPC__Application__c = currentApplication.Id));
		
		Database.insert(products);
		
		PageReference applPage = new ApexPages.StandardController(currentApplication).view();
        applPage.setRedirect(true);
        return applPage;
	}
	
}