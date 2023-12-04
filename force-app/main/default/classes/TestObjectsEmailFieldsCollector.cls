@isTest
public class TestObjectsEmailFieldsCollector {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
    
	private static testmethod void testfunctions(){ 
        test.startTest();
		Account account = new Account();
		account.Name = 'test';
		//account.Email__c = 'diana@yahoo.com';
		insert account;
		Contact c = new Contact(LastName = 'Rolan', AccountId = account.id, Email = 'rolan@novidea.com');
		insert c;
        test.stopTest();
		//system.assertEquals(getSobjectType(account.Id).getName(),'Account');
		system.debug('DIANA: '+ ObjectsEmailFieldsCollector.getEmailAddrs(account.Id));		
	}
}