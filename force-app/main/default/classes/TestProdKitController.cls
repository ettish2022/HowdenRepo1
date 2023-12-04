@isTest
public class TestProdKitController {

    /*
		test for addStandardProductsKit
	*/
	 static testMethod void  test001() {
         try{
             test.starttest();
             Account client = TestUtils.createAccount('test:client:1', true);
             system.debug('client: ' + client);
            Novidea_HPC__Application__c application = TestUtils.createApplication('test:application:01', 'New', client.Id, true);
             system.debug('application: ' + application);
            TestUtils.createProductDef('test:prod:def:001', true, null, true);
            TestUtils.createProductDef('test:prod:def:002', true, null, true);
            TestUtils.createProductDef('test:prod:def:003', true, null, true);
            TestUtils.createProductDef('test:prod:def:004', false, null, true);
            TestUtils.createProductDef('test:prod:def:005', false, null, true);
            ApexPages.StandardController standardCont = new ApexPages.StandardController(application); 
            ProdKitController kitController  = new ProdKitController(standardCont);
            kitController.addStandardProductsKit();
            test.stopTest();
            list<Novidea_HPC__Product__c> products = [SELECT Novidea_HPC__Application__c, Name FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Application__c =:  application.Id];
            system.assertEquals(products.size(), 3);
         }
         catch(exception ex){
             system.debug(ex.getmessage());
         }
	 	
        
        
	}
	/*
	 	test for incorrect function call
	 */
	static testMethod void  test002() {
		Exception exp = null;
		try {
            Account client = TestUtils.createAccount('test:client:1', true);
             system.debug('client: ' + client);
			ProdKitController kitController  = new ProdKitController(null);
			kitController.addStandardProductsKit();
            system.debug(exp.getTypeName());
            system.assertEquals(exp.getTypeName(), 'ProdKitController.ApplicationNotExistException');
		} catch(Exception e) {
			exp = e;
		}
		
		
	}
}